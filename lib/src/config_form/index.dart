import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_config.dart';
import 'package:simple_ui/models/form_type.dart';
import 'package:simple_ui/src/config_form/widgets/index.dart';
import 'config_form_controller.dart';
import 'utils/data_conversion_utils.dart';
import 'utils/form_data_parser.dart';
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
    final matched = widget.configs.where((c) => c.name == fieldName);
    dynamic parsedValue = value;

    if (matched.isNotEmpty) {
      final config = matched.first;
      parsedValue = FormDataParser.parseFormValue(value, config);
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
            // 报错提示信息：暂未实现的字段类型
            if (controller == null) {
              return Padding(padding: const EdgeInsets.only(bottom: 16), child: Text('暂未实现的字段类型: ${config.type}'));
            }
            if (config.type == FormType.text) {
              return InputForText(config: config, controller: controller, onChanged: (value) => _updateFormData(config.name, value));
            } else if (config.type == FormType.number) {
              return InputForNumber(config: config, controller: controller, onChanged: (value) => _updateFormData(config.name, value));
            } else if (config.type == FormType.integer) {
              return InputForInteger(config: config, controller: controller, onChanged: (value) => _updateFormData(config.name, value));
            } else if (config.type == FormType.textarea) {
              return InputForTextarea(config: config, controller: controller, onChanged: (value) => _updateFormData(config.name, value));
            } else if (config.type == FormType.radio) {
              return SelectForRadio(config: config, controller: controller, onChanged: (value) => _updateFormData(config.name, value));
            } else if (config.type == FormType.checkbox) {
              return SelectForCheckbox(config: config, controller: controller, onChanged: (value) => _updateFormData(config.name, value));
            } else if (config.type == FormType.select) {
              return SelectForSelect(config: config, controller: controller, onChanged: (value) => _updateFormData(config.name, value));
            } else if (config.type == FormType.dropdown) {
              return SelectForDropdown(config: config, controller: controller, onChanged: (value) => _updateFormData(config.name, value));
            } else if (config.type == FormType.treeSelect) {
              return SelectForTree(config: config, controller: controller, onChanged: (value) => _updateFormData(config.name, value));
            } else if (config.type == FormType.date) {
              return DateTimeForDate(config: config, controller: controller, onChanged: (value) => _updateFormData(config.name, value));
            } else if (config.type == FormType.time) {
              return DateTimeForTime(config: config, controller: controller, onChanged: (value) => _updateFormData(config.name, value));
            } else if (config.type == FormType.datetime) {
              return DateTimeForDateTime(config: config, controller: controller, onChanged: (value) => _updateFormData(config.name, value));
            } else if (config.type == FormType.upload) {
              return UploadForFile(config: config, controller: controller, onChanged: (value) => _updateFormData(config.name, value));
            } else if (config.type == FormType.custom) {
              return CustomForAny(config: config, controller: controller, onChanged: (value) => _updateFormData(config.name, value));
            } else {
              return InputForText(config: config, controller: controller, onChanged: (value) => _updateFormData(config.name, value));
            }
            // return Padding(
            //   padding: const EdgeInsets.only(bottom: 16),
            //   child: FieldFactory.buildField(config: config, controller: controller, onChanged: (value) => _updateFormData(config.name, value)),
            // );
          }),
        ],
      ),
    );
  }
}
