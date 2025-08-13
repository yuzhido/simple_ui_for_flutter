import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';

class NewDataFormPage extends StatefulWidget {
  const NewDataFormPage({super.key});
  @override
  State<NewDataFormPage> createState() => _NewDataFormPageState();
}

class _NewDataFormPageState extends State<NewDataFormPage> {
  late final FormConfig formConfig;

  // 添加表单的GlobalKey
  final GlobalKey<State<ConfigForm>> _formKey = GlobalKey<State<ConfigForm>>();

  @override
  void initState() {
    super.initState();
    // 创建表单配置，使用整合后的ConfigForm组件
    formConfig = FormConfig(
      title: '个人信息表单',
      description: '请填写您的个人信息，带*号的为必填项',
      fields: [
        FormFieldConfig(name: 'name', type: FormFieldType.text, label: '姓名', required: true, defaultValue: '张三'),
        FormFieldConfig(name: 'age', type: FormFieldType.integer, label: '年龄', required: true, defaultValue: 25),
        FormFieldConfig(name: 'height', type: FormFieldType.double, label: '身高', required: true, defaultValue: 1.75),
        FormFieldConfig(
          name: 'gender',
          type: FormFieldType.radio,
          label: '性别',
          required: true,
          defaultValue: 'male',
          options: [
            SelectData(label: '男', value: 'male', data: 'male'),
            SelectData(label: '女', value: 'female', data: 'female'),
          ],
        ),
        FormFieldConfig(
          name: 'hobbies',
          type: FormFieldType.checkbox,
          label: '兴趣爱好',
          required: false,
          defaultValue: ['reading'],
          options: [
            SelectData(label: '阅读', value: 'reading', data: 'reading'),
            SelectData(label: '运动', value: 'sports', data: 'sports'),
            SelectData(label: '音乐', value: 'music', data: 'music'),
            SelectData(label: '旅行', value: 'travel', data: 'travel'),
          ],
        ),
        FormFieldConfig(
          name: 'city',
          type: FormFieldType.select,
          label: '城市',
          required: true,
          defaultValue: 'beijing',
          options: [
            SelectData(label: '北京', value: 'beijing', data: 'beijing'),
            SelectData(label: '上海', value: 'shanghai', data: 'shanghai'),
            SelectData(label: '广州', value: 'guangzhou', data: 'guangzhou'),
            SelectData(label: '深圳', value: 'shenzhen', data: 'shenzhen'),
          ],
        ),
        FormFieldConfig(name: 'newsletter', type: FormFieldType.switch_, label: '订阅新闻', required: false, defaultValue: true),
        FormFieldConfig(name: 'birthday', type: FormFieldType.date, label: '生日', required: false, placeholder: '请选择您的生日'),
        FormFieldConfig(name: 'preferredTime', type: FormFieldType.time, label: '偏好时间', required: false, placeholder: '请选择您偏好的时间'),
        FormFieldConfig(name: 'meetingDate', type: FormFieldType.date, label: '会议日期', required: true, placeholder: '请选择会议日期'),
        FormFieldConfig(name: 'meetingTime', type: FormFieldType.time, label: '会议时间', required: true, placeholder: '请选择会议时间'),
        FormFieldConfig(name: 'satisfaction', type: FormFieldType.slider, label: '满意度', required: false, defaultValue: 7.5),
      ],
    );
  }

  void _handleSubmit(Map<String, dynamic> formData) {
    // 显示提交的数据
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('表单数据'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: formData.isEmpty
                ? [
                    const Text(
                      '暂无数据',
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ]
                : formData.entries.map((entry) {
                    final value = entry.value;
                    final displayValue = value == null ? "未填写" : value.toString();

                    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('${entry.key}: $displayValue'));
                  }).toList(),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('确定'))],
      ),
    );
  }

  // 外部验证表单
  void _validateFormExternally() {
    if (_formKey.currentState != null) {
      final formState = _formKey.currentState as dynamic;
      if (formState.validateForm != null) {
        final isValid = formState.validateForm();
        if (isValid) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ 表单验证通过！'), backgroundColor: Colors.green));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ 表单验证失败，请检查必填项'), backgroundColor: Colors.red));
        }
      }
    }
  }

  // 外部重置表单
  void _resetFormExternally() {
    if (_formKey.currentState != null) {
      final formState = _formKey.currentState as dynamic;
      if (formState.resetForm != null) {
        formState.resetForm();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔄 表单已重置'), backgroundColor: Colors.blue));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('整合后的表单示例'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 外部控制按钮
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('外部控制', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _validateFormExternally,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('验证表单'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _resetFormExternally,
                          icon: const Icon(Icons.refresh),
                          label: const Text('重置表单'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 表单组件
            ConfigForm(key: _formKey, formConfig: formConfig, onSubmit: _handleSubmit),
          ],
        ),
      ),
    );
  }
}
