import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataForFormPage extends StatefulWidget {
  const DataForFormPage({super.key});
  @override
  State<DataForFormPage> createState() => _DataForFormPageState();
}

class _DataForFormPageState extends State<DataForFormPage> {
  late final FormConfig formConfig;

  // 添加表单的GlobalKey，用于外部调用验证方法
  final GlobalKey<State<ConfigForm>> _formKey = GlobalKey<State<ConfigForm>>();

  // 添加验证状态
  bool _isFormValid = false;
  Map<String, String?> _currentErrors = {};

  @override
  void initState() {
    super.initState();

    // 使用新的类型约束创建表单配置
    formConfig = FormConfig(
      title: '用户信息表单',
      description: '请填写您的个人信息',
      submitButtonText: '提交信息',
      fields: [
        FormFieldConfig(label: '姓名', name: 'name', type: FormFieldType.text, required: true, placeholder: '请输入您的姓名', defaultValue: '张三'),
        FormFieldConfig(label: '年龄', name: 'age', type: FormFieldType.number, required: true, placeholder: '请输入您的年龄', defaultValue: 25),
        FormFieldConfig(label: '身高', name: 'height', type: FormFieldType.double, required: true, placeholder: '请输入您的身高(米)', defaultValue: 1.75),
        FormFieldConfig(
          label: '性别',
          name: 'gender',
          type: FormFieldType.radio,
          required: true,
          options: [
            SelectData(label: '男', value: 'male', data: 'male'),
            SelectData(label: '女', value: 'female', data: 'female'),
          ],
          defaultValue: 'male',
        ),
        FormFieldConfig(
          label: '学历',
          name: 'education',
          type: FormFieldType.checkbox,
          options: [
            SelectData(label: '小学', value: 'primary', data: 'primary'),
            SelectData(label: '初中', value: 'junior', data: 'junior'),
            SelectData(label: '高中', value: 'senior', data: 'senior'),
            SelectData(label: '大学', value: 'university', data: 'university'),
          ],
        ),
        FormFieldConfig(
          label: '职业',
          name: 'profession',
          type: FormFieldType.select,
          required: true,
          options: [
            SelectData(label: '医生', value: 'doctor', data: 'doctor'),
            SelectData(label: '教师', value: 'teacher', data: 'teacher'),
            SelectData(label: '工程师', value: 'engineer', data: 'engineer'),
            SelectData(label: '律师', value: 'lawyer', data: 'lawyer'),
            SelectData(label: '设计师', value: 'designer', data: 'designer'),
            SelectData(label: '销售', value: 'sales', data: 'sales'),
            SelectData(label: '市场', value: 'marketing', data: 'marketing'),
            SelectData(label: '财务', value: 'finance', data: 'finance'),
            SelectData(label: '人力资源', value: 'hr', data: 'hr'),
            SelectData(label: '运营', value: 'operations', data: 'operations'),
          ],
          filterable: true,
          placeholder: '请选择您的职业',
          defaultValue: SelectData(label: '工程师', value: 'engineer', data: 'engineer'),
        ),
        FormFieldConfig(
          label: '测试本地搜索',
          name: 'test_local',
          type: FormFieldType.select,
          required: false,
          options: [
            SelectData(label: '苹果', value: 'apple', data: 'apple'),
            SelectData(label: '香蕉', value: 'banana', data: 'banana'),
            SelectData(label: '橙子', value: 'orange', data: 'orange'),
            SelectData(label: '葡萄', value: 'grape', data: 'grape'),
            SelectData(label: '草莓', value: 'strawberry', data: 'strawberry'),
            SelectData(label: '蓝莓', value: 'blueberry', data: 'blueberry'),
            SelectData(label: '樱桃', value: 'cherry', data: 'cherry'),
            SelectData(label: '桃子', value: 'peach', data: 'peach'),
            SelectData(label: '梨子', value: 'pear', data: 'pear'),
            SelectData(label: '西瓜', value: 'watermelon', data: 'watermelon'),
          ],
          filterable: true,
          placeholder: '请输入关键字自动筛选',
        ),
        FormFieldConfig(
          label: '城市',
          name: 'city',
          type: FormFieldType.select,
          required: true,
          remote: true,
          remoteFetch: (keyword) => _fetchCities(keyword),
          placeholder: '请选择您的城市',
          defaultValue: SelectData<String>(label: '广州', value: 'guangzhou', data: 'guangzhou'),
        ),
        FormFieldConfig(
          label: '技能',
          name: 'skills',
          type: FormFieldType.select,
          required: true,
          multiple: true,
          remote: true,
          remoteFetch: (keyword) => _fetchSkills(keyword),
          placeholder: '请选择您的技能（可多选）',
          defaultValue: [
            SelectData<String>(label: 'Flutter开发', value: 'flutter', data: 'flutter'),
            SelectData<String>(label: 'React开发', value: 'react', data: 'react'),
          ],
        ),
        FormFieldConfig(
          label: '待办事项',
          name: 'todos',
          type: FormFieldType.select,
          required: true,
          remote: true,
          remoteFetch: (keyword) => _fetchTodos(keyword),
          placeholder: '请选择您的待办事项',
        ),
        FormFieldConfig(
          label: '多选待办事项',
          name: 'multiple_todos',
          type: FormFieldType.select,
          required: true,
          multiple: true,
          remote: true,
          remoteFetch: (keyword) => _fetchTodos(keyword),
          placeholder: '请选择多个待办事项（可多选）',
        ),
        FormFieldConfig(
          label: '兴趣爱好',
          name: 'hobbies',
          type: FormFieldType.checkbox,
          required: true,
          options: [
            SelectData(label: '阅读', value: 'reading', data: 'reading'),
            SelectData(label: '写作', value: 'writing', data: 'writing'),
            SelectData(label: '编程', value: 'programming', data: 'programming'),
            SelectData(label: '音乐', value: 'music', data: 'music'),
            SelectData(label: '电影', value: 'movie', data: 'movie'),
          ],
          defaultValue: ['reading', 'programming'],
        ),
        FormFieldConfig(
          label: '自我介绍',
          name: 'introduction',
          type: FormFieldType.textarea,
          required: true,
          placeholder: '请简单介绍一下自己...',
          defaultValue: '我是一名热爱编程的开发者，喜欢学习新技术。',
        ),
        FormFieldConfig(label: '提交', name: 'submit', type: FormFieldType.button, required: false),
      ],
    );
  }

  // 模拟从后端获取城市数据
  Future<List<SelectData<String>>> _fetchCities(String? keyword) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      SelectData<String>(label: '北京', value: 'beijing', data: 'beijing'),
      SelectData<String>(label: '上海', value: 'shanghai', data: 'shanghai'),
      SelectData<String>(label: '广州', value: 'guangzhou', data: 'guangzhou'),
      SelectData<String>(label: '深圳', value: 'shenzhen', data: 'shenzhen'),
      SelectData<String>(label: '杭州', value: 'hangzhou', data: 'hangzhou'),
      SelectData<String>(label: '南京', value: 'nanjing', data: 'nanjing'),
      SelectData<String>(label: '成都', value: 'chengdu', data: 'chengdu'),
      SelectData<String>(label: '武汉', value: 'wuhan', data: 'wuhan'),
      SelectData<String>(label: '西安', value: 'xian', data: 'xian'),
      SelectData<String>(label: '重庆', value: 'chongqing', data: 'chongqing'),
    ];
  }

  // 模拟从后端获取技能数据
  Future<List<SelectData<String>>> _fetchSkills(String? keyword) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      SelectData<String>(label: 'Flutter开发', value: 'flutter', data: 'flutter'),
      SelectData<String>(label: 'React开发', value: 'react', data: 'react'),
      SelectData<String>(label: 'Vue开发', value: 'vue', data: 'vue'),
      SelectData<String>(label: 'Java开发', value: 'java', data: 'java'),
      SelectData<String>(label: 'Python开发', value: 'python', data: 'python'),
      SelectData<String>(label: 'UI设计', value: 'ui_design', data: 'ui_design'),
      SelectData<String>(label: '产品经理', value: 'product_manager', data: 'product_manager'),
      SelectData<String>(label: '数据分析', value: 'data_analysis', data: 'data_analysis'),
      SelectData<String>(label: '项目管理', value: 'project_management', data: 'project_management'),
      SelectData<String>(label: '测试工程师', value: 'test_engineer', data: 'test_engineer'),
    ];
  }

  // 从真实API获取待办事项数据
  Future<List<SelectData<String>>> _fetchTodos(String? keyword) async {
    try {
      // 从 https://jsonplaceholder.typicode.com/todos 获取数据
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos'));

      if (response.statusCode == 200) {
        final List<dynamic> todos = json.decode(response.body);

        // 将API数据转换为SelectData格式
        return todos.map((todo) {
          final completed = todo['completed'] as bool;
          final title = todo['title'] as String;
          final id = todo['id'] as int;

          // 添加完成状态到标签中
          final label = completed ? '✅ $title' : '⏳ $title';

          return SelectData<String>(label: label, value: id.toString(), data: title);
        }).toList();
      } else {
        throw Exception('获取数据失败: ${response.statusCode}');
      }
    } catch (e) {
      print('获取待办事项数据时出错: $e');
      // 返回空列表或默认数据
      return [SelectData<String>(label: '获取数据失败', value: 'error', data: 'error')];
    }
  }

  // 外部验证表单的方法
  void _validateFormExternally() {
    if (_formKey.currentState != null) {
      // 通过GlobalKey调用表单的验证方法
      final formState = _formKey.currentState as dynamic;
      if (formState.validateForm != null) {
        final isValid = formState.validateForm();
        print('外部验证结果: $isValid');

        if (isValid) {
          // 获取表单数据
          final formData = formState.getFormData();
          print('表单数据: $formData');

          // 显示成功消息
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('表单验证通过！'), backgroundColor: Colors.green));
        } else {
          // 获取错误信息
          final errors = formState.getErrors();
          print('验证错误: $errors');

          // 显示错误消息
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('表单验证失败，请检查错误信息'), backgroundColor: Colors.red));
        }
      }
    }
  }

  // 外部重置表单的方法
  void _resetFormExternally() {
    if (_formKey.currentState != null) {
      final formState = _formKey.currentState as dynamic;
      if (formState.resetForm != null) {
        formState.resetForm();
        print('表单已重置');

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('表单已重置'), backgroundColor: Colors.blue));
      }
    }
  }

  // 获取表单数据的方法
  void _getFormDataExternally() {
    if (_formKey.currentState != null) {
      final formState = _formKey.currentState as dynamic;
      if (formState.getFormData != null) {
        try {
          final formData = formState.getFormData();
          print('当前表单数据: $formData');
          print('数据类型: ${formData.runtimeType}');
          print('数据长度: ${formData.length}');

          // 显示数据对话框
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('当前表单数据'),
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
        } catch (e) {
          print('获取表单数据时出错: $e');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('获取数据失败: $e'), backgroundColor: Colors.red));
        }
      } else {
        print('getFormData方法不存在');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('获取数据方法不存在'), backgroundColor: Colors.red));
      }
    } else {
      print('表单状态为空');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('表单状态为空'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('跳转查看数据驱动表单（DataForForm）示例')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 外部控制按钮区域
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '外部控制区域',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                  ),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _getFormDataExternally,
                          icon: const Icon(Icons.data_usage),
                          label: const Text('获取数据'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isFormValid ? Colors.green.shade100 : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: _isFormValid ? Colors.green.shade300 : Colors.red.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_isFormValid ? Icons.check_circle : Icons.error, color: _isFormValid ? Colors.green : Colors.red, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                _isFormValid ? '验证通过' : '验证失败',
                                style: TextStyle(
                                  color: _isFormValid ? Colors.green.shade700 : Colors.red.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_currentErrors.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '当前错误信息:',
                            style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          ..._currentErrors.entries.map(
                            (entry) => Text('• ${entry.key}: ${entry.value}', style: TextStyle(color: Colors.red.shade600, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 表单组件
            ConfigForm(
              key: _formKey,
              formConfig: formConfig,
              onValidationChanged: (isValid, errors) {
                setState(() {
                  _isFormValid = isValid;
                  _currentErrors = errors;
                });
                print('验证状态变化: isValid=$isValid, errors=$errors');
              },
              onSubmit: (formData) {
                print('表单数据: $formData');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('表单提交成功！数据: $formData')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
