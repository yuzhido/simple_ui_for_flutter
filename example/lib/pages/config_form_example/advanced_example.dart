import 'package:flutter/material.dart';
import 'package:simple_ui/models/field_configs.dart';
import 'package:simple_ui/simple_ui.dart';

/// 高级配置示例页面
/// 展示新的配置系统如何让不同字段类型有专门的属性
class AdvancedConfigExamplePage extends StatefulWidget {
  const AdvancedConfigExamplePage({super.key});

  @override
  State<AdvancedConfigExamplePage> createState() => _AdvancedConfigExamplePageState();
}

class _AdvancedConfigExamplePageState extends State<AdvancedConfigExamplePage> {
  Map<String, dynamic> _formData = {};

  // 展示不同字段类型的专门配置
  List<FormConfig> get _formConfigs => [
    // 文本字段 - 只有文本相关的属性
    FormConfig.text(TextFieldConfig(name: 'username', label: '用户名', required: true, defaultValue: 'admin', minLength: 3, maxLength: 20)),

    // 多行文本字段 - 有行数配置
    FormConfig.textarea(
      TextareaFieldConfig(
        name: 'description',
        label: '详细描述',
        required: false,
        minLength: 10,
        maxLength: 500,
        rows: 6, // 只有textarea才有这个属性
      ),
    ),

    // 数字字段 - 有小数位数限制
    FormConfig.number(
      NumberFieldConfig(
        name: 'price',
        label: '价格',
        required: true,
        defaultValue: 99.99,
        minValue: 0.01,
        maxValue: 9999.99,
        decimalPlaces: 2, // 只有数字字段才有这个属性
      ),
    ),

    // 整数字段 - 只有整数相关的属性
    FormConfig.integer(IntegerFieldConfig(name: 'quantity', label: '数量', required: true, defaultValue: 1, minValue: 1)),

    // 日期字段 - 有日期范围限制
    FormConfig.date(
      DateFieldConfig(
        name: 'startDate',
        label: '开始日期',
        required: true,
        minDate: DateTime.now(), // 只有日期字段才有这个属性
        maxDate: DateTime.now().add(const Duration(days: 365)),
        format: 'YYYY-MM-DD',
      ),
    ),

    // 单选字段 - 有选项配置
    FormConfig.radio(
      RadioFieldConfig(
        name: 'gender',
        label: '性别',
        required: true,
        defaultValue: 'male',
        options: const [
          SelectData(value: 'male', data: '', label: '男'),
          SelectData(value: 'female', data: '', label: '女'),
        ],
      ),
    ),

    // 多选字段 - 有选项配置
    FormConfig.checkbox(
      CheckboxFieldConfig(
        name: 'hobbies',
        label: '兴趣爱好',
        required: false,
        defaultValue: ['reading'],
        options: const [
          SelectData(value: 'reading', data: '', label: '阅读'),
          SelectData(value: 'music', data: '', label: '音乐'),
          SelectData(value: 'sports', data: '', label: '运动'),
          SelectData(value: 'travel', data: '', label: '旅行'),
        ],
      ),
    ),

    // 下拉选择字段 - 有搜索和多选配置
    FormConfig.select(
      SelectFieldConfig(
        name: 'city',
        label: '城市',
        required: true,
        multiple: false,
        searchable: true, // 只有下拉选择才有这个属性
        options: const [
          SelectData(value: 'beijing', data: '', label: '北京'),
          SelectData(value: 'shanghai', data: '', label: '上海'),
          SelectData(value: 'guangzhou', data: '', label: '广州'),
          SelectData(value: 'shenzhen', data: '', label: '深圳'),
        ],
      ),
    ),

    // 文件上传字段 - 有文件类型和大小限制
    FormConfig.upload(
      UploadFieldConfig(
        name: 'avatar',
        label: '头像',
        required: false,
        allowedTypes: ['jpg', 'jpeg', 'png', 'gif'], // 只有上传字段才有这个属性
        maxFileSize: 5 * 1024 * 1024, // 5MB
        maxFiles: 1,
        uploadUrl: '/api/upload',
      ),
    ),
  ];

  void _onFormChanged(Map<String, dynamic> data) {
    setState(() {
      _formData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('高级配置示例'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('新配置系统优势：', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              '• 每个字段类型都有专门的配置类\n'
              '• 只显示该字段类型相关的属性\n'
              '• 类型安全，避免配置错误\n'
              '• 代码更清晰，维护更容易',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ConfigForm(
              configs: _formConfigs,
              onChanged: _onFormChanged,
              submitBuilder: (formData) => Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('表单提交成功！')));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: const Text('提交表单'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
