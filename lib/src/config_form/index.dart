import 'package:flutter/material.dart';
import 'package:simple_ui/models/index.dart';
import 'package:flutter/services.dart';
import 'package:simple_ui/src/dropdown_choose/index.dart';
import 'package:simple_ui/src/upload_file/index.dart';

class ConfigFormController extends ChangeNotifier {
  final Map<String, dynamic> _values = {};
  Map<String, dynamic> get values => Map.unmodifiable(_values);

  void _setAll(Map<String, dynamic> source) {
    _values
      ..clear()
      ..addAll(source);
    notifyListeners();
  }

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
  void reset(FormConfig formConfig) {
    _values.clear();
    for (final field in formConfig.fields) {
      if (field.isSaveInfo && field.defaultValue != null) {
        _values[field.name] = field.defaultValue;
      }
    }
    notifyListeners();
  }
}

class ConfigForm extends StatefulWidget {
  final FormConfig formConfig;
  final EdgeInsets? padding;
  final TextStyle? labelStyle;
  final double? fieldGap;
  final GlobalKey<FormState>? formKey;
  final ConfigFormController? controller;
  const ConfigForm({super.key, required this.formConfig, this.padding, this.labelStyle, this.fieldGap, this.formKey, this.controller});
  @override
  State<ConfigForm> createState() => _ConfigFormState();
}

class _ConfigFormState extends State<ConfigForm> {
  // 基础静态状态（仅用于演示UI，不实现真实交互与校验）
  // 仅保留动态表单所需的最小状态
  final FocusNode _unfocusNode = FocusNode(debugLabel: 'unfocus-holder');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _cfgControllers = {};
  final Map<String, dynamic> _cfgValues = {};

  @override
  void initState() {
    super.initState();
    _initConfigControllers();
    // 监听控制器的变化
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    for (final c in _cfgControllers.values) {
      c.dispose();
    }
    // 移除监听器
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    // 当控制器值发生变化时，同步到本地状态
    if (widget.controller != null) {
      final controllerValues = widget.controller!.values;
      bool hasChanges = false;

      for (final entry in controllerValues.entries) {
        if (_cfgValues[entry.key] != entry.value) {
          _cfgValues[entry.key] = entry.value;
          // 同步到对应的 TextEditingController
          if (_cfgControllers.containsKey(entry.key)) {
            _cfgControllers[entry.key]?.text = entry.value?.toString() ?? '';
          }
          hasChanges = true;
        }
      }

      if (hasChanges) {
        setState(() {});
      }
    }
  }

  void _initConfigControllers() {
    final cfg = widget.formConfig;
    for (final field in cfg.fields) {
      // 当 isShow 为 false 时不参与初始化及渲染
      if (field.isShow == false) {
        continue;
      }
      // 如果不需要保存信息，跳过值存储
      if (!field.isSaveInfo) {
        continue;
      }

      switch (field.type) {
        case FormFieldType.text:
        case FormFieldType.number:
        case FormFieldType.integer:
        case FormFieldType.textarea:
          final controller = TextEditingController(text: field.defaultValue?.toString());
          _cfgControllers[field.name] = controller;
          _cfgValues[field.name] = field.defaultValue;
          break;
        default:
          _cfgValues[field.name] = field.defaultValue;
      }
    }
    _syncController();
  }

  void _syncController() {
    widget.controller?._setAll(_cfgValues);
  }

  void _setValue(String name, dynamic value, {bool forceSave = false}) {
    // 查找对应的字段配置
    final field = widget.formConfig.fields.firstWhere((f) => f.name == name, orElse: () => throw Exception('Field with name "$name" not found'));

    // 如果不需要保存信息且不是强制保存，则跳过
    if (!field.isSaveInfo && !forceSave) {
      return;
    }

    _cfgValues[name] = value;
    _syncController();
  }

  List<Widget> _buildDynamicFromConfig(FormConfig cfg) {
    final widgets = <Widget>[];
    for (final field in cfg.fields) {
      // isShow 为 false 则不渲染
      if (field.isShow == false) {
        continue;
      }
      // label 区域：
      // - 非 custom 类型：始终显示（为空时提示“请配置label”）
      // - custom 类型：仅当 label 非空时显示
      final isCustom = field.type == FormFieldType.custom;
      final hasLabel = field.label != null && field.label!.trim().isNotEmpty;
      final shouldShowLabel = !isCustom || (isCustom && hasLabel);
      if (shouldShowLabel) {
        final labelText = hasLabel ? field.label! : '请配置label';
        widgets.add(_buildLabel(labelText, isRequired: field.required));
        widgets.add(const SizedBox(height: 8));
      }
      switch (field.type) {
        case FormFieldType.text:
          widgets.add(
            TextFormField(
              controller: _cfgControllers[field.name],
              decoration: _inputDecoration(field.placeholder ?? '请输入'),
              onChanged: (v) => _setValue(field.name, v),
              validator: (v) {
                if (field.required && (v == null || v.trim().isEmpty)) return '${field.label}必填';
                return null;
              },
            ),
          );
          break;
        case FormFieldType.number:
          widgets.add(
            TextFormField(
              controller: _cfgControllers[field.name],
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
              decoration: _inputDecoration(field.placeholder ?? '可输入小数'),
              onChanged: (v) => _setValue(field.name, v),
              validator: (v) {
                if (field.required && (v == null || v.trim().isEmpty)) return '${field.label}必填';
                return null;
              },
            ),
          );
          break;
        case FormFieldType.integer:
          widgets.add(
            TextFormField(
              controller: _cfgControllers[field.name],
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration(field.placeholder ?? '仅展示整数输入框'),
              onChanged: (v) => _setValue(field.name, v),
              validator: (v) {
                if (field.required && (v == null || v.trim().isEmpty)) return '${field.label}必填';
                return null;
              },
            ),
          );
          break;
        case FormFieldType.textarea:
          final p = field.props is TextareaFieldProps ? field.props as TextareaFieldProps : null;
          widgets.add(
            TextFormField(
              controller: _cfgControllers[field.name],
              maxLines: p?.maxLines ?? 4,
              decoration: _textareaDecoration(field.placeholder ?? '请输入'),
              onChanged: (v) => _setValue(field.name, v),
              validator: (v) {
                if (field.required && (v == null || v.trim().isEmpty)) return '${field.label}必填';
                return null;
              },
            ),
          );
          break;
        case FormFieldType.select:
          final List<SelectData<dynamic>> opts = field.props is SelectFieldProps ? (field.props as SelectFieldProps).options : const <SelectData<dynamic>>[];
          widgets.add(
            DropdownButtonFormField<dynamic>(
              value: _cfgValues[field.name],
              items: opts.map((o) => DropdownMenuItem(value: o.value, child: Text(o.label))).toList(),
              onChanged: (val) => setState(() => _setValue(field.name, val)),
              decoration: _inputDecoration(field.placeholder ?? '请选择'),
              validator: (val) {
                if (field.required && (val == null || (val is String && val.toString().trim().isEmpty))) return '请选择${field.label}';
                return null;
              },
            ),
          );
          break;
        case FormFieldType.radio:
          final List<SelectData<dynamic>> opts = field.props is RadioFieldProps ? (field.props as RadioFieldProps).options : const <SelectData<dynamic>>[];
          widgets.add(
            FormField<dynamic>(
              validator: (val) {
                if (!field.required) return null;
                final v = _cfgValues[field.name];
                return v == null ? '请选择${field.label}' : null;
              },
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGroupContainer(
                      Column(
                        children: [
                          ...opts.map(
                            (o) => InkWell(
                              onTap: () {
                                setState(() => _setValue(field.name, o.value));
                                state.didChange(o.value);
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Row(
                                children: [
                                  Expanded(child: Text(o.label, style: const TextStyle(fontSize: 14))),
                                  Radio<dynamic>(
                                    value: o.value,
                                    groupValue: _cfgValues[field.name],
                                    onChanged: (v) {
                                      setState(() => _setValue(field.name, v));
                                      state.didChange(v);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
            ),
          );
          break;
        case FormFieldType.checkbox:
          final List selected = (_cfgValues[field.name] as List?) ?? <dynamic>[];
          final List<SelectData<dynamic>> opts = field.props is CheckboxFieldProps ? (field.props as CheckboxFieldProps).options : const <SelectData<dynamic>>[];
          widgets.add(
            FormField<List<dynamic>>(
              validator: (val) {
                if (!field.required) return null;
                final list = (_cfgValues[field.name] as List?) ?? <dynamic>[];
                return list.isEmpty ? '至少选择一项' : null;
              },
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGroupContainer(
                      Column(
                        children: opts
                            .map(
                              (o) => CheckboxListTile(
                                title: Text(o.label, style: const TextStyle(fontSize: 14)),
                                value: selected.contains(o.value),
                                onChanged: (checked) => setState(() {
                                  if (checked == true) {
                                    if (!selected.contains(o.value)) selected.add(o.value);
                                  } else {
                                    selected.remove(o.value);
                                  }
                                  final newList = List.from(selected);
                                  _setValue(field.name, newList);
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
            ),
          );
          break;
        case FormFieldType.dropdown:
          final p = field.props is DropdownFieldProps ? field.props as DropdownFieldProps : null;
          final List<SelectData<dynamic>> opts = p?.options ?? const <SelectData<dynamic>>[];
          final bool multiple = p?.multiple ?? false;
          final bool filterable = p?.filterable ?? false;
          final bool remote = p?.remote ?? false;
          final dynamic defaultValue = p?.defaultValue;
          widgets.add(
            FormField<dynamic>(
              validator: (val) {
                if (!field.required) return null;
                final v = _cfgValues[field.name];
                if (multiple) {
                  return (v is List && v.isNotEmpty) ? null : '至少选择一项';
                }
                return v == null ? '请选择${field.label}' : null;
              },
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownChoose<dynamic>(
                      list: remote ? null : opts,
                      remoteFetch: remote ? (p?.remoteFetch == null ? null : (String? kw) => p!.remoteFetch!(kw ?? '')) : null,
                      multiple: multiple,
                      filterable: filterable,
                      remote: remote,
                      defaultValue: defaultValue,
                      showAdd: p?.showAdd ?? false,
                      onAdd: p?.onAdd,
                      onSingleSelected: (value) {
                        setState(() {
                          _setValue(field.name, value.value);
                        });
                        state.didChange(value.value);
                        if (p?.onSingleSelected != null) {
                          p!.onSingleSelected!(value);
                        }
                      },
                      onMultipleSelected: (values) {
                        final list = values.map((e) => e.value).toList();
                        setState(() {
                          _setValue(field.name, list);
                        });
                        state.didChange(list);
                        if (p?.onMultipleSelected != null) {
                          p!.onMultipleSelected!(values);
                        }
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
            ),
          );
          break;
        case FormFieldType.date:
          widgets.add(
            FormField<String>(
              validator: (val) {
                if (field.required && (_cfgValues[field.name] == null || (_cfgValues[field.name].toString().trim().isEmpty))) return '请选择${field.label}';
                return null;
              },
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTapContainer(
                      placeholder: _cfgValues[field.name] == null ? (field.placeholder ?? '请选择日期') : _cfgValues[field.name].toString(),
                      icon: Icons.calendar_today,
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(context: context, initialDate: now, firstDate: DateTime(1900), lastDate: DateTime(2100));
                        if (picked != null) {
                          final v = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                          setState(() {
                            _setValue(field.name, v);
                          });
                          state.didChange(v);
                        }
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
            ),
          );
          break;
        case FormFieldType.time:
          widgets.add(
            FormField<String>(
              validator: (val) {
                if (field.required && (_cfgValues[field.name] == null || (_cfgValues[field.name].toString().trim().isEmpty))) return '请选择${field.label}';
                return null;
              },
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTapContainer(
                      placeholder: _cfgValues[field.name] == null ? (field.placeholder ?? '请选择时间') : _cfgValues[field.name].toString(),
                      icon: Icons.access_time,
                      onTap: () async {
                        final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (picked != null) {
                          final v = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                          setState(() {
                            _setValue(field.name, v);
                          });
                          state.didChange(v);
                        }
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
            ),
          );
          break;
        case FormFieldType.datetime:
          widgets.add(
            FormField<String>(
              validator: (val) {
                if (field.required && (_cfgValues[field.name] == null || (_cfgValues[field.name].toString().trim().isEmpty))) return '请选择${field.label}';
                return null;
              },
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTapContainer(
                      placeholder: _cfgValues[field.name] == null ? (field.placeholder ?? '请选择日期时间') : _cfgValues[field.name].toString(),
                      icon: Icons.event,
                      onTap: () async {
                        final now = DateTime.now();
                        final date = await showDatePicker(context: context, initialDate: now, firstDate: DateTime(1900), lastDate: DateTime(2100));
                        if (date == null) return;
                        if (!mounted) return;
                        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (time == null) return;
                        final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                        final v =
                            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                        setState(() {
                          _setValue(field.name, v);
                        });
                        state.didChange(v);
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
            ),
          );
          break;
        case FormFieldType.upload:
          final p = field.props is UploadFieldProps ? field.props as UploadFieldProps : null;
          widgets.add(
            FormField<List<UploadedFile>>(
              validator: (val) {
                if (!field.required) return null;
                final files = (_cfgValues[field.name] as List<UploadedFile>?) ?? const <UploadedFile>[];
                return files.isEmpty ? '请上传文件' : null;
              },
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UploadFile(
                      listType: (p?.listType is UploadListType) ? p?.listType as UploadListType : UploadListType.card,
                      customUploadArea: p?.customUploadArea,
                      uploadAreaSize: p?.uploadAreaSize,
                      borderColor: p?.borderColor,
                      backgroundColor: p?.backgroundColor ?? Colors.grey.shade50,
                      borderRadius: p?.borderRadius,
                      uploadIcon: p?.uploadIcon,
                      iconSize: p?.iconSize,
                      iconColor: p?.iconColor,
                      uploadText: p?.uploadText ?? '上传文件',
                      textStyle: p?.textStyle,
                      initialFiles: p?.initialFiles ?? const [],
                      onFilesChanged: (files) {
                        setState(() {
                          _setValue(field.name, files);
                        });
                        state.didChange(files);
                        if (p?.onFilesChanged != null) {
                          p!.onFilesChanged!(files);
                        }
                      },
                      showFileList: p?.showFileList ?? true,
                      customFileItemBuilder: p?.customFileItemBuilder,
                      fileItemSize: p?.fileItemSize,
                      limit: p?.limit ?? -1,
                      fileSource: p?.fileSource ?? FileSource.all,
                      onFileSelected: p?.onFileSelected,
                      onImageSelected: p?.onImageSelected,
                      uploadConfig: p?.uploadConfig,
                      autoUpload: p?.autoUpload ?? false,
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(state.errorText ?? '', style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                  ],
                );
              },
            ),
          );
          break;
        case FormFieldType.custom:
          final p = field.props is CustomFieldProps ? field.props as CustomFieldProps : null;
          assert(p != null, 'Custom type requires CustomFieldProps with contentBuilder');
          if (p == null) break;

          // 如果有自定义校验器，使用 FormField 包装以支持校验
          if (p.validator != null) {
            widgets.add(
              FormField<dynamic>(
                initialValue: _cfgValues[field.name],
                validator: (val) {
                  // 然后执行自定义校验
                  return p.validator!(val);
                },
                builder: (state) {
                  // 当控制器值改变时，同步到 FormField 状态
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final currentValue = _cfgValues[field.name];
                    if (state.value != currentValue) {
                      state.didChange(currentValue);
                    }
                  });

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      p.contentBuilder(context, _cfgValues[field.name], (newVal) {
                        setState(() {
                          _setValue(field.name, newVal);
                        });
                        state.didChange(newVal);
                      }),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(state.errorText ?? '', style: const TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                    ],
                  );
                },
              ),
            );
          } else {
            // 没有自定义校验器，但仍有必填校验
            if (field.required) {
              widgets.add(
                FormField<dynamic>(
                  initialValue: _cfgValues[field.name],
                  validator: (val) {
                    if (val == null || (val is String && val.toString().trim().isEmpty)) {
                      return '${field.label}必填';
                    }
                    return null;
                  },
                  builder: (state) {
                    // 当控制器值改变时，同步到 FormField 状态
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final currentValue = _cfgValues[field.name];
                      if (state.value != currentValue) {
                        state.didChange(currentValue);
                      }
                    });

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        p.contentBuilder(context, _cfgValues[field.name], (newVal) {
                          setState(() {
                            _setValue(field.name, newVal);
                          });
                          state.didChange(newVal);
                        }),
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(state.errorText ?? '', style: const TextStyle(color: Colors.red, fontSize: 12)),
                          ),
                      ],
                    );
                  },
                ),
              );
            } else {
              // 既没有自定义校验器，也不是必填，直接渲染内容
              widgets.add(
                p.contentBuilder(
                  context,
                  _cfgValues[field.name],
                  (newVal) => setState(() {
                    _setValue(field.name, newVal);
                  }),
                ),
              );
            }
          }
          break;
      }
      widgets.add(const SizedBox(height: 16));
    }
    return widgets;
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
          autovalidateMode: AutovalidateMode.disabled,
          child: SingleChildScrollView(
            padding: widget.padding ?? widget.formConfig.uiOptions?.padding ?? const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [..._buildDynamicFromConfig(widget.formConfig)]),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, {bool isRequired = false}) {
    final cfg = widget.formConfig.uiOptions;
    final style = widget.labelStyle ?? cfg?.labelStyle ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87);
    if (!isRequired) return Text(label, style: style);
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
      // 尝试通过设置对齐方式来解决左对齐问题
      alignLabelWithHint: true,
    );
  }

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

  Widget _buildTapContainer({required String placeholder, required IconData icon, VoidCallback? onTap}) {
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
              child: Text(placeholder, style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
            ),
            Icon(icon, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
