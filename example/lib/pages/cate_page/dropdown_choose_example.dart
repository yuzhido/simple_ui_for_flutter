import 'package:example/pages/dropdown_choose/index.dart';
import 'package:flutter/material.dart';

class DropdownChooseExamplePage extends StatefulWidget {
  const DropdownChooseExamplePage({super.key});
  @override
  State<DropdownChooseExamplePage> createState() => _DropdownChoosePageState();
}

class _DropdownChoosePageState extends State<DropdownChooseExamplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('自定义下拉选择相关示例')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DropdownChoosePage())),
            child: const Text('下拉选择（DropdownChoose）示例'),
          ),
          const SizedBox(height: 12),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
