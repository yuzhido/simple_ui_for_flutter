import 'package:flutter/material.dart';

class CircleLoading extends StatelessWidget {
  const CircleLoading({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600)));
  }
}
