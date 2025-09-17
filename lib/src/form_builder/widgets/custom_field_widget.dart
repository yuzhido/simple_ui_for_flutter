import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';

/// 自定义字段组件
class CustomFieldWidget extends StatelessWidget {
  final FormBuilderConfig config;
  final dynamic value;
  final Function(dynamic) onChanged;

  const CustomFieldWidget({super.key, required this.config, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: const Center(
        child: Text('自定义字段', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
