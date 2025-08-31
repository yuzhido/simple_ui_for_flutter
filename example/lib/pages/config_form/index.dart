import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';

class ConfigFormPage extends StatefulWidget {
  const ConfigFormPage({super.key});
  @override
  State<ConfigFormPage> createState() => _ConfigFormPageState();
}

class _ConfigFormPageState extends State<ConfigFormPage> {
  late final FormConfig formConfig;

  @override
  void initState() {
    super.initState();

    // 创建FormConfig对象
    formConfig = FormConfig(
      title: '数据驱动表单演示',
      description: '这是一个数据驱动表单演示，通过配置信息动态生成表单字段',
      submitButtonText: '提交',
      fields: [
        FormFieldConfig(label: '姓名', name: 'name', type: FormFieldType.text, required: true),
        FormFieldConfig(label: '年龄', name: 'age', type: FormFieldType.integer, required: true),
        FormFieldConfig(label: '身高', name: 'height', type: FormFieldType.double, required: false),
        FormFieldConfig(
          label: '性别',
          name: 'gender',
          type: FormFieldType.select,
          required: true,
          options: [
            SelectData(label: '男', value: '男', data: '男'),
            SelectData(label: '女', value: '女', data: '女'),
          ],
        ),
        FormFieldConfig(
          label: '爱好',
          name: 'hobby',
          type: FormFieldType.checkbox,
          required: true,
          options: [
            SelectData(label: '读书', value: '读书', data: '读书'),
            SelectData(label: '旅游', value: '旅游', data: '旅游'),
            SelectData(label: '美食', value: '美食', data: '美食'),
            SelectData(label: '运动', value: '运动', data: '运动'),
            SelectData(label: '音乐', value: '音乐', data: '音乐'),
          ],
        ),
        FormFieldConfig(
          label: '职业',
          name: 'profession',
          type: FormFieldType.radio,
          required: true,
          options: [
            SelectData(label: '程序员', value: '程序员', data: '程序员'),
            SelectData(label: '设计师', value: '设计师', data: '设计师'),
            SelectData(label: '产品经理', value: '产品经理', data: '产品经理'),
            SelectData(label: '运营', value: '运营', data: '运营'),
            SelectData(label: '销售', value: '销售', data: '销售'),
          ],
        ),
        FormFieldConfig(
          label: '城市',
          name: 'city',
          type: FormFieldType.select,
          required: true,
          options: [
            SelectData(label: '北京', value: '北京', data: '北京'),
            SelectData(label: '上海', value: '上海', data: '上海'),
            SelectData(label: '广州', value: '广州', data: '广州'),
            SelectData(label: '深圳', value: '深圳', data: '深圳'),
            SelectData(label: '杭州', value: '杭州', data: '杭州'),
            SelectData(label: '成都', value: '成都', data: '成都'),
          ],
        ),
        FormFieldConfig(label: '邮箱', name: 'email', type: FormFieldType.text, required: true, placeholder: '请输入邮箱地址', validationRule: 'email'),
        FormFieldConfig(label: '上传文件', name: 'files', type: FormFieldType.upload, required: false),
        FormFieldConfig(label: '个人简介', name: 'bio', type: FormFieldType.textarea, required: false),
      ],
    );
  }

  Map<String, dynamic>? _formData;

  void _handleSubmit(Map<String, dynamic> data) {
    setState(() {
      _formData = data;
    });

    // 显示提交结果
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('表单提交成功'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: data.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text('${entry.key}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Text(entry.value?.toString() ?? 'null', style: TextStyle(color: entry.value == null ? Colors.grey : Colors.black)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('确定'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('数据驱动表单演示'), backgroundColor: const Color(0xFF007AFF), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 使用动态表单组件
            ConfigForm(formConfig: formConfig, onSubmit: _handleSubmit),

            // 显示表单数据
            if (_formData != null) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text('表单数据预览：', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
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
                  children: _formData!.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text('${entry.key}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            child: Text(entry.value?.toString() ?? 'null', style: TextStyle(color: entry.value == null ? Colors.grey : Colors.black)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
