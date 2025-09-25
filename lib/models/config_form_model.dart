import 'package:flutter/material.dart';
import 'package:simple_ui/src/config_form/widgets/tree_select_field_widget.dart';
import 'package:simple_ui/src/config_form/widgets/radio_field_widget.dart';
import 'package:simple_ui/src/config_form/widgets/checkbox_field_widget.dart';
import 'package:simple_ui/src/config_form/widgets/select_field_widget.dart';
import 'field_configs.dart';
import 'package:simple_ui/src/config_form/widgets/dropdown_field_widget.dart';

/// 表单字段类型枚举
enum FormType {
  // 文本1
  text,
  // 数字2
  number,
  // 整数3
  integer,
  // 多行文本4
  textarea,
  // 单选5
  radio,
  // 多选6
  checkbox,
  // 下拉7
  select,
  // 自定义下拉8
  dropdown,
  // 日期9
  date,
  // 时间10
  time,
  // 日期时间11
  datetime,
  // 上传12
  upload,
  // 树选择13
  treeSelect,
  // 自定义14
  custom,
}

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
        RadioFieldWidget<T>(config: cfg as dynamic, controller: controller, onChanged: onChanged),
  );
  static FormConfig checkbox<T>(CheckboxFieldConfig<T> config) => FormConfig(
    type: FormType.checkbox,
    config: config,
    builder: (FormConfig cfg, TextEditingController controller, Function(String) onChanged) =>
        CheckboxFieldWidget<T>(config: cfg as dynamic, controller: controller, onChanged: onChanged),
  );
  static FormConfig select<T>(SelectFieldConfig<T> config) => FormConfig(
    type: FormType.select,
    config: config,
    builder: (FormConfig cfg, TextEditingController controller, Function(String) onChanged) =>
        SelectFieldWidget<T>(config: cfg as dynamic, controller: controller, onChanged: onChanged),
  );
  static FormConfig dropdown<T>(DropdownFieldConfig<T> config) => FormConfig(
    type: FormType.dropdown,
    config: config,
    builder: (FormConfig cfg, TextEditingController controller, Function(String) onChanged) => DropdownFieldWidget<T>(config: cfg, controller: controller, onChanged: onChanged),
  );
  static FormConfig upload(UploadFieldConfig config) => FormConfig(type: FormType.upload, config: config);
  static FormConfig treeSelect<T>(TreeSelectFieldConfig<T> config) => FormConfig(
    type: FormType.treeSelect,
    config: config,
    builder: (FormConfig cfg, TextEditingController controller, Function(String) onChanged) => TreeSelectFieldWidget<T>(config: cfg, controller: controller, onChanged: onChanged),
  );
  static FormConfig custom(CustomFieldConfig config) => FormConfig(type: FormType.custom, config: config);
}
