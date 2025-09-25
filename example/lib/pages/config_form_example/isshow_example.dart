import 'dart:async';
import 'package:flutter/material.dart';
import 'package:simple_ui/models/field_configs.dart';
import 'package:simple_ui/simple_ui.dart';

/// isShow属性示例页面
/// 展示如何使用isShow属性控制表单项的显示和隐藏
class IsShowExamplePage extends StatefulWidget {
  const IsShowExamplePage({super.key});

  @override
  State<IsShowExamplePage> createState() => _IsShowExamplePageState();
}

class _IsShowExamplePageState extends State<IsShowExamplePage> {
  Map<String, dynamic> _formData = {};
  final ConfigFormController _formController = ConfigFormController();
  Timer? _timer;
  int _countdown = 5;
  bool _showAdvancedFields = false;
  bool _showDescription = false; // 根据年龄控制描述字段显示

  // 表单配置 - 部分字段初始隐藏
  List<FormConfig> get _formConfigs => [
    // 基础字段 - 始终显示
    FormConfig.text(
      TextFieldConfig(
        name: 'username',
        label: '用户名',
        required: true,
        defaultValue: '张三',
        isShow: true, // 明确设置为显示
      ),
    ),
    FormConfig.text(TextFieldConfig(name: 'email', label: '邮箱', required: true, defaultValue: 'zhangsan@example.com', isShow: true)),

    // 条件显示字段 - 根据用户类型显示
    FormConfig.integer(
      IntegerFieldConfig(
        name: 'age',
        label: '年龄',
        required: false,
        defaultValue: 25,
        minValue: 1,
        maxValue: 120,
        isShow: _showAdvancedFields, // 根据条件显示
      ),
    ),
    FormConfig.textarea(TextareaFieldConfig(name: 'description', label: '个人描述', required: false, defaultValue: '这是一个描述', rows: 3, isShow: _showDescription)), // 根据年龄控制显示
    // 隐藏字段 - 不显示
    FormConfig.number(
      NumberFieldConfig(
        name: 'salary',
        label: '薪资',
        required: false,
        defaultValue: 8000.0,
        minValue: 0,
        maxValue: 100000,
        isShow: false, // 明确设置为隐藏
      ),
    ),
    FormConfig.date(
      DateFieldConfig(
        name: 'birthday',
        label: '生日',
        required: false,
        isShow: false, // 隐藏字段
      ),
    ),

    // 动态显示字段 - 5秒后显示
    FormConfig.text(
      TextFieldConfig(
        name: 'dynamicField',
        label: '动态字段',
        required: false,
        defaultValue: '这个字段将在5秒后显示',
        isShow: _countdown <= 0, // 倒计时结束后显示
      ),
    ),
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('动态字段已显示！'), backgroundColor: Colors.green, duration: Duration(seconds: 2)));
        timer.cancel();
      }
    });
  }

  void _onFormChanged(Map<String, dynamic> data) {
    setState(() {
      _formData = data;
      // 根据年龄控制个人描述字段显示
      final ageStr = data['age']?.toString() ?? '';
      final age = int.tryParse(ageStr);
      _showDescription = age != null && age > 50;
    });
  }

  void _toggleAdvancedFields() {
    setState(() {
      _showAdvancedFields = !_showAdvancedFields;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_showAdvancedFields ? '高级字段已显示' : '高级字段已隐藏'),
        backgroundColor: _showAdvancedFields ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAllFields() {
    setState(() {
      _showAdvancedFields = true;
      _countdown = 0; // 立即显示动态字段
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('所有字段已显示！'), backgroundColor: Colors.blue, duration: Duration(seconds: 2)));
  }

  void _hideAllFields() {
    setState(() {
      _showAdvancedFields = false;
      _countdown = 5; // 重新开始倒计时
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('部分字段已隐藏！'), backgroundColor: Colors.red, duration: Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('isShow属性示例'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态提示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('当前状态：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('• 高级字段：${_showAdvancedFields ? "显示" : "隐藏"}'),
                  Text('• 个人描述：${_showDescription ? "显示（年龄>50）" : "隐藏（年龄≤50）"}'),
                  Text('• 动态字段：${_countdown <= 0 ? "显示" : "还有${_countdown}秒显示"}'),
                  Text('• 隐藏字段：薪资、生日（isShow=false）'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 年龄控制提示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: const Text('💡 提示：输入年龄大于50时，个人描述字段会自动显示；年龄小于等于50时，个人描述字段会自动隐藏。', style: TextStyle(fontSize: 14, color: Colors.amber)),
            ),
            const SizedBox(height: 20),

            // 操作按钮
            const Text('控制字段显示：', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleAdvancedFields,
                  icon: Icon(_showAdvancedFields ? Icons.visibility_off : Icons.visibility),
                  label: Text(_showAdvancedFields ? '隐藏高级字段' : '显示高级字段'),
                  style: ElevatedButton.styleFrom(backgroundColor: _showAdvancedFields ? Colors.orange : Colors.green, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: _showAllFields,
                  icon: const Icon(Icons.visibility),
                  label: const Text('显示所有字段'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: _hideAllFields,
                  icon: const Icon(Icons.visibility_off),
                  label: const Text('隐藏部分字段'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
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
            const Text('isShow属性说明：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              '• isShow=true：字段显示（默认值）\n'
              '• isShow=false：字段隐藏\n'
              '• 支持动态控制：可以根据条件动态显示/隐藏字段\n'
              '• 年龄>50时显示个人描述字段，≤50时隐藏\n'
              '• 隐藏的字段不会参与表单验证\n'
              '• 隐藏的字段不会出现在提交的数据中\n'
              '• 支持所有字段类型：text、number、date等',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // 代码示例
            const Text('代码示例：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
              child: Text('''// 隐藏字段
FormConfig.text(TextFieldConfig(
  name: 'hiddenField',
  label: '隐藏字段',
  isShow: false, // 设置为false隐藏
)),

// 条件显示
FormConfig.integer(IntegerFieldConfig(
  name: 'age',
  label: '年龄',
  isShow: _showAdvancedFields, // 根据条件显示
)),

// 根据其他字段值动态显示
FormConfig.textarea(TextareaFieldConfig(
  name: 'description',
  label: '个人描述',
  isShow: _showDescription, // 根据年龄>50显示
)),

// 动态显示
FormConfig.text(TextFieldConfig(
  name: 'dynamicField',
  label: '动态字段',
  isShow: _countdown <= 0, // 倒计时结束后显示
)),''', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.green[300])),
            ),
          ],
        ),
      ),
    );
  }
}
