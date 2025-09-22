import 'package:example/pages/dropdown_choose/index.dart';
import 'package:flutter/material.dart';

class DropdownChoosePage extends StatefulWidget {
  const DropdownChoosePage({super.key});
  @override
  State<DropdownChoosePage> createState() => _DropdownChoosePageState();
}

class _DropdownChoosePageState extends State<DropdownChoosePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('自定义下拉选择相关示例')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DropdownSelectPage())),
            child: const Text('下拉选择（DropdownChoose）示例'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
