import 'package:example/pages/config_form_example/index.dart';
import 'package:example/pages/config_form_example/advanced_example.dart';
import 'package:example/pages/config_form_example/dynamic_example.dart';
import 'package:example/pages/config_form_example/isshow_example.dart';
import 'package:example/pages/config_form_example/time_datetime_example.dart';
import 'package:example/pages/config_form_example/choice_example.dart';
import 'package:example/pages/config_form_example/tree_select_demo.dart';
import 'package:example/pages/config_form_example/dropdown_choose_demo.dart';
import 'package:flutter/material.dart';
import 'package:example/pages/config_form_example/upload_file_demo.dart';
import 'package:example/pages/config_form_example/custom_widget_demo.dart';
import 'package:example/pages/config_form_example/all_form_type_demo.dart';
import 'package:example/pages/config_form_example/all_form_type_required_demo.dart';
import 'package:example/pages/config_form_example/all_type_set_default_value_demo.dart';
import 'package:example/pages/config_form_example/all_type_add_is_required.dart';
import 'package:example/pages/config_form_example/input_type_demo.dart';

class ConfigFormExamplesPage extends StatefulWidget {
  const ConfigFormExamplesPage({super.key});
  @override
  State<ConfigFormExamplesPage> createState() => _ConfigFormExamplesPageState();
}

class _ConfigFormExamplesPageState extends State<ConfigFormExamplesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ConfigForm 示例'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('选择要查看的示例：', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigFormExamplePage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('基础配置示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AllFormTypeDemoPage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('All FormType 全类型示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AllFormTypeRequiredDemoPage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black54, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('All FormType 必填示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AllTypeSetDefaultValueDemoPage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('默认值设置示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AllTypeAddIsRequiredPage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('个人信息表单示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvancedConfigExamplePage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('高级配置示例（新配置系统）'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DynamicDefaultValueExamplePage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('动态修改默认值示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const IsShowExamplePage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('isShow属性示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TimeDateTimeExamplePage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('Time & DateTime 字段示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChoiceFieldsExamplePage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('Radio / Checkbox / Select 示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DropdownChooseDemoPage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('DropdownChoose 示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadFileDemoPage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('Upload 文件上传示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomWidgetDemoPage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('Custom 自定义组件示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TreeSelectDemoPage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('TreeSelect 示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const InputTypeDemoPage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('⌨️ 输入类型配置演示'),
            ),
            const SizedBox(height: 20),
            const Text('新配置系统特点：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              '• 每个字段类型都有专门的配置类\n'
              '• 只显示该字段类型相关的属性\n'
              '• 类型安全，避免配置错误\n'
              '• 代码更清晰，维护更容易\n'
              '• 支持更多字段类型和高级功能',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
