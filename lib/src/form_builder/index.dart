import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';
import 'widgets/index.dart';

/// FormBuilder控制器，用于管理表单状态
class FormBuilderController extends ChangeNotifier {
  final Map<String, dynamic> _values = {};
  Map<String, dynamic> get values => Map.unmodifiable(_values);

  /// 设置单个字段的值
  void setValue(String fieldName, dynamic value) {
    _values[fieldName] = value;
    notifyListeners();
  }

  /// 获取单个字段的值
  dynamic getValue(String fieldName) {
    return _values[fieldName];
  }

  /// 批量设置字段值
  void setValues(Map<String, dynamic> values) {
    _values.addAll(values);
    notifyListeners();
  }

  /// 清空所有字段值
  void clear() {
    _values.clear();
    notifyListeners();
  }

  /// 重置字段值到默认值
  void reset(List<FormBuilderConfig> configs) {
    _values.clear();
    for (final config in configs) {
      if (config.isSaveInfo && config.defaultValue != null) {
        _values[config.name] = config.defaultValue;
      }
    }
    notifyListeners();
  }
}

/// FormBuilder组件 - 数据驱动表单
class FormBuilder extends StatefulWidget {
  /// 表单配置列表
  final List<FormBuilderConfig> configs;

  /// 内边距
  final EdgeInsets? padding;

  /// 标签样式
  final TextStyle? labelStyle;

  /// 字段间距
  final double? fieldGap;

  /// 表单Key
  final GlobalKey<FormState>? formKey;

  /// 控制器
  final FormBuilderController? controller;

  /// 是否自动验证
  final bool autovalidate;

  const FormBuilder({super.key, required this.configs, this.padding, this.labelStyle, this.fieldGap, this.formKey, this.controller, this.autovalidate = false});

  @override
  State<FormBuilder> createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  final FocusNode _unfocusNode = FocusNode(debugLabel: 'unfocus-holder');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, dynamic> _fieldValues = {};

  @override
  void initState() {
    super.initState();
    _initControllers();
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _initControllers() {
    for (final config in widget.configs) {
      if (!config.isShow || !config.isSaveInfo) continue;

      // 初始化文本类型字段的控制器
      if (_isTextType(config.type)) {
        _textControllers[config.name] = TextEditingController(text: config.defaultValue?.toString() ?? '');
      }

      // 初始化字段值
      _fieldValues[config.name] = config.defaultValue;
    }

    _syncController();
  }

  void _onControllerChanged() {
    if (widget.controller != null) {
      final controllerValues = widget.controller!.values;
      bool hasChanges = false;

      for (final entry in controllerValues.entries) {
        if (_fieldValues[entry.key] != entry.value) {
          _fieldValues[entry.key] = entry.value;
          if (_textControllers.containsKey(entry.key)) {
            _textControllers[entry.key]?.text = entry.value?.toString() ?? '';
          }
          hasChanges = true;
        }
      }

      if (hasChanges) {
        setState(() {});
      }
    }
  }

  void _syncController() {
    widget.controller?.setValues(_fieldValues);
  }

  bool _isTextType(FormBuilderType type) {
    return type == FormBuilderType.text || type == FormBuilderType.number || type == FormBuilderType.integer || type == FormBuilderType.textarea;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) {
        FocusScope.of(context).requestFocus(_unfocusNode);
      },
      onPanDown: (_) {
        FocusScope.of(context).requestFocus(_unfocusNode);
      },
      child: Focus(
        focusNode: _unfocusNode,
        descendantsAreFocusable: true,
        canRequestFocus: true,
        child: Form(
          key: widget.formKey ?? _formKey,
          autovalidateMode: widget.autovalidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          child: SingleChildScrollView(
            padding: widget.padding ?? const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _buildFormFields()),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    final widgets = <Widget>[];

    for (final config in widget.configs) {
      if (!config.isShow) continue;

      // 构建标签
      if (config.label != null && config.label!.trim().isNotEmpty) {
        widgets.add(_buildLabel(config.label!, isRequired: config.required));
        widgets.add(SizedBox(height: widget.fieldGap ?? 8));
      }

      // 构建字段
      widgets.add(_buildField(config, (name, value) => widget.controller?.setValue(name, value)));
      widgets.add(SizedBox(height: widget.fieldGap ?? 16));
    }

    return widgets;
  }

  Widget _buildLabel(String label, {bool isRequired = false}) {
    final style = widget.labelStyle ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87);

    if (!isRequired) {
      return Text(label, style: style);
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: label, style: style),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildField(FormBuilderConfig config, Function(String, dynamic) onChanged) {
    final currentValue = widget.controller?.getValue(config.name);

    void onFieldChanged(value) {
      onChanged(config.name, value);
      // 调用配置中的 onChange 回调
      config.onChange?.call(config.name, value);
    }

    switch (config.type) {
      case FormBuilderType.text:
        return TextFieldWidget(config: config, value: currentValue, onChanged: onFieldChanged);
      case FormBuilderType.number:
        return NumberFieldWidget(config: config, value: currentValue, onChanged: onFieldChanged);
      case FormBuilderType.integer:
        return IntegerFieldWidget(config: config, value: currentValue, onChanged: onFieldChanged);
      case FormBuilderType.textarea:
        return TextareaFieldWidget(config: config, value: currentValue, onChanged: onFieldChanged);
      case FormBuilderType.radio:
        return RadioFieldWidget(config: config, value: currentValue, onChanged: onFieldChanged);
      case FormBuilderType.checkbox:
        return CheckboxFieldWidget(config: config, value: currentValue, onChanged: onFieldChanged);
      case FormBuilderType.select:
        return SelectFieldWidget(config: config, value: currentValue, onChanged: onFieldChanged);
      case FormBuilderType.dropdown:
        return DropdownFieldWidget(config: config, value: currentValue, onChanged: onFieldChanged);
      case FormBuilderType.date:
        return DateFieldWidget(config: config, value: currentValue, onChanged: onFieldChanged);
      case FormBuilderType.time:
        return TimeFieldWidget(config: config, value: currentValue, onChanged: onFieldChanged);
      case FormBuilderType.datetime:
        return DateTimeFieldWidget(config: config, value: currentValue, onChanged: onFieldChanged);
      case FormBuilderType.upload:
        return UploadFieldWidget(config: config, value: currentValue, onChanged: onFieldChanged);
      case FormBuilderType.custom:
        return CustomFieldWidget(config: config, value: currentValue, onChanged: onFieldChanged);
    }
  }
}
