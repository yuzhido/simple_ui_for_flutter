import 'package:example/pages/custom_form/index.dart';
import 'package:flutter/material.dart';

class CustomFormExampleDemosPage extends StatefulWidget {
  const CustomFormExampleDemosPage({super.key});
  @override
  State<CustomFormExampleDemosPage> createState() => _CustomFormExampleDemosPageState();
}

class _CustomFormExampleDemosPageState extends State<CustomFormExampleDemosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导航栏标题')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomFormPage())),
              child: const Text('最新配置表单(CustomFormExampleDemosPage)示例'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
