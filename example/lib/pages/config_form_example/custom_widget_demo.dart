import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';

class CustomWidgetDemoPage extends StatefulWidget {
  const CustomWidgetDemoPage({super.key});
  @override
  State<CustomWidgetDemoPage> createState() => _CustomWidgetDemoPageState();
}

class _CustomWidgetDemoPageState extends State<CustomWidgetDemoPage> {
  final ConfigFormController _formController = ConfigFormController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('自定义组件示例')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConfigForm(
              controller: _formController,
              configs: [
                // 自定义输入组件（通过 CustomFieldConfig 指定 contentBuilder）
                FormConfig.custom(
                  CustomFieldConfig(
                    name: 'custom_input',
                    label: '自定义输入',
                    required: true,
                    contentBuilder: (cfg, controller, onChanged) {
                      return TextFormField(
                        decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '请输入自定义内容'),
                        onChanged: onChanged,
                      );
                    },
                  ),
                ),
                // 自定义展示组件
                FormConfig.custom(
                  CustomFieldConfig(
                    name: 'static_info',
                    label: '只读信息13131',
                    contentBuilder: (cfg, controller, onChanged) {
                      return Container(
                        child: Text('controller.text', style: const TextStyle(color: Colors.grey)),
                      );
                    },
                  ),
                ),
              ],
              submitBuilder: (formData) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formController.validate()) {
                        final data = _formController.getFormData();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('提交成功：\n${data.toString()}')));
                      }
                    },
                    child: const Text('提交'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
