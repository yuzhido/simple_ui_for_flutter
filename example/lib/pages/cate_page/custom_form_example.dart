import 'package:example/pages/custom_form/index.dart';
import 'package:flutter/material.dart';

class CustomFormExamplePage extends StatefulWidget {
  const CustomFormExamplePage({super.key});
  @override
  State<CustomFormExamplePage> createState() => _CustomFormExamplePageState();
}

class _CustomFormExamplePageState extends State<CustomFormExamplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导航栏标题')),
      body: Column(
        children: [
          //
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomFormPage())),
            child: const Text('自定义表单（CustomForm）示例'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
