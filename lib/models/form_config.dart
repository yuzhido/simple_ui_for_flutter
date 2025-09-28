import 'package:flutter/material.dart';
import 'package:simple_ui/models/validator.dart';
import 'package:simple_ui/models/form_type.dart';
import 'package:simple_ui/src/config_form/widgets/index.dart';
import 'field_configs.dart';

typedef FieldBuilder = Widget Function(FormConfig config, TextEditingController controller, Function(String) onChanged);

/// 统一的表单字段配置
class FormConfig<T> {
  final FormType type;
  final BaseFieldConfig config;
  final FieldBuilder? builder;

  const FormConfig({required this.type, required this.config, this.builder});

  // 获取字段名称
  String get name => config.name;

  // 获取字段标签
  String? get label => config.label;

  // 是否必填
  bool get required => config.required;

  // 默认值
  dynamic get defaultValue => config.defaultValue;

  // 验证器
  FormValidator? get validator => config.validator;

  // 是否显示
  bool get isShow => config.isShow;
  // 便捷构造方法
  static FormConfig text(TextFieldConfig config) => FormConfig(type: FormType.text, config: config);
  static FormConfig textarea(TextareaFieldConfig config) => FormConfig(type: FormType.textarea, config: config);
  static FormConfig number(NumberFieldConfig config) => FormConfig(type: FormType.number, config: config);
  static FormConfig integer(IntegerFieldConfig config) => FormConfig(type: FormType.integer, config: config);
  static FormConfig date(DateFieldConfig config) => FormConfig(type: FormType.date, config: config);
  static FormConfig time(TimeFieldConfig config) => FormConfig(type: FormType.time, config: config);
  static FormConfig datetime(DateTimeFieldConfig config) => FormConfig(type: FormType.datetime, config: config);
  static FormConfig radio<T>(RadioFieldConfig<T> config) => FormConfig(
    type: FormType.radio,
    config: config,
    builder: (FormConfig cfg, TextEditingController controller, Function(String) onChanged) =>
        SelectForRadio<T>(config: cfg as dynamic, controller: controller, onChanged: onChanged),
  );
  static FormConfig checkbox<T>(CheckboxFieldConfig<T> config) => FormConfig(
    type: FormType.checkbox,
    config: config,
    builder: (FormConfig cfg, TextEditingController controller, Function(String) onChanged) =>
        SelectForCheckbox<T>(config: cfg as dynamic, controller: controller, onChanged: onChanged),
  );
  static FormConfig select<T>(SelectFieldConfig<T> config) => FormConfig(
    type: FormType.select,
    config: config,
    builder: (FormConfig cfg, TextEditingController controller, Function(String) onChanged) =>
        SelectForSelect<T>(config: cfg as dynamic, controller: controller, onChanged: onChanged),
  );
  static FormConfig dropdown<T>(DropdownFieldConfig<T> config) => FormConfig(
    type: FormType.dropdown,
    config: config,
    builder: (FormConfig cfg, TextEditingController controller, Function(String) onChanged) => SelectForDropdown<T>(config: cfg, controller: controller, onChanged: onChanged),
  );
  static FormConfig upload(UploadFieldConfig config) => FormConfig(type: FormType.upload, config: config);
  static FormConfig treeSelect<T>(TreeSelectFieldConfig<T> config) => FormConfig(
    type: FormType.treeSelect,
    config: config,
    builder: (FormConfig cfg, TextEditingController controller, Function(String) onChanged) => SelectForTree<T>(config: cfg, controller: controller, onChanged: onChanged),
  );
  static FormConfig custom(CustomFieldConfig config) => FormConfig(type: FormType.custom, config: config);
}
