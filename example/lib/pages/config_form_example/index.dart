import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';

class ConfigFormExamplePage extends StatefulWidget {
  const ConfigFormExamplePage({super.key});
  @override
  State<ConfigFormExamplePage> createState() => _ConfigFormExamplePageState();
}

class _ConfigFormExamplePageState extends State<ConfigFormExamplePage> {
  Map<String, dynamic> _formData = {};
  final ConfigFormController _formController = ConfigFormController();

  // 示例配置
  List<FormConfig> get _formConfigs => [
    FormConfig.text(TextFieldConfig(name: 'username', label: '用户名', required: true, defaultValue: '默认用户名', minLength: 2, maxLength: 20)),
    FormConfig.text(TextFieldConfig(name: 'email', label: '邮箱', required: true)),
    FormConfig.integer(IntegerFieldConfig(name: 'age', label: '年龄', required: false, defaultValue: 25, minValue: 1, maxValue: 120)),
    FormConfig.date(DateFieldConfig(name: 'birthday', label: '生日', required: false, minDate: DateTime(1900, 1, 1), maxDate: DateTime.now())),
    FormConfig.textarea(TextareaFieldConfig(name: 'description', label: '个人描述', required: false, maxLength: 500, rows: 4)),
    FormConfig.text(TextFieldConfig(name: 'phone', label: '手机号', required: false)),
    FormConfig.text(
      TextFieldConfig(
        name: 'customField',
        label: '自定义验证字段',
        required: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '此字段不能为空';
          }
          if (value.length < 5) {
            return '至少需要5个字符';
          }
          if (!value.contains('test')) {
            return '必须包含"test"字符串';
          }
          return null;
        },
      ),
    ),
  ];

  void _onFormChanged(Map<String, dynamic> data) {
    setState(() {
      _formData = data;
    });
  }

  void _onFormSubmit(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('表单数据'),
        content: Text(data.toString()),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('确定'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('配置表单示例'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '动态配置表单示例',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text('通过配置动态生成表单，支持文本、数字、多行文本等输入类型，内置表单验证功能', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),

            // 表单组件
            ConfigForm(
              configs: _formConfigs,
              onChanged: _onFormChanged,
              controller: _formController,
              submitBuilder: (formData) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // 重置表单
                      _formController.reset();
                      setState(() {
                        _formData.clear();
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text('重置'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // 验证并提交表单
                      final validatedData = _formController.save();
                      if (validatedData != null) {
                        _onFormSubmit(validatedData);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请检查表单填写是否正确'), backgroundColor: Colors.red));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('提交表单'),
                  ),
                ],
              ),
            ),

            // 实时显示表单数据
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '实时表单数据:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(_formData.isEmpty ? '暂无数据' : _formData.toString(), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 配置说明
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '配置说明:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• 用户名: 必填，2-20字符，带默认值\n'
                    '• 邮箱: 必填，自动验证邮箱格式\n'
                    '• 年龄: 可选，1-120岁，带默认值25\n'
                    '• 生日: 可选日期选择器\n'
                    '• 个人描述: 可选多行文本，最多500字符\n'
                    '• 手机号: 可选，自动验证手机号格式\n'
                    '• 自定义验证字段: 必填，至少5字符，必须包含"test"',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
