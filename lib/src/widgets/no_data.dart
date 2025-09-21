import 'package:flutter/material.dart';

class NoData extends StatelessWidget {
  const NoData({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            '暂无数据',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
