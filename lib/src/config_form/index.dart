import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_config.dart';
import 'package:simple_ui/models/form_type.dart';
import 'widgets/field_factory.dart';
import 'config_form_controller.dart';
import 'utils/data_conversion_utils.dart';
export 'config_form_controller.dart';

class ConfigForm extends StatefulWidget {
  // 表单配置
  final List<FormConfig> configs;
  // 表单初始值
  final Map<String, dynamic>? initialValues;
  // 表单数据改变回调
  final Function(Map<String, dynamic>)? onChanged;
  // 表单提交按钮构建回调
  final Widget Function(Map<String, dynamic> formData)? submitBuilder;
  // 表单控制器
  final ConfigFormController? controller;

  const ConfigForm({super.key, required this.configs, this.initialValues, this.onChanged, this.submitBuilder, this.controller});

  @override
  State<ConfigForm> createState() => _ConfigFormState();
}

class _ConfigFormState extends State<ConfigForm> {
  late Map<String, dynamic> _formData;
  final Map<String, TextEditingController> _controllers = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeFormData();
    _initializeController();
  }

  void _initializeController() {
    if (widget.controller != null) {
      widget.controller!.setFormKey(_formKey);
      widget.controller!.setGetFormData(() => getFormData());
      widget.controller!.setControllers(_controllers);
      widget.controller!.setFormData(_formData);
      widget.controller!.setUpdateFormData(_updateFormData);
    }
  }

  void _initializeFormData() {
    _formData = Map<String, dynamic>.from(widget.initialValues ?? {});

    // 初始化控制器和表单数据
    for (var config in widget.configs) {
      if (config.type == FormType.text ||
          config.type == FormType.textarea ||
          config.type == FormType.number ||
          config.type == FormType.integer ||
          config.type == FormType.date ||
          config.type == FormType.time ||
          config.type == FormType.datetime ||
          config.type == FormType.radio ||
          config.type == FormType.checkbox ||
          config.type == FormType.select ||
          config.type == FormType.dropdown ||
          config.type == FormType.treeSelect ||
          config.type == FormType.custom ||
          config.type == FormType.upload) {
        // 使用统一的数据转换工具，避免List被错误转换为"[item1,item2]"格式
        final defaultValue = DataConversionUtils.valueToControllerText(config.defaultValue, config.type);
        final currentValue = DataConversionUtils.valueToControllerText(_formData[config.name], config.type);
        _controllers[config.name] = TextEditingController(text: currentValue.isNotEmpty ? currentValue : defaultValue);
        // 如果表单数据中没有这个字段，但有默认值，则设置默认值
        if (!_formData.containsKey(config.name) && config.defaultValue != null) {
          _formData[config.name] = config.defaultValue;
        }
      }
    }

    // 初始化完成后通知父组件
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged?.call(_formData);
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateFormData(String fieldName, dynamic value) {
    // 根据字段类型将字符串转换为期望的实际类型
    dynamic parsedValue = value;
    final matched = widget.configs.where((c) => c.name == fieldName);
    if (matched.isNotEmpty) {
      final fieldType = matched.first.type;
      final fieldConfig = matched.first.config;
      switch (fieldType) {
        case FormType.number:
          if (value == null) {
            parsedValue = null;
          } else {
            final str = value.toString().trim();
            parsedValue = str.isEmpty ? null : double.tryParse(str);
          }
          break;
        case FormType.integer:
          if (value == null) {
            parsedValue = null;
          } else {
            final str = value.toString().trim();
            parsedValue = str.isEmpty ? null : int.tryParse(str);
          }
          break;
        case FormType.radio:
          // 单选：将字符串反查为原始 option.value 的类型
          try {
            // ignore: unnecessary_cast
            final options = (fieldConfig as dynamic).options as List<dynamic>;
            dynamic opt;
            try {
              opt = options.firstWhere((o) => (o.value?.toString() ?? '') == (value?.toString() ?? ''));
            } catch (_) {
              opt = null;
            }
            parsedValue = opt?.value;
          } catch (_) {
            parsedValue = value;
          }
          break;
        case FormType.select:
          // 下拉：支持单选/多选。控件以字符串/逗号分隔回传，这里反查成原始类型或列表
          try {
            // ignore: unnecessary_cast
            final cfg = fieldConfig as dynamic; // SelectFieldConfig
            final options = cfg.options as List<dynamic>;
            toOriginal(String s) {
              final found = options.where((o) => (o.value?.toString() ?? '') == s).toList();
              return found.isEmpty ? s : found.first.value;
            }

            final str = value?.toString() ?? '';
            if (cfg.multiple == true) {
              if (str.isEmpty) {
                parsedValue = <dynamic>[];
              } else {
                final parts = str.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                parsedValue = parts.map(toOriginal).toList();
              }
            } else {
              parsedValue = str.isEmpty ? null : toOriginal(str);
            }
          } catch (_) {
            parsedValue = value;
          }
          break;
        case FormType.checkbox:
          // 多选复选：以逗号分隔字符串回传，这里反查为原始类型列表
          try {
            // ignore: unnecessary_cast
            final options = (fieldConfig as dynamic).options as List<dynamic>;
            mapOne(String s) {
              final found = options.where((o) => (o.value?.toString() ?? '') == s).toList();
              return found.isEmpty ? s : found.first.value;
            }

            final str = value?.toString() ?? '';
            if (str.isEmpty) {
              parsedValue = <dynamic>[];
            } else {
              parsedValue = str.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).map(mapOne).toList();
            }
          } catch (_) {
            parsedValue = value;
          }
          break;
        case FormType.dropdown:
          // DropdownChoose：与 select 相同规则，支持单/多选，字符串(或逗号串)反查为原始类型
          try {
            final cfg = fieldConfig as dynamic; // DropdownFieldConfig
            final options = cfg.options as List<dynamic>;
            toOriginal(String s) {
              final found = options.where((o) => (o.value?.toString() ?? '') == s).toList();
              return found.isEmpty ? s : found.first.value;
            }

            final str = value?.toString() ?? '';
            if (cfg.multiple == true) {
              if (str.isEmpty) {
                parsedValue = <dynamic>[];
              } else {
                final parts = str.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                parsedValue = parts.map(toOriginal).toList();
              }
            } else {
              parsedValue = str.isEmpty ? null : toOriginal(str);
            }
          } catch (_) {
            parsedValue = value;
          }
          break;
        case FormType.treeSelect:
          // TreeSelect：同下拉规则，字符串(或逗号串)反查为原始类型或列表
          try {
            final cfg = fieldConfig as dynamic; // TreeSelectFieldConfig
            final options = cfg.options as List<dynamic>;
            // 深度搜索树节点
            List<dynamic> flatten(List<dynamic> nodes) {
              final result = <dynamic>[];
              for (final n in nodes) {
                result.add(n);
                final children = (n.children as List<dynamic>?) ?? const [];
                if (children.isNotEmpty) {
                  result.addAll(flatten(children));
                }
              }
              return result;
            }

            final flatOptions = flatten(options);
            toOriginal(String s) {
              final found = flatOptions.where((o) => (o.value?.toString() ?? '') == s).toList();
              return found.isEmpty ? s : found.first.value;
            }

            final str = value?.toString() ?? '';
            if (cfg.multiple == true) {
              if (str.isEmpty) {
                parsedValue = <dynamic>[];
              } else {
                final parts = str.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                parsedValue = parts.map(toOriginal).toList();
              }
            } else {
              parsedValue = str.isEmpty ? null : toOriginal(str);
            }
          } catch (_) {
            parsedValue = value;
          }
          break;
        default:
          // 其它类型保持原值
          parsedValue = value;
      }
    }

    setState(() {
      _formData[fieldName] = parsedValue;
    });
    widget.onChanged?.call(_formData);
  }

  /// 验证表单
  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  /// 获取表单数据
  Map<String, dynamic> getFormData() {
    return Map<String, dynamic>.from(_formData);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...widget.configs.where((config) => config.isShow).map((config) {
            final controller = _controllers[config.name];
            if (controller == null) {
              return Padding(padding: const EdgeInsets.only(bottom: 16), child: Text('暂未实现的字段类型: ${config.type}'));
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FieldFactory.buildField(config: config, controller: controller, onChanged: (value) => _updateFormData(config.name, value)),
            );
          }),
          if (widget.submitBuilder != null) ...[const SizedBox(height: 20), widget.submitBuilder!(_formData)],
        ],
      ),
    );
  }
}
