import 'package:flutter/material.dart';

class LoadingData extends StatelessWidget {
  const LoadingData({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600)),
          const SizedBox(height: 16),
          Text(
            '正在加载数据...',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
