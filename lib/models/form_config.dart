import 'package:flutter/material.dart';
import 'select_data.dart';

/// 表单字段类型枚举
enum FormFieldType { text, number, integer, textarea, radio, checkbox, select, dropdown, date, time, datetime, upload, custom }

/// 单个字段配置
class FormFieldConfig {
  final String name;
  final String? label;
  final FormFieldType type;
  final bool required;
  final dynamic defaultValue;
  final String? placeholder;

  /// 类型专用属性
  final Object? props;

  const FormFieldConfig({required this.name, required this.type, this.label, this.required = false, this.defaultValue, this.placeholder, this.props});

  // 工厂构造，提供更直观的类型化参数
  FormFieldConfig.text({required String name, String? label, String? placeholder, bool required = false, String? defaultValue})
    : this(name: name, type: FormFieldType.text, label: label, placeholder: placeholder, required: required, defaultValue: defaultValue, props: const TextFieldProps());

  FormFieldConfig.number({required String name, String? label, String? placeholder, bool required = false, num? defaultValue, NumberFieldProps props = const NumberFieldProps()})
    : this(name: name, type: FormFieldType.number, label: label, placeholder: placeholder, required: required, defaultValue: defaultValue, props: props);

  FormFieldConfig.integer({required String name, String? label, String? placeholder, bool required = false, int? defaultValue, IntegerFieldProps props = const IntegerFieldProps()})
    : this(name: name, type: FormFieldType.integer, label: label, placeholder: placeholder, required: required, defaultValue: defaultValue, props: props);

  FormFieldConfig.textarea({
    required String name,
    String? label,
    String? placeholder,
    bool required = false,
    String? defaultValue,
    TextareaFieldProps props = const TextareaFieldProps(),
  }) : this(name: name, type: FormFieldType.textarea, label: label, placeholder: placeholder, required: required, defaultValue: defaultValue, props: props);

  FormFieldConfig.select({required String name, String? label, String? placeholder, bool required = false, dynamic defaultValue, SelectFieldProps? props})
    : this(
        name: name,
        type: FormFieldType.select,
        label: label,
        placeholder: placeholder,
        required: required,
        defaultValue: defaultValue,
        props: props ?? SelectFieldProps(options: const <SelectData<dynamic>>[]),
      );

  FormFieldConfig.radio({required String name, String? label, bool required = false, dynamic defaultValue, RadioFieldProps? props})
    : this(
        name: name,
        type: FormFieldType.radio,
        label: label,
        required: required,
        defaultValue: defaultValue,
        props: props ?? RadioFieldProps(options: const <SelectData<dynamic>>[]),
      );

  FormFieldConfig.checkbox({required String name, String? label, bool required = false, List<dynamic>? defaultValue, CheckboxFieldProps? props})
    : this(
        name: name,
        type: FormFieldType.checkbox,
        label: label,
        required: required,
        defaultValue: defaultValue,
        props: props ?? CheckboxFieldProps(options: const <SelectData<dynamic>>[]),
      );

  FormFieldConfig.dropdown({required String name, String? label, bool required = false, dynamic defaultValue, DropdownFieldProps? props})
    : this(
        name: name,
        type: FormFieldType.dropdown,
        label: label,
        required: required,
        defaultValue: defaultValue,
        props: props ?? DropdownFieldProps(options: const <SelectData<dynamic>>[]),
      );

  FormFieldConfig.date({required String name, String? label, String? placeholder, bool required = false, String? defaultValue, DateFieldProps props = const DateFieldProps()})
    : this(name: name, type: FormFieldType.date, label: label, placeholder: placeholder, required: required, defaultValue: defaultValue, props: props);

  FormFieldConfig.time({required String name, String? label, String? placeholder, bool required = false, String? defaultValue, TimeFieldProps props = const TimeFieldProps()})
    : this(name: name, type: FormFieldType.time, label: label, placeholder: placeholder, required: required, defaultValue: defaultValue, props: props);

  FormFieldConfig.datetime({
    required String name,
    String? label,
    String? placeholder,
    bool required = false,
    String? defaultValue,
    DateTimeFieldProps props = const DateTimeFieldProps(),
  }) : this(name: name, type: FormFieldType.datetime, label: label, placeholder: placeholder, required: required, defaultValue: defaultValue, props: props);

  FormFieldConfig.upload({required String name, String? label, bool required = false, UploadFieldProps props = const UploadFieldProps()})
    : this(name: name, type: FormFieldType.upload, label: label, required: required, props: props);

  factory FormFieldConfig.custom({required String name, String? label, bool required = false, CustomFieldProps? props}) {
    assert(props != null, 'Custom type requires CustomFieldProps with contentBuilder');
    return FormFieldConfig(name: name, type: FormFieldType.custom, label: label, required: required, props: props);
  }
}

/// 表单配置
class FormConfig {
  final List<FormFieldConfig> fields;
  final FormUIOptions? uiOptions;
  const FormConfig({required this.fields, this.uiOptions});
}

// 文本（单行），目前无额外属性
class TextFieldProps {
  const TextFieldProps();
}

// 数字（小数）
class NumberFieldProps {
  final num? min;
  final num? max;
  final int? fractionDigits;
  const NumberFieldProps({this.min, this.max, this.fractionDigits});
}

// 整数
class IntegerFieldProps {
  final int? min;
  final int? max;
  const IntegerFieldProps({this.min, this.max});
}

// 多行文本
class TextareaFieldProps {
  final int? maxLines;
  const TextareaFieldProps({this.maxLines});
}

// 单选
class RadioFieldProps {
  final List<SelectData<dynamic>> options;
  const RadioFieldProps({required this.options});
}

// 多选
class CheckboxFieldProps {
  final List<SelectData<dynamic>> options;
  const CheckboxFieldProps({required this.options});
}

// 下拉
class SelectFieldProps {
  final List<SelectData<dynamic>> options;
  const SelectFieldProps({required this.options});
}

// 自定义下拉
class DropdownFieldProps {
  final List<SelectData<dynamic>> options;
  final bool? multiple;
  final bool? filterable;
  final bool? remote;
  final dynamic defaultValue;
  final String? singleTitleText;
  final String? multipleTitleText;
  final String? placeholderText;
  final Future<List<SelectData<dynamic>>> Function(String keyword)? remoteFetch;
  final Function(SelectData<dynamic>)? onSingleSelected;
  final Function(List<SelectData<dynamic>>)? onMultipleSelected;
  final bool? showAdd;
  final void Function(String keyword)? onAdd;
  const DropdownFieldProps({
    required this.options,
    this.multiple,
    this.filterable,
    this.remote,
    this.defaultValue,
    this.remoteFetch,
    this.singleTitleText,
    this.multipleTitleText,
    this.placeholderText,
    this.onSingleSelected,
    this.onMultipleSelected,
    this.showAdd,
    this.onAdd,
  });
}

// 自定义表单项
typedef CustomContentBuilder = Widget Function(BuildContext context, dynamic value, void Function(dynamic newValue) onChanged);

class CustomFieldProps {
  final CustomContentBuilder contentBuilder;
  const CustomFieldProps({required this.contentBuilder});
}

// 日期/时间/日期时间（预留扩展属性）
class DateFieldProps {
  const DateFieldProps();
}

class TimeFieldProps {
  const TimeFieldProps();
}

class DateTimeFieldProps {
  const DateTimeFieldProps();
}

// 上传（简化常用属性）
class UploadFieldProps {
  final String? uploadText;
  final bool? autoUpload;
  final bool? showFileList;
  final Color? backgroundColor;
  // 列表展示类型（卡片/列表等）——保持为 dynamic，避免与组件层产生强耦合
  // 若你希望强类型枚举，可后续将 UploadListType 上移到 models 并替换这里的 dynamic
  final dynamic listType;
  // 其余可选外观/行为参数（与 UploadFile 保持名称对齐）
  final Widget? customUploadArea;
  final double? uploadAreaSize;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final IconData? uploadIcon;
  final double? iconSize;
  final Color? iconColor;
  final TextStyle? textStyle;
  final List<Map<String, dynamic>>? initialFiles;
  final Function(List<Map<String, dynamic>>)? onFilesChanged;
  final Widget Function(Map<String, dynamic>)? customFileItemBuilder;
  final double? fileItemSize;
  final int? limit;
  final dynamic fileSource; // 与组件枚举保持解耦
  final dynamic onFileSelected; // 回调透传
  final dynamic onImageSelected; // 回调透传
  final dynamic uploadConfig; // 上传配置透传
  const UploadFieldProps({
    this.uploadText,
    this.autoUpload,
    this.showFileList,
    this.backgroundColor,
    this.listType,
    this.customUploadArea,
    this.uploadAreaSize,
    this.borderColor,
    this.borderRadius,
    this.uploadIcon,
    this.iconSize,
    this.iconColor,
    this.textStyle,
    this.initialFiles,
    this.onFilesChanged,
    this.customFileItemBuilder,
    this.fileItemSize,
    this.limit,
    this.fileSource,
    this.onFileSelected,
    this.onImageSelected,
    this.uploadConfig,
  });
}

/// 表单级别的UI配置（组件也可传相同配置进行覆盖）
class FormUIOptions {
  final EdgeInsets padding;
  final TextStyle labelStyle;
  final double fieldGap;
  const FormUIOptions({
    this.padding = const EdgeInsets.all(16),
    this.labelStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
    this.fieldGap = 16,
  });
}
