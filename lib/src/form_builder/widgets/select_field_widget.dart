import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';

/// 下拉选择字段组件
class SelectFieldWidget extends StatelessWidget {
  final FormBuilderConfig config;
  final dynamic value;
  final Function(dynamic) onChanged;

  const SelectFieldWidget({super.key, required this.config, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final List<SelectOption> options = config.props is List<SelectOption> ? config.props as List<SelectOption> : [];

    return DropdownButtonFormField<dynamic>(
      value: value,
      items: options.map((option) => DropdownMenuItem(value: option.value, child: Text(option.label))).toList(),
      onChanged: onChanged,
      decoration: _inputDecoration(config.placeholder ?? '请选择'),
      validator:
          config.validator ??
          (val) {
            if (config.required && (val == null || (val is String && val.toString().trim().isEmpty))) {
              return '请选择${config.label}';
            }
            return null;
          },
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
}
