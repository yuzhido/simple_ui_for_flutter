import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';

/// 多行文本字段组件
class TextareaFieldWidget extends StatelessWidget {
  final FormBuilderConfig config;
  final TextEditingController? controller;
  final dynamic value;
  final Function(String) onChanged;

  const TextareaFieldWidget({super.key, required this.config, this.controller, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? value?.toString() : null,
      maxLines: 4,
      decoration: _textareaDecoration('请输入${config.label ?? ''}'),
      onChanged: onChanged,
      validator:
          config.validator ??
          (value) {
            if (config.required && (value == null || value.trim().isEmpty)) {
              return '${config.label}必填';
            }
            return null;
          },
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
      alignLabelWithHint: true,
    );
  }
}
