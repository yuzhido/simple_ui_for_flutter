import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_ui/models/form_field_config.dart';
import 'package:simple_ui/models/select_data.dart';
import 'package:simple_ui/src/dropdown_choose/index.dart';

class ConfigForm extends StatefulWidget {
  final FormConfig formConfig;
  final Function(Map<String, dynamic>)? onSubmit;
  final Function(bool isValid, Map<String, String?> errors)? onValidationChanged;

  const ConfigForm({super.key, required this.formConfig, this.onSubmit, this.onValidationChanged});

  @override
  State<ConfigForm> createState() => _ConfigFormState();
}

class _ConfigFormState extends State<ConfigForm> {
  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _errors = {};
  final Map<String, Key> _dropdownKeys = {};
  // 添加一个key来强制重建表单
  Key _formKey = UniqueKey();

  // 暴露给外部调用的验证方法
  bool validateForm() {
    return _validateForm();
  }

  // 获取当前表单数据
  Map<String, dynamic> getFormData() {
    return Map.unmodifiable(_formData);
  }

  // 获取当前错误信息
  Map<String, String?> getErrors() {
    return Map.unmodifiable(_errors);
  }

  // 重置表单（外部可调用）
  void resetForm() {
    _resetForm();
  }

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    // 初始化控制器和默认值
    for (var field in widget.formConfig.fields) {
      final name = field.name;
      if (field.type == FormFieldType.text ||
          field.type == FormFieldType.number ||
          field.type == FormFieldType.double ||
          field.type == FormFieldType.integer ||
          field.type == FormFieldType.textarea) {
        _controllers[name] = TextEditingController();
        if (field.defaultValue != null) {
          _controllers[name]!.text = field.defaultValue.toString();
          _formData[name] = field.defaultValue;
        }
      } else if (field.type == FormFieldType.select) {
        // 为DropdownChoose组件创建key
        _dropdownKeys[name] = UniqueKey();
        if (field.defaultValue != null) {
          _formData[name] = field.defaultValue;
        }
      } else if (field.defaultValue != null) {
        _formData[name] = field.defaultValue;
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(ConfigForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果formConfig发生变化，重新初始化控制器和默认值
    if (oldWidget.formConfig != widget.formConfig) {
      // 清理旧的控制器
      for (var controller in _controllers.values) {
        controller.dispose();
      }
      _controllers.clear();
      _dropdownKeys.clear();
      _formData.clear();
      _errors.clear();

      // 重新初始化控制器和默认值
      _initializeFormData();
    }
  }

  /// 验证表单
  bool _validateForm() {
    _errors.clear();
    bool isValid = true;

    for (var field in widget.formConfig.fields) {
      final name = field.name;
      final required = field.required;
      final value = _formData[name];

      if (required) {
        if (value == null || (value is String && value.trim().isEmpty) || (value is List && value.isEmpty)) {
          _errors[name] = '${field.label}不能为空';
          isValid = false;
        }
      }
    }

    setState(() {});

    // 通知外部验证状态变化
    if (widget.onValidationChanged != null) {
      widget.onValidationChanged!(isValid, _errors);
    }

    return isValid;
  }

  /// 重置表单
  void _resetForm() {
    setState(() {
      _errors.clear();
      _formData.clear();

      // 清空所有文本控制器
      for (var controller in _controllers.values) {
        controller.clear();
      }

      // 为DropdownChoose组件生成新的key，强制重建
      for (var field in widget.formConfig.fields) {
        if (field.type == FormFieldType.select) {
          _dropdownKeys[field.name] = UniqueKey();
        }
      }

      // 强制重建表单以重置所有字段状态
      _formKey = UniqueKey();

      // 重新初始化默认值
      _initializeFormData();
    });
  }

  /// 构建带红色*号的标签文本
  Widget _buildLabel(String label, bool required) {
    if (!required) {
      return Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
      );
    }
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        children: [
          TextSpan(text: label),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// 构建错误提示
  Widget _buildError(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(error, style: const TextStyle(color: Colors.red, fontSize: 12)),
    );
  }

  Widget _buildField(FormFieldConfig field) {
    final name = field.name;
    final type = field.type;
    final error = _errors[name];

    switch (type) {
      case FormFieldType.text:
        return _buildTextField(field, error);

      case FormFieldType.number:
        return _buildNumberField(field, error, false);

      case FormFieldType.integer:
        return _buildNumberField(field, error, true);

      case FormFieldType.double:
        return _buildNumberField(field, error, false);

      case FormFieldType.textarea:
        return _buildTextArea(field, error);

      case FormFieldType.radio:
        return _buildRadioGroup(field, error);

      case FormFieldType.checkbox:
        return _buildCheckboxGroup(field, error);

      case FormFieldType.select:
        return _buildSelect(field, error);

      case FormFieldType.dropdown:
        return _buildSelect(field, error);

      case FormFieldType.button:
        return _buildButton(field);

      case FormFieldType.switch_:
        return _buildSwitch(field, error);

      case FormFieldType.date:
        return _buildDatePicker(field, error);

      case FormFieldType.time:
        return _buildTimePicker(field, error);

      case FormFieldType.slider:
        return _buildSlider(field, error);
    }
  }

  Widget _buildTextField(FormFieldConfig field, String? error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field.label, field.required),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controllers[field.name],
          decoration: InputDecoration(
            hintText: _getPlaceholder(field),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: error != null ? Colors.red : Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: error != null ? Colors.red : Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: field.disabled ? Colors.grey.shade100 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          enabled: !field.disabled,
          onChanged: (value) {
            _formData[field.name] = value;
            if (error != null) {
              _errors.remove(field.name);
              setState(() {});
            }
          },
        ),
        _buildError(error),
      ],
    );
  }

  Widget _buildNumberField(FormFieldConfig field, String? error, bool isInteger) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field.label, field.required),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controllers[field.name],
          decoration: InputDecoration(
            hintText: _getPlaceholder(field),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: error != null ? Colors.red : Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: error != null ? Colors.red : Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: field.disabled ? Colors.grey.shade100 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          keyboardType: isInteger ? TextInputType.number : const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [if (isInteger) FilteringTextInputFormatter.digitsOnly else FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          enabled: !field.disabled,
          onChanged: (value) {
            _formData[field.name] = value;
            if (error != null) {
              _errors.remove(field.name);
              setState(() {});
            }
          },
        ),
        _buildError(error),
      ],
    );
  }

  Widget _buildTextArea(FormFieldConfig field, String? error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field.label, field.required),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controllers[field.name],
          decoration: InputDecoration(
            hintText: _getPlaceholder(field),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: error != null ? Colors.red : Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: error != null ? Colors.red : Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: field.disabled ? Colors.grey.shade100 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          maxLines: 4,
          enabled: !field.disabled,
          onChanged: (value) {
            _formData[field.name] = value;
            if (error != null) {
              _errors.remove(field.name);
              setState(() {});
            }
          },
        ),
        _buildError(error),
      ],
    );
  }

  Widget _buildRadioGroup(FormFieldConfig field, String? error) {
    final options = field.options ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field.label, field.required),
        const SizedBox(height: 8),
        Container(
          height: 56, // 与输入框高度一致
          decoration: BoxDecoration(
            border: Border.all(color: error != null ? Colors.red : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            children: options
                .map(
                  (option) => Expanded(
                    child: RadioListTile<dynamic>(
                      title: Text(option.label, style: const TextStyle(fontSize: 14)),
                      value: option.value,
                      groupValue: _formData[field.name],
                      activeColor: Colors.blue,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      onChanged: field.disabled
                          ? null
                          : (value) {
                              setState(() {
                                _formData[field.name] = value;
                                if (error != null) {
                                  _errors.remove(field.name);
                                }
                              });
                            },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        _buildError(error),
      ],
    );
  }

  Widget _buildCheckboxGroup(FormFieldConfig field, String? error) {
    final options = field.options ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field.label, field.required),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: error != null ? Colors.red : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map(
                  (option) => Container(
                    constraints: const BoxConstraints(minWidth: 80),
                    child: CheckboxListTile(
                      title: Text(option.label, style: const TextStyle(fontSize: 14)),
                      value: (_formData[field.name] as List<dynamic>?)?.contains(option.value) ?? false,
                      activeColor: Colors.blue,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      onChanged: field.disabled
                          ? null
                          : (checked) {
                              setState(() {
                                if (_formData[field.name] == null) {
                                  _formData[field.name] = <dynamic>[];
                                }
                                final list = _formData[field.name] as List<dynamic>;
                                if (checked == true) {
                                  if (!list.contains(option.value)) {
                                    list.add(option.value);
                                  }
                                } else {
                                  list.remove(option.value);
                                }
                                if (error != null) {
                                  _errors.remove(field.name);
                                }
                              });
                            },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        _buildError(error),
      ],
    );
  }

  Widget _buildSelect(FormFieldConfig field, String? error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field.label, field.required),
        const SizedBox(height: 8),
        DropdownChoose<String>(
          key: _dropdownKeys[field.name],
          list: field.options?.map((option) => SelectData<String>(label: option.label, value: option.value as String, data: option.data)).toList(),
          remoteFetch: field.remoteFetch != null
              ? (String? keyword) => field.remoteFetch!(keyword).then(
                  (list) => list.map((item) => SelectData<String>(label: item.label, value: item.value as String, data: item.data)).toList(),
                )
              : null,
          multiple: field.multiple,
          filterable: field.filterable,
          remote: field.remote,
          defaultValue: field.defaultValue,
          onSingleSelected: field.disabled
              ? null
              : (value) {
                  setState(() {
                    _formData[field.name] = value.value;
                    if (error != null) {
                      _errors.remove(field.name);
                    }
                  });
                },
          onMultipleSelected: field.disabled
              ? null
              : (values) {
                  setState(() {
                    _formData[field.name] = values.map((v) => v.value).toList();
                    if (error != null) {
                      _errors.remove(field.name);
                    }
                  });
                },
        ),
        _buildError(error),
      ],
    );
  }

  Widget _buildSwitch(FormFieldConfig field, String? error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field.label, field.required),
        const SizedBox(height: 8),
        Row(
          children: [
            Switch(
              value: _formData[field.name] ?? false,
              onChanged: field.disabled
                  ? null
                  : (value) {
                      setState(() {
                        _formData[field.name] = value;
                        if (error != null) {
                          _errors.remove(field.name);
                        }
                      });
                    },
            ),
          ],
        ),
        _buildError(error),
      ],
    );
  }

  Widget _buildDatePicker(FormFieldConfig field, String? error) {
    final hasValue = _formData[field.name] is DateTime;
    final placeholder = _getPlaceholder(field);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field.label, field.required),
        const SizedBox(height: 8),
        InkWell(
          onTap: field.disabled
              ? null
              : () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _formData[field.name] ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _formData[field.name] = date;
                      if (error != null) {
                        _errors.remove(field.name);
                      }
                    });
                  }
                },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: error != null ? Colors.red : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: field.disabled ? Colors.grey.shade100 : Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: hasValue
                      ? Text(
                          '${_formData[field.name].year}-${_formData[field.name].month.toString().padLeft(2, '0')}-${_formData[field.name].day.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 16),
                        )
                      : Text(placeholder, style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),
        _buildError(error),
      ],
    );
  }

  Widget _buildTimePicker(FormFieldConfig field, String? error) {
    final hasValue = _formData[field.name] is TimeOfDay;
    final placeholder = _getPlaceholder(field);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field.label, field.required),
        const SizedBox(height: 8),
        InkWell(
          onTap: field.disabled
              ? null
              : () async {
                  final time = await showTimePicker(context: context, initialTime: _formData[field.name] ?? TimeOfDay.now());
                  if (time != null) {
                    setState(() {
                      _formData[field.name] = time;
                      if (error != null) {
                        _errors.remove(field.name);
                      }
                    });
                  }
                },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: error != null ? Colors.red : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: field.disabled ? Colors.grey.shade100 : Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: hasValue
                      ? Text(
                          '${_formData[field.name].hour.toString().padLeft(2, '0')}:${_formData[field.name].minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 16),
                        )
                      : Text(placeholder, style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                ),
                const Icon(Icons.access_time, color: Colors.grey),
              ],
            ),
          ),
        ),
        _buildError(error),
      ],
    );
  }

  Widget _buildSlider(FormFieldConfig field, String? error) {
    final currentValue = (_formData[field.name] ?? 0.0).toDouble();
    final minValue = 0.0;
    final maxValue = 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field.label, field.required),
        const SizedBox(height: 8),
        Text('${currentValue.toStringAsFixed(1)}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Slider(
          value: currentValue,
          min: minValue,
          max: maxValue,
          divisions: 100,
          onChanged: field.disabled
              ? null
              : (value) {
                  setState(() {
                    _formData[field.name] = value;
                    if (error != null) {
                      _errors.remove(field.name);
                    }
                  });
                },
        ),
        _buildError(error),
      ],
    );
  }

  Widget _buildButton(FormFieldConfig field) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: field.disabled
                ? null
                : () {
                    if (_validateForm()) {
                      if (widget.onSubmit != null) {
                        widget.onSubmit!(_formData);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请填写所有必填字段'), backgroundColor: Colors.red));
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 2,
            ),
            child: Text(field.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: field.disabled ? null : _resetForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 1,
            ),
            child: const Text('重置', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  /// 获取字段的placeholder，如果没有提供则自动生成
  String _getPlaceholder(FormFieldConfig field) {
    if (field.placeholder != null && field.placeholder!.isNotEmpty) {
      return field.placeholder!;
    }

    // 根据字段类型和label自动生成placeholder
    switch (field.type) {
      case FormFieldType.text:
      case FormFieldType.number:
      case FormFieldType.integer:
      case FormFieldType.double:
      case FormFieldType.textarea:
        return '请输入${field.label}';
      case FormFieldType.radio:
      case FormFieldType.checkbox:
        return '请选择${field.label}';
      case FormFieldType.select:
      case FormFieldType.dropdown:
        return '请选择${field.label}';
      case FormFieldType.date:
        return '请选择${field.label}';
      case FormFieldType.time:
        return '请选择${field.label}';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 点击空白区域时隐藏键盘
        FocusScope.of(context).unfocus();
      },
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
        child: Column(
          key: _formKey, // 添加key来强制重建
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.formConfig.title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  widget.formConfig.title!,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            if (widget.formConfig.description != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  widget.formConfig.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600], height: 1.4),
                ),
              ),
            ...widget.formConfig.fields.map((field) {
              return Padding(padding: const EdgeInsets.only(bottom: 20.0), child: _buildField(field));
            }),
          ],
        ),
      ),
    );
  }
}
