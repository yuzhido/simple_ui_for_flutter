import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_type.dart';
import 'package:simple_ui/simple_ui.dart';

class ConfigFormExamplePage extends StatefulWidget {
  const ConfigFormExamplePage({super.key});
  @override
  State<ConfigFormExamplePage> createState() => _ConfigFormExamplePageState();
}

class _ConfigFormExamplePageState extends State<ConfigFormExamplePage> {
  late ConfigFormController _controller;
  Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    _controller = ConfigFormController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 表单配置
  List<FormConfig> get _formConfigs => [
    // 文本输入
    FormConfig(
      type: FormType.text,
      name: 'username',
      label: '用户名',
      required: true,
      defaultValue: 'admin',
      props: const TextFieldProps(minLength: 3, maxLength: 20, keyboardType: TextInputType.text),
    ),
    FormConfig<DropdownProps>(
      type: FormType.dropdown,
      name: 'username',
      label: '用户名',
      required: true,
      props: DropdownProps<String>(
        options: const [
          SelectData(label: '男', value: 'male', data: '男性'),
          SelectData(label: '女', value: 'female', data: '女性'),
          SelectData(label: '其他', value: 'other', data: '其他'),
        ],
      ),
    ),
    FormConfig<DropdownProps>(
      type: FormType.dropdown,
      name: 'username',
      label: '用户名',
      required: true,
      props: DropdownProps<String>(
        multiple: true,
        options: const [
          SelectData(label: '男', value: 'male', data: '男性'),
          SelectData(label: '女', value: 'female', data: '女性'),
          SelectData(label: '其他', value: 'other', data: '其他'),
        ],
      ),
    ),

    // 数字输入
    FormConfig(type: FormType.number, name: 'price', label: '价格', required: true, defaultValue: 99.99, props: const NumberProps(minValue: 0, maxValue: 9999.99, decimalPlaces: 2)),

    // 整数输入
    FormConfig(type: FormType.integer, name: 'quantity', label: '数量', required: true, defaultValue: 1, props: const IntegerProps(minValue: 1, maxValue: 100)),

    // 多行文本
    FormConfig(type: FormType.textarea, name: 'description', label: '描述', required: false, defaultValue: '这是一个示例描述', props: const TextareaProps(rows: 4, maxLength: 500)),

    // 单选
    FormConfig(
      type: FormType.radio,
      name: 'gender',
      label: '性别',
      required: true,
      defaultValue: 'male',
      props: RadioProps<String>(
        options: const [
          SelectData(label: '男', value: 'male', data: '男性'),
          SelectData(label: '女', value: 'female', data: '女性'),
          SelectData(label: '其他', value: 'other', data: '其他'),
        ],
      ),
    ),

    // 多选
    FormConfig(
      type: FormType.checkbox,
      name: 'hobbies',
      label: '爱好',
      required: false,
      defaultValue: ['reading', 'music'],
      props: CheckboxProps<String>(
        options: const [
          SelectData(label: '阅读', value: 'reading', data: '阅读'),
          SelectData(label: '音乐', value: 'music', data: '音乐'),
          SelectData(label: '运动', value: 'sports', data: '运动'),
          SelectData(label: '旅行', value: 'travel', data: '旅行'),
          SelectData(label: '摄影', value: 'photography', data: '摄影'),
        ],
      ),
    ),

    // 下拉选择
    FormConfig(
      type: FormType.select,
      name: 'city',
      label: '城市',
      required: true,
      defaultValue: 'beijing',
      props: SelectProps<String>(
        options: const [
          SelectData(label: '北京', value: 'beijing', data: '北京市'),
          SelectData(label: '上海', value: 'shanghai', data: '上海市'),
          SelectData(label: '广州', value: 'guangzhou', data: '广州市'),
          SelectData(label: '深圳', value: 'shenzhen', data: '深圳市'),
          SelectData(label: '杭州', value: 'hangzhou', data: '杭州市'),
        ],
      ),
    ),

    // 日期选择
    FormConfig(
      type: FormType.date,
      name: 'birthday',
      label: '生日',
      required: false,
      defaultValue: '1990-01-01',
      props: const DateProps(format: 'YYYY-MM-DD'),
    ),

    // 时间选择
    FormConfig(
      type: FormType.time,
      name: 'meeting_time',
      label: '会议时间',
      required: false,
      defaultValue: '14:30',
      props: const TimeProps(format: 'HH:mm'),
    ),

    // 日期时间选择
    FormConfig(
      type: FormType.datetime,
      name: 'created_at',
      label: '创建时间',
      required: false,
      defaultValue: '2024-01-01 10:00',
      props: const DateTimeProps(format: 'YYYY-MM-DD HH:mm'),
    ),
  ];

  // 表单数据变化回调
  void _onFormChanged(Map<String, dynamic> data) {
    setState(() {
      _formData = data;
    });
    print('表单数据变化: $data');
  }

  // 提交表单
  void _submitForm() {
    final formData = _controller.formData;
    print('提交表单数据: $formData');

    // 显示提交结果
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('表单提交'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('提交的数据:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...formData.entries.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('${entry.key}: ${entry.value}'))),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('确定'))],
      ),
    );
  }

  // 重置表单
  void _resetForm() {
    _controller.reset();
    setState(() {
      _formData = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ConfigForm 示例'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 表单标题
            const Text('ConfigForm 组件使用示例', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('这个示例展示了 ConfigForm 组件支持的各种表单字段类型', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),

            // 表单组件
            ConfigForm(configs: _formConfigs, controller: _controller, onChanged: _onFormChanged),

            const SizedBox(height: 24),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('提交表单'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetForm,
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('重置表单'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 实时数据显示
            if (_formData.isNotEmpty) ...[
              const Text('实时表单数据:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
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
                  children: _formData.entries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('${entry.key}: ${entry.value}', style: const TextStyle(fontFamily: 'monospace')),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
