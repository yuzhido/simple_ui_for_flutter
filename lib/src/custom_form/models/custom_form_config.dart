import 'package:simple_ui/models/form_type.dart';
import 'package:simple_ui/models/validator.dart';

// 基础表单字段属性配置抽象类
abstract class BaseFieldProps {
  const BaseFieldProps();
}

// 文本输入框特定属性配置
class TextFieldProps extends BaseFieldProps {
  // 输入提示文本
  final String? placeholder;
  // 最大字符长度
  final int? maxLength;
  // 最小字符长度
  final int? minLength;
  // 是否只读
  final bool readOnly;
  // 是否启用清除按钮
  final bool showClearButton;

  const TextFieldProps({this.placeholder, this.maxLength, this.minLength, this.readOnly = false, this.showClearButton = true});
}

// 数字输入框特定属性配置
class NumberFieldProps extends BaseFieldProps {
  // 输入提示文本
  final String? placeholder;
  // 最大值
  final double? maxValue;
  // 最小值
  final double? minValue;
  // 小数位数
  final int? decimalPlaces;
  // 是否只读
  final bool readOnly;

  const NumberFieldProps({this.placeholder, this.maxValue, this.minValue, this.decimalPlaces, this.readOnly = false});
}

// 整数输入框特定属性配置
class IntegerFieldProps extends BaseFieldProps {
  // 输入提示文本
  final String? placeholder;
  // 最大值
  final int? maxValue;
  // 最小值
  final int? minValue;
  // 是否只读
  final bool readOnly;

  const IntegerFieldProps({this.placeholder, this.maxValue, this.minValue, this.readOnly = false});
}

// 多行文本输入框特定属性配置
class TextareaFieldProps extends BaseFieldProps {
  // 输入提示文本
  final String? placeholder;
  // 最大字符长度
  final int? maxLength;
  // 最小字符长度
  final int? minLength;
  // 行数
  final int? rows;
  // 最大行数
  final int? maxRows;
  // 是否只读
  final bool readOnly;

  const TextareaFieldProps({this.placeholder, this.maxLength, this.minLength, this.rows = 3, this.maxRows, this.readOnly = false});
}

// 表单配置信息
class FormFiledConfig<T extends BaseFieldProps> {
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
  // 特定组件的属性配置
  final T? props;

  FormFiledConfig({required this.label, this.required = false, this.visible = true, required this.prop, this.type = FormType.text, this.validator, this.value, this.props});

  // 便捷构造方法 - 文本输入框
  static FormFiledConfig<TextFieldProps> text({
    required String label,
    required String prop,
    bool required = false,
    bool visible = true,
    dynamic value,
    FormValidator? validator,
    TextFieldProps? props,
  }) {
    return FormFiledConfig<TextFieldProps>(label: label, prop: prop, type: FormType.text, required: required, visible: visible, value: value, validator: validator, props: props);
  }

  // 便捷构造方法 - 数字输入框
  static FormFiledConfig<NumberFieldProps> number({
    required String label,
    required String prop,
    bool required = false,
    bool visible = true,
    dynamic value,
    FormValidator? validator,
    NumberFieldProps? props,
  }) {
    return FormFiledConfig<NumberFieldProps>(
      label: label,
      prop: prop,
      type: FormType.number,
      required: required,
      visible: visible,
      value: value,
      validator: validator,
      props: props,
    );
  }

  // 便捷构造方法 - 整数输入框
  static FormFiledConfig<IntegerFieldProps> integer({
    required String label,
    required String prop,
    bool required = false,
    bool visible = true,
    dynamic value,
    FormValidator? validator,
    IntegerFieldProps? props,
  }) {
    return FormFiledConfig<IntegerFieldProps>(
      label: label,
      prop: prop,
      type: FormType.integer,
      required: required,
      visible: visible,
      value: value,
      validator: validator,
      props: props,
    );
  }

  // 便捷构造方法 - 多行文本输入框
  static FormFiledConfig<TextareaFieldProps> textarea({
    required String label,
    required String prop,
    bool required = false,
    bool visible = true,
    dynamic value,
    FormValidator? validator,
    TextareaFieldProps? props,
  }) {
    return FormFiledConfig<TextareaFieldProps>(
      label: label,
      prop: prop,
      type: FormType.textarea,
      required: required,
      visible: visible,
      value: value,
      validator: validator,
      props: props,
    );
  }
}
