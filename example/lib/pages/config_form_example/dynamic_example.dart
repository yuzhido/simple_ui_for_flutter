import 'dart:async';
import 'package:flutter/material.dart';
import 'package:simple_ui/models/field_configs.dart';
import 'package:simple_ui/simple_ui.dart';
import 'package:simple_ui/src/config_form/config_form_controller.dart';

/// 动态修改默认值示例页面
/// 展示如何在运行时动态修改表单字段的值
class DynamicDefaultValueExamplePage extends StatefulWidget {
  const DynamicDefaultValueExamplePage({super.key});

  @override
  State<DynamicDefaultValueExamplePage> createState() => _DynamicDefaultValueExamplePageState();
}

class _DynamicDefaultValueExamplePageState extends State<DynamicDefaultValueExamplePage> {
  Map<String, dynamic> _formData = {};
  final ConfigFormController _formController = ConfigFormController();
  Timer? _timer;
  int _countdown = 3;

  // 表单配置
  List<FormConfig> get _formConfigs => [
    FormConfig.text(TextFieldConfig(name: 'username', label: '用户名', required: true, defaultValue: '初始用户名')),
    FormConfig.text(TextFieldConfig(name: 'email', label: '邮箱', required: true, defaultValue: 'initial@example.com')),
    FormConfig.integer(IntegerFieldConfig(name: 'age', label: '年龄', required: false, defaultValue: 18, minValue: 1, maxValue: 120)),
    FormConfig.textarea(TextareaFieldConfig(name: 'description', label: '个人描述', required: false, defaultValue: '这是初始描述内容', rows: 3)),
    FormConfig.number(NumberFieldConfig(name: 'salary', label: '期望薪资', required: false, defaultValue: 8000.0, minValue: 0, maxValue: 100000)),
  ];

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        _updateDefaultValues();
        timer.cancel();
      }
    });
  }

  void _updateDefaultValues() {
    // 3秒后动态修改所有字段的默认值
    _formController.setFieldValues({
      'username': '动态用户名_${DateTime.now().millisecondsSinceEpoch}',
      'email': 'dynamic_${DateTime.now().millisecondsSinceEpoch}@example.com',
      'age': 25 + (DateTime.now().millisecondsSinceEpoch % 20),
      'description': '这是动态更新的描述内容，更新时间：${DateTime.now().toString().substring(0, 19)}',
      'salary': 12000.0 + (DateTime.now().millisecondsSinceEpoch % 5000),
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('默认值已动态更新！'), backgroundColor: Colors.green, duration: Duration(seconds: 2)));
  }

  void _onFormChanged(Map<String, dynamic> data) {
    setState(() {
      _formData = data;
    });
  }

  void _manualUpdateValues() {
    // 手动更新字段值
    _formController.setFieldValues({
      'username': '手动更新_${DateTime.now().millisecondsSinceEpoch}',
      'email': 'manual_${DateTime.now().millisecondsSinceEpoch}@example.com',
      'age': 30 + (DateTime.now().millisecondsSinceEpoch % 10),
      'description': '手动更新的描述内容',
      'salary': 15000.0,
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('字段值已手动更新！'), backgroundColor: Colors.blue, duration: Duration(seconds: 2)));
  }

  void _clearAllFields() {
    _formController.clearAllFields();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('所有字段已清空！'), backgroundColor: Colors.orange, duration: Duration(seconds: 2)));
  }

  void _resetToDefaults() {
    _formController.reset();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('表单已重置为默认值！'), backgroundColor: Colors.purple, duration: Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('动态修改默认值示例'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 倒计时提示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _countdown > 0 ? Colors.orange[100] : Colors.green[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _countdown > 0 ? Colors.orange : Colors.green),
              ),
              child: Text(
                _countdown > 0 ? '⏰ ${_countdown}秒后将自动更新所有字段的默认值...' : '✅ 默认值已自动更新完成！',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _countdown > 0 ? Colors.orange[800] : Colors.green[800]),
              ),
            ),
            const SizedBox(height: 20),

            // 操作按钮
            const Text('手动操作：', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _manualUpdateValues,
                  icon: const Icon(Icons.update),
                  label: const Text('手动更新值'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: _clearAllFields,
                  icon: const Icon(Icons.clear),
                  label: const Text('清空所有字段'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: _resetToDefaults,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重置表单'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 表单
            ConfigForm(
              configs: _formConfigs,
              controller: _formController,
              onChanged: _onFormChanged,
              submitBuilder: (formData) => Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final data = _formController.save();
                        if (data != null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('表单提交成功！数据：${data.toString()}'), backgroundColor: Colors.green));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('表单验证失败，请检查输入！'), backgroundColor: Colors.red));
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: const Text('提交表单'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 实时表单数据
            const Text('实时表单数据：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(_formData.toString(), style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ),
            const SizedBox(height: 20),

            // 功能说明
            const Text('功能说明：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              '• 页面加载后3秒自动更新所有字段值\n'
              '• 支持手动更新单个或批量字段值\n'
              '• 支持清空所有字段或重置表单\n'
              '• 所有操作都会实时更新表单数据和UI\n'
              '• 支持表单验证和提交',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
