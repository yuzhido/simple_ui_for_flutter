import 'package:flutter/material.dart';

class FormBuilderDemoPage extends StatefulWidget {
  const FormBuilderDemoPage({super.key});
  @override
  State<FormBuilderDemoPage> createState() => _FormBuilderDemoPageState();
}

class _FormBuilderDemoPageState extends State<FormBuilderDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FormBuilder 示例')),
      body: const Text('页面内容正在开发中...'),
    );
  }
}
