import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_ui/models/file_info.dart';
import 'package:simple_ui/models/form_builder_config.dart';
import 'package:simple_ui/models/select_data.dart';
import 'package:simple_ui/src/dropdown_choose/index.dart';
import 'package:simple_ui/src/upload_file/index.dart';

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

  void _setValue(String name, dynamic value) {
    _fieldValues[name] = value;
    widget.controller?.setValue(name, value);
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
      widgets.add(_buildField(config));
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

  Widget _buildField(FormBuilderConfig config) {
    switch (config.type) {
      case FormBuilderType.text:
        return _buildTextField(config);
      case FormBuilderType.number:
        return _buildNumberField(config);
      case FormBuilderType.integer:
        return _buildIntegerField(config);
      case FormBuilderType.textarea:
        return _buildTextareaField(config);
      case FormBuilderType.radio:
        return _buildRadioField(config);
      case FormBuilderType.checkbox:
        return _buildCheckboxField(config);
      case FormBuilderType.select:
        return _buildSelectField(config);
      case FormBuilderType.dropdown:
        return _buildDropdownField(config);
      case FormBuilderType.date:
        return _buildDateField(config);
      case FormBuilderType.time:
        return _buildTimeField(config);
      case FormBuilderType.datetime:
        return _buildDateTimeField(config);
      case FormBuilderType.upload:
        return _buildUploadField(config);
      case FormBuilderType.custom:
        return _buildCustomField(config);
    }
  }

  // 文本字段
  Widget _buildTextField(FormBuilderConfig config) {
    return TextFormField(
      controller: _textControllers[config.name],
      decoration: _inputDecoration('请输入${config.label ?? ''}'),
      onChanged: (value) => _setValue(config.name, value),
      validator: (value) {
        if (config.required && (value == null || value.trim().isEmpty)) {
          return '${config.label}必填';
        }
        return null;
      },
    );
  }

  // 数字字段
  Widget _buildNumberField(FormBuilderConfig config) {
    return TextFormField(
      controller: _textControllers[config.name],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        TextInputFormatter.withFunction((oldValue, newValue) {
          final text = newValue.text;
          if (text.isEmpty) return newValue;
          if (!RegExp(r'^[0-9.]*$').hasMatch(text)) return oldValue;
          if ('.'.allMatches(text).length > 1) return oldValue;
          if (text.startsWith('.')) {
            final fixed = '0$text';
            final baseOffset = newValue.selection.baseOffset + 1;
            final extentOffset = newValue.selection.extentOffset + 1;
            return TextEditingValue(
              text: fixed,
              selection: TextSelection(baseOffset: baseOffset, extentOffset: extentOffset),
            );
          }
          return newValue;
        }),
      ],
      decoration: _inputDecoration('可输入小数'),
      onChanged: (value) => _setValue(config.name, value),
      validator: (value) {
        if (config.required && (value == null || value.trim().isEmpty)) {
          return '${config.label}必填';
        }
        return null;
      },
    );
  }

  // 整数字段
  Widget _buildIntegerField(FormBuilderConfig config) {
    return TextFormField(
      controller: _textControllers[config.name],
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: _inputDecoration('请输入${config.label ?? ''}'),
      onChanged: (value) => _setValue(config.name, value),
      validator: (value) {
        if (config.required && (value == null || value.trim().isEmpty)) {
          return '${config.label}必填';
        }
        return null;
      },
    );
  }

  // 多行文本字段
  Widget _buildTextareaField(FormBuilderConfig config) {
    return TextFormField(
      controller: _textControllers[config.name],
      maxLines: 4,
      decoration: _textareaDecoration('请输入${config.label ?? ''}'),
      onChanged: (value) => _setValue(config.name, value),
      validator: (value) {
        if (config.required && (value == null || value.trim().isEmpty)) {
          return '${config.label}必填';
        }
        return null;
      },
    );
  }

  // 单选框字段
  Widget _buildRadioField(FormBuilderConfig config) {
    final List<SelectOption> options = config.props is List<SelectOption> ? config.props as List<SelectOption> : [];

    return FormField<dynamic>(
      validator: (val) {
        if (!config.required) return null;
        final v = _fieldValues[config.name];
        return v == null ? '请选择${config.label}' : null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupContainer(
              Column(
                children: options
                    .map(
                      (option) => InkWell(
                        onTap: () {
                          setState(() => _setValue(config.name, option.value));
                          state.didChange(option.value);
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          children: [
                            Expanded(child: Text(option.label, style: const TextStyle(fontSize: 14))),
                            Radio<dynamic>(
                              value: option.value,
                              groupValue: _fieldValues[config.name],
                              onChanged: (v) {
                                setState(() => _setValue(config.name, v));
                                state.didChange(v);
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(state.errorText ?? '', style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        );
      },
    );
  }

  // 复选框字段
  Widget _buildCheckboxField(FormBuilderConfig config) {
    final List<SelectOption> options = config.props is List<SelectOption> ? config.props as List<SelectOption> : [];
    final List selected = (_fieldValues[config.name] as List?) ?? <dynamic>[];

    return FormField<List<dynamic>>(
      validator: (val) {
        if (!config.required) return null;
        final list = (_fieldValues[config.name] as List?) ?? <dynamic>[];
        return list.isEmpty ? '至少选择一项' : null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupContainer(
              Column(
                children: options
                    .map(
                      (option) => CheckboxListTile(
                        title: Text(option.label, style: const TextStyle(fontSize: 14)),
                        value: selected.contains(option.value),
                        onChanged: (checked) => setState(() {
                          if (checked == true) {
                            if (!selected.contains(option.value)) selected.add(option.value);
                          } else {
                            selected.remove(option.value);
                          }
                          final newList = List.from(selected);
                          _setValue(config.name, newList);
                          state.didChange(newList);
                        }),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                    .toList(),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(state.errorText ?? '', style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        );
      },
    );
  }

  // 下拉选择字段
  Widget _buildSelectField(FormBuilderConfig config) {
    final List<SelectOption> options = config.props is List<SelectOption> ? config.props as List<SelectOption> : [];

    return DropdownButtonFormField<dynamic>(
      value: _fieldValues[config.name],
      items: options.map((option) => DropdownMenuItem(value: option.value, child: Text(option.label))).toList(),
      onChanged: (val) => setState(() => _setValue(config.name, val)),
      decoration: _inputDecoration(config.placeholder ?? '请选择'),
      validator: (val) {
        if (config.required && (val == null || (val is String && val.toString().trim().isEmpty))) {
          return '请选择${config.label}';
        }
        return null;
      },
    );
  }

  // 自定义下拉字段
  Widget _buildDropdownField(FormBuilderConfig config) {
    final DropdownProps? props = config.props is DropdownProps ? config.props as DropdownProps : null;
    if (props == null) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Text('配置错误')),
      );
    }

    // 转换SelectOption为SelectData
    final List<SelectData<dynamic>> selectDataList = props.options.map((option) => SelectData(label: option.label, value: option.value, data: null)).toList();

    // 处理默认值
    dynamic defaultValue;
    if (config.defaultValue != null) {
      if (props.multiple) {
        // 多选模式：defaultValue应该是List<SelectOption>
        if (config.defaultValue is List<SelectOption>) {
          defaultValue = config.defaultValue.map((option) => SelectData(label: option.label, value: option.value, data: null)).toList();
        }
      } else {
        // 单选模式：defaultValue应该是SelectOption
        if (config.defaultValue is SelectOption) {
          defaultValue = SelectData(label: config.defaultValue.label, value: config.defaultValue.value, data: null);
        }
      }
    }

    return FormField<dynamic>(
      validator: (val) {
        if (!config.required) return null;
        if (props.multiple) {
          final list = (_fieldValues[config.name] as List?) ?? <dynamic>[];
          return list.isEmpty ? '至少选择一项' : null;
        }
        return _fieldValues[config.name] == null ? '请选择${config.label}' : null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownChoose<dynamic>(
              list: props.remote ? null : selectDataList,
              remoteFetch: props.remote
                  ? (String? kw) async {
                      if (props.remoteFetch != null) {
                        final options = await props.remoteFetch!(kw ?? '');
                        return options.map((option) => SelectData(label: option.label, value: option.value, data: null)).toList();
                      }
                      return <SelectData<dynamic>>[];
                    }
                  : null,
              multiple: props.multiple,
              filterable: props.filterable,
              remote: props.remote,
              defaultValue: defaultValue,
              singleTitleText: props.multiple ? null : config.placeholder,
              multipleTitleText: props.multiple ? config.placeholder : null,
              placeholderText: config.placeholder ?? '请选择',
              showAdd: props.showAdd,
              onAdd: props.onAdd,
              onSingleSelected: (value) {
                setState(() {
                  _setValue(config.name, value.value);
                });
                state.didChange(value.value);
                props.onSingleSelected?.call(SelectData(label: value.label, value: value.value));
              },
              onMultipleSelected: (values) {
                final list = values.map((e) => e.value).toList();
                setState(() {
                  _setValue(config.name, list);
                });
                state.didChange(list);
                props.onMultipleSelected?.call(values.map((e) => SelectData(label: e.label, value: e.value)).toList());
              },
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(state.errorText ?? '', style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        );
      },
    );
  }

  // 日期字段
  Widget _buildDateField(FormBuilderConfig config) {
    return _buildDateTapContainer(
      placeholder: _fieldValues[config.name]?.toString() ?? '请选择日期',
      hasValue: _fieldValues[config.name] != null,
      icon: Icons.calendar_today,
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(context: context, initialDate: now, firstDate: DateTime(1900), lastDate: DateTime(2100), locale: const Locale('zh', 'CN'));
        if (picked != null) {
          final value = '${picked.year}年${picked.month}月${picked.day}日';
          setState(() {
            _setValue(config.name, value);
          });
        }
      },
    );
  }

  // 时间字段
  Widget _buildTimeField(FormBuilderConfig config) {
    return _buildDateTapContainer(
      placeholder: _fieldValues[config.name]?.toString() ?? '请选择时间',
      hasValue: _fieldValues[config.name] != null,
      icon: Icons.access_time,
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
        if (picked != null) {
          final value = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          setState(() {
            _setValue(config.name, value);
          });
        }
      },
    );
  }

  // 日期时间字段
  Widget _buildDateTimeField(FormBuilderConfig config) {
    return _buildDateTapContainer(
      placeholder: _fieldValues[config.name]?.toString() ?? '请选择日期时间',
      hasValue: _fieldValues[config.name] != null,
      icon: Icons.event,
      onTap: () async {
        final now = DateTime.now();
        final date = await showDatePicker(context: context, initialDate: now, firstDate: DateTime(1900), lastDate: DateTime(2100), locale: const Locale('zh', 'CN'));
        if (date == null) return;
        if (!mounted) return;
        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
        if (time == null) return;
        final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        final value = '${dt.year}年${dt.month}月${dt.day}日 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        setState(() {
          _setValue(config.name, value);
        });
      },
    );
  }

  // 上传字段
  Widget _buildUploadField(FormBuilderConfig config) {
    final UploadProps? props = config.props is UploadProps ? config.props as UploadProps : null;
    if (props == null) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Text('配置错误')),
      );
    }

    // 转换初始文件列表
    List<UploadedFile> initialFiles = [];
    if (props.initialFiles != null) {
      initialFiles = props.initialFiles!.map((file) {
        if (file is UploadedFile) {
          return file;
        } else if (file is Map<String, dynamic>) {
          // 从Map创建UploadedFile
          return UploadedFile(
            fileName: file['fileName'] ?? 'unknown',
            status: UploadStatus.success,
            timestamp: file['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
            fileSize: file['fileSize'] ?? 0,
            filePath: file['filePath'],
            isImage: file['isImage'] ?? false,
            fileUrl: file['fileUrl'],
            data: file['data'],
          );
        }
        return UploadedFile(fileName: file.toString(), status: UploadStatus.success, timestamp: DateTime.now().millisecondsSinceEpoch);
      }).toList();
    }

    // 处理默认值 - 将FileInfo转换为UploadedFile
    List<FileInfo>? defaultFileInfos;
    if (config.defaultValue != null) {
      if (config.defaultValue is List) {
        defaultFileInfos = (config.defaultValue as List).whereType<FileInfo>().toList();
      }
    }

    return FormField<List<dynamic>>(
      validator: (val) {
        if (!config.required) return null;
        final files = (_fieldValues[config.name] as List?) ?? <dynamic>[];
        return files.isEmpty ? '请上传文件' : null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UploadFile(
              listType: props.listType ?? UploadListType.card,
              customUploadArea: props.customUploadArea,
              uploadAreaSize: props.uploadAreaSize,
              borderColor: props.borderColor,
              backgroundColor: props.backgroundColor ?? Colors.grey.shade50,
              borderRadius: props.borderRadius,
              uploadIcon: props.uploadIcon,
              iconSize: props.iconSize,
              iconColor: props.iconColor,
              uploadText: props.uploadText ?? '上传文件',
              textStyle: props.textStyle,
              initialFiles: initialFiles,
              defaultValue: defaultFileInfos, // 传递默认值
              onFilesChanged: (files) {
                setState(() {
                  _setValue(config.name, files);
                });
                state.didChange(files);
                props.onFilesChanged?.call(files);
              },
              showFileList: props.showFileList,
              customFileItemBuilder: props.customFileItemBuilder,
              fileItemSize: props.fileItemSize,
              limit: props.limit ?? -1,
              fileSource: props.fileSource ?? FileSource.all,
              onFileSelected: props.onFileSelected,
              onImageSelected: props.onImageSelected,
              uploadConfig: props.uploadConfig,
              autoUpload: props.autoUpload,
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(state.errorText ?? '', style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        );
      },
    );
  }

  // 自定义字段
  Widget _buildCustomField(FormBuilderConfig config) {
    // 这里需要根据props获取自定义构建器，暂时返回占位
    return Container(
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: Text('自定义组件 (待实现)')),
    );
  }

  // 日期时间选择容器
  Widget _buildDateTapContainer({required String placeholder, required bool hasValue, required IconData icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(placeholder, style: TextStyle(fontSize: 16, color: hasValue ? Colors.black87 : Colors.grey.shade500)),
            ),
            Icon(icon, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // 输入框装饰
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      errorStyle: const TextStyle(color: Colors.red),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // 多行文本装饰
  InputDecoration _textareaDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      errorStyle: const TextStyle(color: Colors.red, fontSize: 12, height: 1.0),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      isDense: true,
      errorMaxLines: 1,
      alignLabelWithHint: true,
    );
  }

  // 组容器装饰
  Widget _buildGroupContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: child,
    );
  }
}
