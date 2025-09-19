import 'package:flutter/material.dart';
import 'package:simple_ui/models/select_data.dart';
import 'package:simple_ui/models/file_upload.dart';

/// 表单字段类型枚举
enum FormBuilderType {
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
  // 自定义13
  custom,
}

/// 单选/多选选项数据
class SelectOption {
  final String label;
  final dynamic value;
  const SelectOption({required this.label, required this.value});
}

/// 单个字段配置
class FormBuilderConfig {
  // 字段名称
  final String name;
  // 字段标签
  final String? label;
  // 字段类型
  final FormBuilderType type;
  // 是否必填
  final bool required;
  // 默认值
  final dynamic defaultValue;
  // true 表示保存信息，false 不保存
  final bool isSaveInfo;
  // true 表示显示，false 不显示
  final bool isShow;
  // 类型专用属性
  final Object? props;
  // 占位符文本
  final String? placeholder;
  // 自定义验证器
  final String? Function(dynamic)? validator;
  // 数据改变时的回调函数
  final void Function(String fieldName, dynamic value)? onChange;
  // 值格式化字符串（用于 date、time、datetime 类型）
  final String? valueFormat;
  // 自定义内容构建器（用于 custom 类型）
  final Widget Function(BuildContext context, FormBuilderConfig config, dynamic value, Function(dynamic) onChanged)? contentBuilder;

  FormBuilderConfig({
    required this.name,
    required this.type,
    this.label,
    this.required = false,
    this.defaultValue,
    this.isSaveInfo = true,
    this.props,
    this.isShow = true,
    this.placeholder,
    this.validator,
    this.onChange,
    this.valueFormat,
    this.contentBuilder,
  }) {
    // 验证：如果类型是custom，必须提供contentBuilder
    if (type == FormBuilderType.custom && contentBuilder == null) {
      throw ArgumentError(
        'FormBuilderConfig: 当类型为 FormBuilderType.custom 时，必须提供 contentBuilder 参数。'
        '\n请使用 FormBuilderConfig.custom() 工厂构造方法或确保传递了 contentBuilder 参数。',
      );
    }
  }

  // 工厂构造方法 - 单选
  factory FormBuilderConfig.radio({
    required String name,
    String? label,
    bool required = false,
    dynamic defaultValue,
    List<SelectOption>? options,
    bool isShow = true,
    String? Function(dynamic)? validator,
    void Function(String fieldName, dynamic value)? onChange,
  }) {
    return FormBuilderConfig(
      name: name,
      type: FormBuilderType.radio,
      label: label,
      required: required,
      defaultValue: defaultValue,
      props: options ?? [],
      isShow: isShow,
      validator: validator,
      onChange: onChange,
    );
  }

  // 工厂构造方法 - 多选
  factory FormBuilderConfig.checkbox({
    required String name,
    String? label,
    bool required = false,
    List<dynamic>? defaultValue,
    List<SelectOption>? options,
    bool isShow = true,
    String? Function(dynamic)? validator,
    void Function(String fieldName, dynamic value)? onChange,
  }) {
    return FormBuilderConfig(
      name: name,
      type: FormBuilderType.checkbox,
      label: label,
      required: required,
      defaultValue: defaultValue ?? [],
      props: options ?? [],
      isShow: isShow,
      validator: validator,
      onChange: onChange,
    );
  }

  // 工厂构造方法 - 下拉选择
  factory FormBuilderConfig.select({
    required String name,
    String? label,
    bool required = false,
    dynamic defaultValue,
    List<SelectOption>? options,
    String? placeholder,
    bool isShow = true,
    String? Function(dynamic)? validator,
    void Function(String fieldName, dynamic value)? onChange,
  }) {
    return FormBuilderConfig(
      name: name,
      type: FormBuilderType.select,
      label: label,
      required: required,
      defaultValue: defaultValue,
      props: options ?? [],
      placeholder: placeholder,
      isShow: isShow,
      validator: validator,
      onChange: onChange,
    );
  }

  // 工厂构造方法 - 自定义下拉
  static FormBuilderConfig dropdown<T>({
    required String name,
    String? label,
    bool required = false,
    dynamic defaultValue,
    List<SelectData<T>>? options,
    String? placeholder,
    bool multiple = false,
    bool filterable = false,
    bool remote = false,
    Future<List<SelectData<T>>> Function(String keyword)? remoteFetch,
    Function(SelectData<T>)? onSingleSelected,
    Function(List<SelectData<T>>)? onMultipleSelected,
    bool showAdd = false,
    void Function(String keyword)? onAdd,
    bool isShow = true,
    String? Function(dynamic)? validator,
    void Function(String fieldName, dynamic value)? onChange,
  }) {
    return FormBuilderConfig(
      name: name,
      type: FormBuilderType.dropdown,
      label: label,
      required: required,
      defaultValue: defaultValue,
      props: DropdownProps<T>(
        options: options ?? [],
        multiple: multiple,
        filterable: filterable,
        remote: remote,
        remoteFetch: remoteFetch,
        onSingleSelected: onSingleSelected,
        onMultipleSelected: onMultipleSelected,
        showAdd: showAdd,
        onAdd: onAdd,
      ),
      placeholder: placeholder,
      isShow: isShow,
      validator: validator,
      onChange: onChange,
    );
  }

  // 工厂构造方法 - 文件上传
  factory FormBuilderConfig.upload({
    required String name,
    String? label,
    bool required = false,
    List<FileUploadModel>? defaultValue,
    // FileUpload 组件核心属性
    Widget? customFileList,
    FileListType fileListType = FileListType.card,
    Function(FileUploadModel, List<FileUploadModel>, String)? onFileChange,
    Function(FileUploadModel)? onUploadSuccess,
    Function(FileUploadModel, String)? onUploadFailed,
    Function(FileUploadModel, double)? onUploadProgress,
    FileSource fileSource = FileSource.all,
    int? limit,
    bool showFileList = true,
    bool autoUpload = true,
    bool isRemoveFailFile = false,
    UploadConfig? uploadConfig,

    /// 自定义上传函数
    /// 函数签名: Future<FileUploadModel?> Function(String filePath, Function(double) onProgress)
    /// 参数: filePath - 要上传的文件路径, onProgress - 进度回调函数(0.0-1.0)
    /// 返回: 上传成功时返回FileUploadModel，失败时返回null
    Future<FileUploadModel?> Function(String filePath, Function(double) onProgress)? customUpload,
    Widget? uploadIcon, // 自定义上传区域图标
    Widget? uploadText, // 自定义上传区域文本
    bool isShow = true,
    String? Function(dynamic)? validator,
    void Function(String fieldName, dynamic value)? onChange,
  }) {
    return FormBuilderConfig(
      name: name,
      type: FormBuilderType.upload,
      label: label,
      required: required,
      defaultValue: defaultValue ?? [],
      props: UploadProps(
        customFileList: customFileList,
        fileListType: fileListType,
        onFileChange: onFileChange,
        onUploadSuccess: onUploadSuccess,
        onUploadFailed: onUploadFailed,
        onUploadProgress: onUploadProgress,
        fileSource: fileSource,
        limit: limit,
        showFileList: showFileList,
        autoUpload: autoUpload,
        isRemoveFailFile: isRemoveFailFile,
        uploadConfig: uploadConfig,
        customUpload: customUpload,
        defaultValue: defaultValue,
        uploadIcon: uploadIcon,
        uploadText: uploadText,
      ),
      isShow: isShow,
      validator: validator,
      onChange: onChange,
    );
  }

  // 工厂构造方法 - 日期
  factory FormBuilderConfig.date({
    required String name,
    String? label,
    bool required = false,
    dynamic defaultValue,
    String? placeholder,
    String? valueFormat,
    bool isShow = true,
    String? Function(dynamic)? validator,
    void Function(String fieldName, dynamic value)? onChange,
  }) {
    return FormBuilderConfig(
      name: name,
      type: FormBuilderType.date,
      label: label,
      required: required,
      defaultValue: defaultValue,
      placeholder: placeholder,
      valueFormat: valueFormat,
      isShow: isShow,
      validator: validator,
      onChange: onChange,
    );
  }

  // 工厂构造方法 - 时间
  factory FormBuilderConfig.time({
    required String name,
    String? label,
    bool required = false,
    dynamic defaultValue,
    String? placeholder,
    String? valueFormat,
    bool isShow = true,
    String? Function(dynamic)? validator,
    void Function(String fieldName, dynamic value)? onChange,
  }) {
    return FormBuilderConfig(
      name: name,
      type: FormBuilderType.time,
      label: label,
      required: required,
      defaultValue: defaultValue,
      placeholder: placeholder,
      valueFormat: valueFormat,
      isShow: isShow,
      validator: validator,
      onChange: onChange,
    );
  }

  // 工厂构造方法 - 日期时间
  factory FormBuilderConfig.datetime({
    required String name,
    String? label,
    bool required = false,
    dynamic defaultValue,
    String? placeholder,
    String? valueFormat,
    bool isShow = true,
    String? Function(dynamic)? validator,
    void Function(String fieldName, dynamic value)? onChange,
  }) {
    return FormBuilderConfig(
      name: name,
      type: FormBuilderType.datetime,
      label: label,
      required: required,
      defaultValue: defaultValue,
      placeholder: placeholder,
      valueFormat: valueFormat,
      isShow: isShow,
      validator: validator,
      onChange: onChange,
    );
  }

  // 工厂构造方法 - 自定义
  factory FormBuilderConfig.custom({
    required String name,
    required Widget Function(BuildContext context, FormBuilderConfig config, dynamic value, Function(dynamic) onChanged) contentBuilder,
    String? label,
    bool required = false,
    dynamic defaultValue,
    bool isShow = true,
    String? Function(dynamic)? validator,
    void Function(String fieldName, dynamic value)? onChange,
  }) {
    return FormBuilderConfig(
      name: name,
      type: FormBuilderType.custom,
      label: label,
      required: required,
      defaultValue: defaultValue,
      isShow: isShow,
      validator: validator,
      onChange: onChange,
      contentBuilder: contentBuilder,
    );
  }
}

// 自定义下拉属性
class DropdownProps<T> {
  final List<SelectData<T>> options;
  final bool multiple;
  final bool filterable;
  final bool remote;
  final Future<List<SelectData<T>>> Function(String keyword)? remoteFetch;
  final Function(SelectData<T>)? onSingleSelected;
  final Function(List<SelectData<T>>)? onMultipleSelected;
  final bool showAdd;
  final void Function(String keyword)? onAdd;

  const DropdownProps({
    required this.options,
    this.multiple = false,
    this.filterable = false,
    this.remote = false,
    this.remoteFetch,
    this.onSingleSelected,
    this.onMultipleSelected,
    this.showAdd = false,
    this.onAdd,
  });
}

// 文件上传属性 - 仅包含 FileUpload 组件需要的属性
class UploadProps {
  final Widget? customFileList; // 自定义上传文件列表样式
  final FileListType fileListType; // 上传文件列表类型
  final Function(FileUploadModel, List<FileUploadModel>, String)? onFileChange; // 文件改变回调
  final Function(FileUploadModel)? onUploadSuccess; // 上传成功回调
  final Function(FileUploadModel, String)? onUploadFailed; // 上传失败回调
  final Function(FileUploadModel, double)? onUploadProgress; // 上传进度回调
  final FileSource fileSource; // 文件来源
  final int? limit; // 文件数量限制
  final bool showFileList; // 是否显示文件列表
  final bool autoUpload; // 是否自动上传
  final bool isRemoveFailFile; // 上传失败时是否移除文件
  final UploadConfig? uploadConfig; // 上传配置
  final Future<FileUploadModel?> Function(String filePath, Function(double) onProgress)? customUpload; // 自定义上传函数
  final List<FileUploadModel>? defaultValue; // 默认文件列表
  final Widget? uploadIcon; // 自定义上传区域图标
  final Widget? uploadText; // 自定义上传区域文本

  const UploadProps({
    this.customFileList,
    this.fileListType = FileListType.card,
    this.onFileChange,
    this.onUploadSuccess,
    this.onUploadFailed,
    this.onUploadProgress,
    this.fileSource = FileSource.all,
    this.limit,
    this.showFileList = true,
    this.autoUpload = true,
    this.isRemoveFailFile = false,
    this.uploadConfig,
    this.customUpload,
    this.defaultValue,
    this.uploadIcon,
    this.uploadText,
  });
}
