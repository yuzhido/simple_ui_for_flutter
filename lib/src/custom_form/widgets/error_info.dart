import 'package:flutter/material.dart';

// 错误提示信息
class ErrorInfo extends StatelessWidget {
  final String error;
  const ErrorInfo(this.error, {super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),
        Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
      ],
    );
  }
}
