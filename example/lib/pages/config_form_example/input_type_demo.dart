import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_ui/models/field_configs.dart';
import 'package:simple_ui/models/form_config.dart';
import 'package:simple_ui/src/config_form/index.dart';

class InputTypeDemoPage extends StatefulWidget {
  const InputTypeDemoPage({super.key});

  @override
  State<InputTypeDemoPage> createState() => _InputTypeDemoPageState();
}

class _InputTypeDemoPageState extends State<InputTypeDemoPage> {
  final ConfigFormController _formController = ConfigFormController();
  Map<String, dynamic> _formData = {};

  List<FormConfig> get _formConfigs => [
    // 普通文本输入
    FormConfig.text(TextFieldConfig(name: 'username', label: '用户名', required: true, maxLength: 20)),

    // 手机号输入 - 使用数字键盘和格式化器
    FormConfig.text(
      TextFieldConfig(
        name: 'mobile',
        label: '手机号码',
        required: true,
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
      ),
    ),

    // 邮箱输入 - 使用邮箱键盘
    FormConfig.text(TextFieldConfig(name: 'userEmail', label: '邮箱地址', required: true, keyboardType: TextInputType.emailAddress)),

    // 数字输入 - 使用数字键盘
    FormConfig.text(
      TextFieldConfig(
        name: 'idCard',
        label: '身份证号',
        required: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9Xx]')), LengthLimitingTextInputFormatter(18)],
      ),
    ),

    // URL输入 - 使用URL键盘
    FormConfig.text(TextFieldConfig(name: 'website', label: '个人网站', keyboardType: TextInputType.url)),

    // 多行文本输入 - 使用多行键盘
    FormConfig.text(TextFieldConfig(name: 'bio', label: '个人简介', keyboardType: TextInputType.multiline, maxLength: 200)),

    // 金额输入 - 只允许数字和小数点
    FormConfig.text(
      TextFieldConfig(
        name: 'salary',
        label: '期望薪资',
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
      ),
    ),

    // 验证码输入 - 只允许数字，限制长度
    FormConfig.text(
      TextFieldConfig(
        name: 'verifyCode',
        label: '验证码',
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('输入类型配置演示'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 说明文本
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('正确的配置方式：', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 8),
                  Text(
                    '• 通过 keyboardType 属性设置键盘类型\n'
                    '• 通过 inputFormatters 属性设置输入限制\n'
                    '• 不依赖字段名称进行判断\n'
                    '• 配置更加灵活和明确',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 表单
            ConfigForm(
              controller: _formController,
              configs: _formConfigs,
              onChanged: (data) {
                setState(() {
                  _formData = data;
                });
              },
            ),

            const SizedBox(height: 20),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formController.validate()) {
                        final data = _formController.getFormData();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('表单数据'),
                            content: Text(data.toString()),
                            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('确定'))],
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text('提交表单'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _formController.clearAllFields();
                      setState(() {
                        _formData.clear();
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                    child: const Text('清空表单'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 当前表单数据
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('当前表单数据:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_formData.isEmpty ? '暂无数据' : _formData.toString(), style: const TextStyle(fontFamily: 'monospace')),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 代码示例
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('配置示例代码:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('''// 手机号输入配置
FormConfig.text(TextFieldConfig(
  name: 'mobile',
  label: '手机号码',
  keyboardType: TextInputType.phone,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(11),
  ],
))

// 邮箱输入配置
FormConfig.text(TextFieldConfig(
  name: 'email',
  label: '邮箱地址',
  keyboardType: TextInputType.emailAddress,
))''', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.black87)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
