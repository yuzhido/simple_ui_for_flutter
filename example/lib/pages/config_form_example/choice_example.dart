import 'package:flutter/material.dart';
import 'package:simple_ui/models/field_configs.dart';
import 'package:simple_ui/simple_ui.dart';

class ChoiceFieldsExamplePage extends StatefulWidget {
  const ChoiceFieldsExamplePage({super.key});

  @override
  State<ChoiceFieldsExamplePage> createState() => _ChoiceFieldsExamplePageState();
}

class _ChoiceFieldsExamplePageState extends State<ChoiceFieldsExamplePage> {
  Map<String, dynamic> _formData = {};

  List<FormConfig> get _formConfigs => [
    // 单选
    FormConfig.radio<String>(
      RadioFieldConfig<String>(
        name: 'gender',
        label: '性别',
        required: true,
        defaultValue: 'male',
        options: const [
          SelectData(value: 'male', data: 'male_data', label: '男'),
          SelectData(value: 'female', data: 'female_data', label: '女'),
        ],
      ),
    ),
    // 多选
    FormConfig.checkbox<String>(
      CheckboxFieldConfig<String>(
        name: 'hobbies',
        label: '兴趣爱好',
        required: false,
        defaultValue: 'reading,music',
        options: const [
          SelectData(value: 'reading', data: 'reading_data', label: '阅读'),
          SelectData(value: 'music', data: 'music_data', label: '音乐'),
          SelectData(value: 'sports', data: 'sports_data', label: '运动'),
          SelectData(value: 'travel', data: 'travel_data', label: '旅行'),
        ],
      ),
    ),
    // 下拉 - 单选
    FormConfig.select<String>(
      SelectFieldConfig<String>(
        name: 'city',
        label: '所在城市',
        required: true,
        options: const [
          SelectData(value: 'beijing', data: 'beijing_data', label: '北京'),
          SelectData(value: 'shanghai', data: 'shanghai_data', label: '上海'),
          SelectData(value: 'guangzhou', data: 'guangzhou_data', label: '广州'),
          SelectData(value: 'shenzhen', data: 'shenzhen_data', label: '深圳'),
        ],
      ),
    ),
    // 下拉 - 多选
    FormConfig.select<String>(
      SelectFieldConfig<String>(
        name: 'tags',
        label: '个人标签',
        multiple: true,
        searchable: false,
        options: const [
          SelectData(value: 'diligent', data: 'diligent_data', label: '勤奋'),
          SelectData(value: 'creative', data: 'creative_data', label: '有创意'),
          SelectData(value: 'team', data: 'team_data', label: '团队协作'),
          SelectData(value: 'lead', data: 'lead_data', label: '领导力'),
        ],
      ),
    ),
    // 数字类型示例
    FormConfig.select<int>(
      SelectFieldConfig<int>(
        name: 'priority',
        label: '优先级',
        required: true,
        options: const [
          SelectData(value: '1', data: 1, label: '低'),
          SelectData(value: '2', data: 2, label: '中'),
          SelectData(value: '3', data: 3, label: '高'),
          SelectData(value: '4', data: 4, label: '紧急'),
        ],
      ),
    ),
  ];

  void _onFormChanged(Map<String, dynamic> data) {
    setState(() => _formData = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Radio / Checkbox / Select 示例'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConfigForm(
              configs: _formConfigs,
              onChanged: _onFormChanged,
              submitBuilder: (formData) => Column(
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('提交成功：${formData.toString()}'), backgroundColor: Colors.green));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: const Text('提交表单'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
          ],
        ),
      ),
    );
  }
}
