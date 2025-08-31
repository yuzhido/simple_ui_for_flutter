import 'select_data.dart';

/// 表单字段类型枚举
enum FormFieldType {
  text,
  number, // 整数
  integer, // 整数
  double, // 小数
  textarea,
  radio,
  checkbox,
  select,
  button,
  dropdown,
  switch_,
  date,
  time,
  slider,
  upload, // 新增：文件上传类型
}

/// 表单字段配置模型
class FormFieldConfig {
  /// 字段标签
  final String label;

  /// 字段名称（用于数据绑定）
  final String name;

  /// 字段类型
  final FormFieldType type;

  /// 是否必填
  final bool required;

  /// 选项列表（用于radio、checkbox、select类型）
  final List<SelectData<dynamic>>? options;

  /// 占位符文本
  final String? placeholder;

  /// 默认值
  final dynamic defaultValue;

  /// 验证规则
  final String? validationRule;

  /// 是否禁用
  final bool disabled;

  /// 远程数据获取函数（用于select类型）
  final Future<List<SelectData<dynamic>>> Function(String? keyword)? remoteFetch;

  /// 是否支持多选（用于select类型）
  final bool multiple;

  /// 是否可搜索（用于select类型）
  final bool filterable;

  /// 是否远程搜索（用于select类型）
  final bool remote;

  const FormFieldConfig({
    required this.label,
    required this.name,
    required this.type,
    this.required = false,
    this.options,
    this.placeholder,
    this.defaultValue,
    this.validationRule,
    this.disabled = false,
    this.remoteFetch,
    this.multiple = false,
    this.filterable = false,
    this.remote = false,
  });

  /// 从Map创建FormFieldConfig
  factory FormFieldConfig.fromMap(Map<String, dynamic> map) {
    return FormFieldConfig(
      label: map['label'] as String,
      name: map['name'] as String,
      type: _parseFieldType(map['type'] as String),
      required: map['required'] as bool? ?? false,
      options: map['options'] != null ? List<SelectData<dynamic>>.from(map['options']) : null,
      placeholder: map['placeholder'] as String?,
      defaultValue: map['defaultValue'],
      validationRule: map['validationRule'] as String?,
      disabled: map['disabled'] as bool? ?? false,
      remoteFetch: map['remoteFetch'] as Future<List<SelectData<dynamic>>> Function(String? keyword)?,
      multiple: map['multiple'] as bool? ?? false,
      filterable: map['filterable'] as bool? ?? false,
      remote: map['remote'] as bool? ?? false,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'name': name,
      'type': type.name,
      'required': required,
      'options': options,
      'placeholder': placeholder,
      'defaultValue': defaultValue,
      'validationRule': validationRule,
      'disabled': disabled,
      'remoteFetch': remoteFetch,
      'multiple': multiple,
      'filterable': filterable,
      'remote': remote,
    };
  }

  /// 解析字段类型
  static FormFieldType _parseFieldType(String type) {
    switch (type.toLowerCase()) {
      case 'text':
        return FormFieldType.text;
      case 'integer':
        return FormFieldType.integer;
      case 'number':
        return FormFieldType.integer;
      case 'double':
        return FormFieldType.double;
      case 'textarea':
        return FormFieldType.textarea;
      case 'radio':
        return FormFieldType.radio;
      case 'checkbox':
        return FormFieldType.checkbox;
      case 'select':
        return FormFieldType.select;
      case 'button':
        return FormFieldType.button;
      default:
        throw ArgumentError('不支持的字段类型: $type');
    }
  }

  /// 检查是否需要选项
  bool get needsOptions {
    return type == FormFieldType.radio || type == FormFieldType.checkbox || type == FormFieldType.select;
  }

  /// 验证配置是否有效
  bool get isValid {
    if (label.isEmpty || name.isEmpty) return false;
    if (needsOptions && (options == null || options!.isEmpty)) return false;
    return true;
  }

  @override
  String toString() {
    return 'FormFieldConfig(label: $label, name: $name, type: $type, required: $required)';
  }
}

/// 表单配置模型
class FormConfig {
  /// 表单字段配置列表
  final List<FormFieldConfig> fields;

  /// 表单标题
  final String? title;

  /// 表单描述
  final String? description;

  /// 提交按钮文本
  final String submitButtonText;

  const FormConfig({required this.fields, this.title, this.description, this.submitButtonText = '提交'});

  /// 从Map列表创建FormConfig
  factory FormConfig.fromMapList(List<Map<String, dynamic>> mapList) {
    final fields = mapList.map((map) => FormFieldConfig.fromMap(map)).toList();
    return FormConfig(fields: fields);
  }

  /// 从Map创建FormConfig
  factory FormConfig.fromMap(Map<String, dynamic> map) {
    final fieldsList = map['fields'] as List<dynamic>;
    final fields = fieldsList.map((field) => FormFieldConfig.fromMap(field as Map<String, dynamic>)).toList();

    return FormConfig(fields: fields, title: map['title'] as String?, description: map['description'] as String?, submitButtonText: map['submitButtonText'] as String? ?? '提交');
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {'fields': fields.map((field) => field.toMap()).toList(), 'title': title, 'description': description, 'submitButtonText': submitButtonText};
  }

  /// 验证配置是否有效
  bool get isValid {
    return fields.isNotEmpty && fields.every((field) => field.isValid);
  }

  @override
  String toString() {
    return 'FormConfig(fields: $fields, title: $title)';
  }
}
