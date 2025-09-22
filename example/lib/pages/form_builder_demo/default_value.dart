import 'package:flutter/material.dart';
import 'package:simple_ui/models/file_upload.dart';
import 'package:simple_ui/models/form_builder_config.dart';
import 'package:simple_ui/simple_ui.dart';

class DefaultValuePage extends StatefulWidget {
  const DefaultValuePage({super.key});
  @override
  State<DefaultValuePage> createState() => _DefaultValuePageState();
}

class _DefaultValuePageState extends State<DefaultValuePage> {
  final FormBuilderController _controller = FormBuilderController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<FormBuilderConfig> _configs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndInitConfigs();
  }

  // 模拟从后端获取用户数据
  Future<Map<String, dynamic>> _fetchUserDataFromBackend() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 2));

    // 模拟返回的用户数据
    return {
      'name': '张三',
      'age': 28,
      'salary': 15000.50,
      'description': '这是一个经验丰富的Flutter开发工程师，擅长移动端应用开发。',
      'birthday': '1995-06-15',
      'workTime': '09:00',
      'appointment': '2024-01-20 14:30',
      'gender': 'male',
      'hobbies': ['reading', 'sports', 'music'],
      'city': 'shanghai',
      'skills': <SelectData<String>>[
        const SelectData<String>(label: 'Flutter', value: 'flutter', data: '122'),
        const SelectData<String>(label: 'Dart', value: 'dart', data: '122'),
        const SelectData<String>(label: 'React', value: 'react', data: '122'),
      ],
      'avatar': [FileInfo(id: 1, fileName: 'user_avatar.jpg', requestPath: 'https://img2.baidu.com/it/u=3462817521,2900083400&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=558')],
    };
  }

  // 加载用户数据并初始化表单配置
  Future<void> _loadUserDataAndInitConfigs() async {
    try {
      final userData = await _fetchUserDataFromBackend();
      _initConfigsWithDefaultValues(userData);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('加载用户数据失败: $e')));
      }
    }
  }

  void _initConfigsWithDefaultValues(Map<String, dynamic> userData) {
    _configs = [
      FormBuilderConfig(name: 'name', label: '姓名', type: FormBuilderType.text, required: true, defaultValue: userData['name'] ?? ''),
      FormBuilderConfig(name: 'age', label: '年龄', type: FormBuilderType.integer, required: true, defaultValue: userData['age']),
      FormBuilderConfig(name: 'salary', label: '薪资', type: FormBuilderType.number, required: false, defaultValue: userData['salary']),
      FormBuilderConfig(name: 'description', label: '个人描述', type: FormBuilderType.textarea, required: false, defaultValue: userData['description'] ?? ''),
      FormBuilderConfig(
        name: 'birthday',
        label: '生日',
        type: FormBuilderType.date,
        required: false,
        defaultValue: userData['birthday'] != null ? DateTime.tryParse(userData['birthday']) : null,
      ),
      FormBuilderConfig(
        name: 'workTime',
        label: '工作时间',
        type: FormBuilderType.time,
        required: false,
        defaultValue: userData['workTime'] != null ? TimeOfDay(hour: int.parse(userData['workTime'].split(':')[0]), minute: int.parse(userData['workTime'].split(':')[1])) : null,
      ),
      FormBuilderConfig(
        name: 'appointment',
        label: '预约时间',
        type: FormBuilderType.datetime,
        required: false,
        defaultValue: userData['appointment'] != null ? DateTime.tryParse(userData['appointment']) : null,
      ),
      FormBuilderConfig.radio(
        name: 'gender',
        label: '性别',
        required: true,
        defaultValue: userData['gender'],
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
        defaultValue: userData['hobbies'] ?? [],
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
        defaultValue: userData['city'],
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
        defaultValue: userData['skills'],
        placeholder: '请选择技能',
        multiple: true,
        filterable: true,
        options: const [
          SelectData(label: 'Flutter', value: 'flutter', data: 'flutter'),
          SelectData(label: 'Dart', value: 'dart', data: 'dart'),
          SelectData(label: 'React', value: 'react', data: 'react'),
          SelectData(label: 'Vue', value: 'vue', data: 'vue'),
          SelectData(label: 'Angular', value: 'angular', data: 'angular'),
          SelectData(label: 'Node.js', value: 'nodejs', data: 'nodejs'),
          SelectData(label: 'Python', value: 'python', data: 'python'),
          SelectData(label: 'Java', value: 'java', data: 'java'),
        ],
      ),
      FormBuilderConfig.upload(name: 'avatar', label: '头像', required: false, defaultValue: userData['avatar'] ?? [], limit: 3, fileSource: FileSource.imageOrCamera),
    ];

    // 调试信息
    print('Skills default value: ${userData['skills']}');
    print('Skills default value type: ${userData['skills'].runtimeType}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('自定义显示表单默认值'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: _isLoading
          ? const Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('正在加载用户数据...')]),
            )
          : Column(
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
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          child: const Text('提交'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _reloadData,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                          child: const Text('重新加载'),
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

  void _reloadData() {
    setState(() {
      _isLoading = true;
    });
    _loadUserDataAndInitConfigs();
  }
}
