import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';
import 'package:simple_ui/simple_ui.dart';

class FormBuilderDemo extends StatefulWidget {
  const FormBuilderDemo({super.key});

  @override
  State<FormBuilderDemo> createState() => _FormBuilderDemoState();
}

class _FormBuilderDemoState extends State<FormBuilderDemo> {
  final FormBuilderController _controller = FormBuilderController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 示例配置
  final List<FormBuilderConfig> _configs = [
    FormBuilderConfig(name: 'name', label: '姓名', type: FormBuilderType.text, required: true, defaultValue: ''),
    FormBuilderConfig(name: 'age', label: '年龄', type: FormBuilderType.integer, required: true, defaultValue: null),
    FormBuilderConfig(name: 'salary', label: '薪资', type: FormBuilderType.number, required: false, defaultValue: null),
    FormBuilderConfig(name: 'description', label: '个人描述', type: FormBuilderType.textarea, required: false, defaultValue: ''),
    FormBuilderConfig(name: 'birthday', label: '生日', type: FormBuilderType.date, required: false, defaultValue: null),
    FormBuilderConfig(name: 'workTime', label: '工作时间', type: FormBuilderType.time, required: false, defaultValue: null),
    FormBuilderConfig(name: 'appointment', label: '预约时间', type: FormBuilderType.datetime, required: false, defaultValue: null),
    FormBuilderConfig.radio(
      name: 'gender',
      label: '性别',
      required: true,
      defaultValue: null,
      options: const [
        SelectOption(label: '男', value: 'male'),
        SelectOption(label: '女', value: 'female'),
        SelectOption(label: '其他', value: 'other'),
      ],
    ),
    FormBuilderConfig.checkbox(
      name: 'hobbies',
      label: '爱好',
      required: false,
      defaultValue: [],
      options: const [
        SelectOption(label: '阅读', value: 'reading'),
        SelectOption(label: '运动', value: 'sports'),
        SelectOption(label: '音乐', value: 'music'),
        SelectOption(label: '旅行', value: 'travel'),
        SelectOption(label: '游戏', value: 'gaming'),
      ],
    ),
    FormBuilderConfig.select(
      name: 'city',
      label: '城市',
      required: false,
      defaultValue: null,
      placeholder: '请选择城市',
      options: const [
        SelectOption(label: '北京', value: 'beijing'),
        SelectOption(label: '上海', value: 'shanghai'),
        SelectOption(label: '广州', value: 'guangzhou'),
        SelectOption(label: '深圳', value: 'shenzhen'),
        SelectOption(label: '杭州', value: 'hangzhou'),
        SelectOption(label: '成都', value: 'chengdu'),
      ],
    ),
    FormBuilderConfig.dropdown(
      name: 'skills',
      label: '技能',
      required: false,
      defaultValue: null,
      placeholder: '请选择技能',
      multiple: true,
      filterable: true,
      options: const [
        SelectOption(label: 'Flutter', value: 'flutter'),
        SelectOption(label: 'Dart', value: 'dart'),
        SelectOption(label: 'React', value: 'react'),
        SelectOption(label: 'Vue', value: 'vue'),
        SelectOption(label: 'Angular', value: 'angular'),
        SelectOption(label: 'Node.js', value: 'nodejs'),
        SelectOption(label: 'Python', value: 'python'),
        SelectOption(label: 'Java', value: 'java'),
      ],
    ),
    FormBuilderConfig.upload(
      name: 'avatar',
      label: '头像',
      required: false,
      defaultValue: [],
      uploadText: '上传头像',
      listType: UploadListType.card,
      limit: 3,
      fileSource: FileSource.imageOrCamera,
    ),
    FormBuilderConfig(name: 'customField', label: '自定义字段', type: FormBuilderType.custom, required: false, defaultValue: null),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FormBuilder 示例'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(
            child: FormBuilder(configs: _configs, controller: _controller, formKey: _formKey, autovalidate: true),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetForm,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white),
                    child: const Text('重置'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    child: const Text('提交'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _controller.reset(_configs);
    _formKey.currentState?.reset();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final values = _controller.values;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('表单数据'),
          content: SingleChildScrollView(child: Text(values.entries.map((e) => '${e.key}: ${e.value}').join('\n'))),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('确定'))],
        ),
      );
    }
  }
}
