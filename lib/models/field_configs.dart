import 'package:simple_ui/models/select_data.dart';
import 'package:simple_ui/models/file_upload.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_ui/models/validator.dart';

/// 基础字段配置
abstract class BaseFieldConfig<T> {
  final String name;
  final String label;
  final bool required;
  final dynamic defaultValue;
  final FormValidator? validator;
  final bool isShow;

  const BaseFieldConfig({required this.name, required this.label, this.required = false, this.defaultValue, this.validator, this.isShow = true});
}

/// 文本字段配置
class TextFieldConfig extends BaseFieldConfig {
  final int? minLength;
  final int? maxLength;
  final void Function(String val)? onChanged;
  const TextFieldConfig({
    required super.name,
    required super.label,
    super.required = false,
    super.defaultValue,
    super.validator,
    super.isShow = true,
    this.minLength,
    this.maxLength,
    this.onChanged,
  });
}

/// 多行文本字段配置
class TextareaFieldConfig extends BaseFieldConfig {
  final int? minLength;
  final int? maxLength;
  final int? rows;
  final void Function(String val)? onChanged;

  const TextareaFieldConfig({
    required super.name,
    required super.label,
    super.required = false,
    super.defaultValue,
    super.validator,
    super.isShow = true,
    this.minLength,
    this.maxLength,
    this.rows = 4,
    this.onChanged,
  });
}

/// 数字字段配置
class NumberFieldConfig extends BaseFieldConfig {
  final double? minValue;
  final double? maxValue;
  final int? decimalPlaces;
  final void Function(String val)? onChanged;

  const NumberFieldConfig({
    required super.name,
    required super.label,
    super.required = false,
    super.defaultValue,
    super.validator,
    super.isShow = true,
    this.minValue,
    this.maxValue,
    this.decimalPlaces,
    this.onChanged,
  });
}

/// 整数字段配置
class IntegerFieldConfig extends BaseFieldConfig {
  final int? minValue;
  final int? maxValue;
  final void Function(String val)? onChanged;

  const IntegerFieldConfig({
    required super.name,
    required super.label,
    super.required = false,
    super.defaultValue,
    super.validator,
    super.isShow = true,
    this.minValue,
    this.maxValue,
    this.onChanged,
  });
}

/// 日期字段配置
class DateFieldConfig extends BaseFieldConfig {
  final DateTime? minDate;
  final DateTime? maxDate;
  final String? format;
  final void Function(String val)? onChanged;

  const DateFieldConfig({
    required super.name,
    required super.label,
    super.required = false,
    super.defaultValue,
    super.validator,
    super.isShow = true,
    this.minDate,
    this.maxDate,
    this.format = 'YYYY-MM-DD',
    this.onChanged,
  });
}

/// 时间字段配置
class TimeFieldConfig extends BaseFieldConfig {
  final String? format;
  final void Function(String val)? onChanged;

  const TimeFieldConfig({
    required super.name,
    required super.label,
    super.required = false,
    super.defaultValue,
    super.validator,
    super.isShow = true,
    this.format = 'HH:mm',
    this.onChanged,
  });
}

/// 日期时间字段配置
class DateTimeFieldConfig extends BaseFieldConfig {
  final DateTime? minDate;
  final DateTime? maxDate;
  final String? format;
  final void Function(String val)? onChanged;

  const DateTimeFieldConfig({
    required super.name,
    required super.label,
    super.required = false,
    super.defaultValue,
    super.validator,
    super.isShow = true,
    this.minDate,
    this.maxDate,
    this.format = 'YYYY-MM-DD HH:mm',
    this.onChanged,
  });
}

/// 单选字段配置
class RadioFieldConfig<T> extends BaseFieldConfig {
  final List<SelectData<T>> options;
  // 单选回调 - 参数: (选中的value值, 选中的data值, 选中的完整数据)
  final void Function(dynamic, T, SelectData<T>)? onChanged;

  const RadioFieldConfig({
    required super.name,
    required super.label,
    super.required = false,
    super.defaultValue,
    super.validator,
    super.isShow = true,
    required this.options,
    this.onChanged,
  });
}

/// 多选字段配置
class CheckboxFieldConfig<T> extends BaseFieldConfig {
  final List<SelectData<T>> options;
  // 多选回调 - 参数: (选中的value值列表, 选中的data值列表, 选中的完整数据列表)
  final void Function(List<dynamic>, List<T>, List<SelectData<T>>)? onChanged;

  const CheckboxFieldConfig({
    required super.name,
    required super.label,
    super.required = false,
    super.defaultValue,
    super.validator,
    super.isShow = true,
    required this.options,
    this.onChanged,
  });
}

/// 下拉选择字段配置
class SelectFieldConfig<T> extends BaseFieldConfig {
  final List<SelectData<T>> options;
  final bool multiple;
  final bool searchable;
  // 单选回调 - 参数: (选中的value值, 选中的data值, 选中的完整数据)
  final void Function(dynamic, T, SelectData<T>)? onSingleChanged;
  // 多选回调 - 参数: (选中的value值列表, 选中的data值列表, 选中的完整数据列表)
  final void Function(List<dynamic>, List<T>, List<SelectData<T>>)? onMultipleChanged;

  const SelectFieldConfig({
    required super.name,
    required super.label,
    super.required = false,
    super.defaultValue,
    super.validator,
    super.isShow = true,
    required this.options,
    this.multiple = false,
    this.searchable = false,
    this.onSingleChanged,
    this.onMultipleChanged,
  });
}

/// 自定义下拉选择字段配置（基于 DropdownChoose）
class DropdownFieldConfig<T> extends BaseFieldConfig {
  // 选项（本地）
  final List<SelectData<T>> options;
  // 是否多选
  final bool multiple;
  // 是否可过滤（本地）
  final bool filterable;
  // 是否远程搜索
  final bool remote;
  // 是否总是刷新数据（仅在remote为true时有效）
  final bool alwaysRefresh;
  // 远程搜索函数
  final Future<List<SelectData<T>>> Function(String)? remoteSearch;
  // 是否显示新增按钮
  final bool showAdd;
  // 新增回调
  final void Function(String)? onAdd;
  // 占位提示
  final String tips;
  // 单选回调
  final void Function(dynamic, T, SelectData<T>)? onSingleChanged;
  // 多选回调
  final void Function(List<dynamic>, List<T>, List<SelectData<T>>)? onMultipleChanged;

  const DropdownFieldConfig({
    required super.name,
    required super.label,
    super.required = false,
    super.defaultValue,
    super.validator,
    super.isShow = true,
    this.options = const [],
    this.multiple = false,
    this.alwaysRefresh = false,
    this.filterable = false,
    this.remote = false,
    this.remoteSearch,
    this.showAdd = false,
    this.onAdd,
    this.tips = '',
    this.onSingleChanged,
    this.onMultipleChanged,
  });
}

/// 文件上传字段配置
class UploadFieldConfig extends BaseFieldConfig {
  final List<String>? allowedTypes;
  final int? maxFileSize;
  final int? maxFiles;
  final String? uploadUrl;
  // 上传行为与展示
  final FileListType fileListType;
  final FileSource fileSource;
  final bool autoUpload;
  final bool isRemoveFailFile;
  // 自定义上传
  final Future<FileUploadModel?> Function(String filePath, Function(double) onProgress)? customUpload;

  /// 参数3: 操作类型 ('add' 或 'remove')
  final Function(FileUploadModel currentFile, List<FileUploadModel> selectedFiles, String action)? onFileChange;

  const UploadFieldConfig({
    required super.name,
    required super.label,
    super.required = false,
    super.defaultValue,
    super.validator,
    super.isShow = true,
    this.allowedTypes,
    this.maxFileSize,
    this.maxFiles = -1,
    this.uploadUrl,
    this.fileListType = FileListType.card,
    this.fileSource = FileSource.all,
    this.autoUpload = true,
    this.isRemoveFailFile = false,
    this.customUpload,
    this.onFileChange,
  });
}

/// 树选择字段配置
class TreeSelectFieldConfig<T> extends BaseFieldConfig {
  final List<SelectData<T>> options;
  final bool multiple;
  final bool checkable;
  // 顶部title
  final String title;
  // 顶部提示
  final String hintText;
  // 单选模式回调 - 参数: (选中的value值, 选中的data值, 选中的完整数据)
  final void Function(dynamic, T, SelectData<T>)? onSingleChanged;
  // 多选模式回调 - 参数: (选中的value值列表, 选中的data值列表, 选中的完整数据列表)
  final void Function(List<dynamic>, List<T>, List<SelectData<T>>)? onMultipleChanged;
  // 远程搜索
  final Future<List<SelectData<T>>> Function(String)? remoteFetch;
  // 是否开启远程搜索
  final bool remote;
  // 是否可过滤
  final bool filterable;
  // 是否懒加载
  final bool lazyLoad;
  // 懒加载函数 - 传入父节点，返回子节点列表
  final Future<List<SelectData<T>>> Function(SelectData<T>)? lazyLoadFetch;
  // 是否缓存数据
  final bool isCacheData;

  const TreeSelectFieldConfig({
    required super.name,
    required super.label,
    required this.options,
    super.required = false,
    super.defaultValue,
    super.validator,
    super.isShow = true,
    this.multiple = false,
    this.checkable = false,
    this.title = '树形选择器',
    this.hintText = '请输入关键字搜索',
    this.onSingleChanged,
    this.onMultipleChanged,
    this.remoteFetch,
    this.remote = false,
    this.filterable = false,
    this.lazyLoad = false,
    this.lazyLoadFetch,
    this.isCacheData = true,
  });
}

/// 第一个参数将会在运行时传入 FormConfig（或兼容对象），以便在回调中可获取验证器等能力
typedef ContentBuilder = Widget Function(dynamic config, TextEditingController controller, Function(String) onChanged);

/// 自定义字段配置：要求提供 contentBuilder
class CustomFieldConfig extends BaseFieldConfig {
  final ContentBuilder contentBuilder;
  const CustomFieldConfig({
    required super.name,
    required super.label,
    super.required = false,
    super.defaultValue,
    super.validator,
    super.isShow = true,
    required this.contentBuilder,
  });
}
