import 'package:flutter/material.dart';

// 表单字段标签信息
class LabelInfo extends StatelessWidget {
  final String label;
  final bool required;
  const LabelInfo({super.key, required this.label, this.required = false});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
          children: required
              ? [
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ]
              : [],
        ),
      ),
    );
  }
}
