import 'package:flutter/material.dart';
import 'package:simple_ui/models/select_data.dart';

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

  const FormBuilderConfig({
    required this.name,
    required this.type,
    this.label,
    this.required = false,
    this.defaultValue,
    this.isSaveInfo = true,
    this.props,
    this.isShow = true,
    this.placeholder,
  });

  // 工厂构造方法 - 单选
  factory FormBuilderConfig.radio({required String name, String? label, bool required = false, dynamic defaultValue, List<SelectOption>? options, bool isShow = true}) {
    return FormBuilderConfig(name: name, type: FormBuilderType.radio, label: label, required: required, defaultValue: defaultValue, props: options ?? [], isShow: isShow);
  }

  // 工厂构造方法 - 多选
  factory FormBuilderConfig.checkbox({required String name, String? label, bool required = false, List<dynamic>? defaultValue, List<SelectOption>? options, bool isShow = true}) {
    return FormBuilderConfig(name: name, type: FormBuilderType.checkbox, label: label, required: required, defaultValue: defaultValue ?? [], props: options ?? [], isShow: isShow);
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
    );
  }

  // 工厂构造方法 - 自定义下拉
  factory FormBuilderConfig.dropdown({
    required String name,
    String? label,
    bool required = false,
    dynamic defaultValue,
    List<SelectData>? options,
    String? placeholder,
    bool multiple = false,
    bool filterable = false,
    bool remote = false,
    Future<List<SelectData>> Function(String keyword)? remoteFetch,
    Function(SelectData)? onSingleSelected,
    Function(List<SelectData>)? onMultipleSelected,
    bool showAdd = false,
    void Function(String keyword)? onAdd,
    bool isShow = true,
  }) {
    return FormBuilderConfig(
      name: name,
      type: FormBuilderType.dropdown,
      label: label,
      required: required,
      defaultValue: defaultValue,
      props: DropdownProps(
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
    );
  }

  // 工厂构造方法 - 文件上传
  factory FormBuilderConfig.upload({
    required String name,
    String? label,
    bool required = false,
    List<dynamic>? defaultValue,
    String? uploadText,
    bool autoUpload = false,
    bool showFileList = true,
    Color? backgroundColor,
    dynamic listType,
    Widget? customUploadArea,
    double? uploadAreaSize,
    Color? borderColor,
    BorderRadius? borderRadius,
    IconData? uploadIcon,
    double? iconSize,
    Color? iconColor,
    TextStyle? textStyle,
    List<dynamic>? initialFiles,
    Function(List<dynamic>)? onFilesChanged,
    Widget Function(dynamic)? customFileItemBuilder,
    double? fileItemSize,
    int? limit,
    dynamic fileSource,
    Function(dynamic)? onFileSelected,
    Function(dynamic)? onImageSelected,
    dynamic uploadConfig,
    bool isShow = true,
  }) {
    return FormBuilderConfig(
      name: name,
      type: FormBuilderType.upload,
      label: label,
      required: required,
      defaultValue: defaultValue ?? [],
      props: UploadProps(
        uploadText: uploadText,
        autoUpload: autoUpload,
        showFileList: showFileList,
        backgroundColor: backgroundColor,
        listType: listType,
        customUploadArea: customUploadArea,
        uploadAreaSize: uploadAreaSize,
        borderColor: borderColor,
        borderRadius: borderRadius,
        uploadIcon: uploadIcon,
        iconSize: iconSize,
        iconColor: iconColor,
        textStyle: textStyle,
        initialFiles: initialFiles,
        onFilesChanged: onFilesChanged,
        customFileItemBuilder: customFileItemBuilder,
        fileItemSize: fileItemSize,
        limit: limit,
        fileSource: fileSource,
        onFileSelected: onFileSelected,
        onImageSelected: onImageSelected,
        uploadConfig: uploadConfig,
      ),
      isShow: isShow,
    );
  }
}

// 自定义下拉属性
class DropdownProps {
  final List<SelectData> options;
  final bool multiple;
  final bool filterable;
  final bool remote;
  final Future<List<SelectData>> Function(String keyword)? remoteFetch;
  final Function(SelectData)? onSingleSelected;
  final Function(List<SelectData>)? onMultipleSelected;
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

// 文件上传属性
class UploadProps {
  final String? uploadText;
  final bool autoUpload;
  final bool showFileList;
  final Color? backgroundColor;
  final dynamic listType;
  final Widget? customUploadArea;
  final double? uploadAreaSize;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final IconData? uploadIcon;
  final double? iconSize;
  final Color? iconColor;
  final TextStyle? textStyle;
  final List<dynamic>? initialFiles;
  final Function(List<dynamic>)? onFilesChanged;
  final Widget Function(dynamic)? customFileItemBuilder;
  final double? fileItemSize;
  final int? limit;
  final dynamic fileSource;
  final Function(dynamic)? onFileSelected;
  final Function(dynamic)? onImageSelected;
  final dynamic uploadConfig;

  const UploadProps({
    this.uploadText,
    this.autoUpload = false,
    this.showFileList = true,
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
