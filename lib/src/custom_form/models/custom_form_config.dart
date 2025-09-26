import 'package:simple_ui/models/form_type.dart';
import 'package:simple_ui/models/validator.dart';

// 表单配置信息
class FormFiledConfig {
  // 表单标签信息
  final String label;
  // 是否必填
  final bool required;
  // 是否显示
  final bool visible;
  // 表单字段属性
  final String prop;
  // 表单字段类型
  final FormType type;
  // 默认值
  final dynamic value;
  // 自定义验证器函数类型
  final FormValidator? validator;
  FormFiledConfig({required this.label, this.required = false, this.visible = true, required this.prop, this.type = FormType.text, this.validator, this.value});
}
