import 'package:example/models/city.dart';
import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  // 远程获取城市数据
  Future<List<SelectData<City>>> _loadCities(String? keyword) async {
    try {
      final cities = await UserService.getCities(null);

      // 将City对象转换为SelectData格式
      return cities.map((city) => SelectData<City>(label: city.name, value: city.name, data: city)).toList();
    } catch (e) {
      print('加载城市列表失败: $e');
      return [];
    }
  }

  // 表单配置 - 改为方法而不是getter，确保能获取到最新的城市数据
  FormConfig _getFormConfig() {
    return FormConfig(
      title: '新增用户',
      description: '请填写用户的基本信息',
      fields: [
        FormFieldConfig(name: 'name', label: '姓名', type: FormFieldType.text, required: true, placeholder: '请输入用户姓名'),
        FormFieldConfig(
          name: 'gender',
          label: '性别',
          type: FormFieldType.radio,
          required: true,
          options: [
            SelectData(label: '男', value: 'male', data: 'male'),
            SelectData(label: '女', value: 'female', data: 'female'),
          ],
        ),
        FormFieldConfig(name: 'age', label: '年龄', type: FormFieldType.number, required: true, placeholder: '请输入年龄'),
        FormFieldConfig(name: 'occupation', label: '职业', type: FormFieldType.text, required: true, placeholder: '请输入职业'),
        FormFieldConfig(
          name: 'education',
          label: '教育背景',
          type: FormFieldType.select,
          required: true,
          options: [
            SelectData(label: '高中', value: 'high_school', data: 'high_school'),
            SelectData(label: '专科', value: 'college', data: 'college'),
            SelectData(label: '本科', value: 'bachelor', data: 'bachelor'),
            SelectData(label: '硕士', value: 'master', data: 'master'),
            SelectData(label: '博士', value: 'phd', data: 'phd'),
          ],
        ),
        FormFieldConfig(
          name: 'city',
          label: '城市',
          type: FormFieldType.select,
          required: true,
          remote: true,
          remoteFetch: _loadCities, // 使用远程获取城市列表
          placeholder: '请选择所在城市',
        ),
        FormFieldConfig(
          name: 'hobbies',
          label: '爱好',
          type: FormFieldType.checkbox,
          required: false,
          options: [
            SelectData(label: '编程', value: 'programming', data: 'programming'),
            SelectData(label: '阅读', value: 'reading', data: 'reading'),
            SelectData(label: '旅行', value: 'traveling', data: 'traveling'),
            SelectData(label: '摄影', value: 'photography', data: 'photography'),
            SelectData(label: '音乐', value: 'music', data: 'music'),
            SelectData(label: '运动', value: 'sports', data: 'sports'),
            SelectData(label: '烹饪', value: 'cooking', data: 'cooking'),
            SelectData(label: '绘画', value: 'painting', data: 'painting'),
          ],
        ),
        FormFieldConfig(name: 'avatar', label: '头像链接', type: FormFieldType.text, required: false, placeholder: '请输入头像图片链接（可选）'),
        FormFieldConfig(name: 'introduction', label: '个人介绍', type: FormFieldType.textarea, required: false, placeholder: '请输入个人介绍（可选）'),
        FormFieldConfig(name: 'submit', label: '提交', type: FormFieldType.button, required: false),
      ],
    );
  }

  Future<void> _handleSubmit(Map<String, dynamic> formData) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // 处理爱好数据
      List<String> hobbies = [];
      if (formData['hobbies'] != null) {
        hobbies = List<String>.from(formData['hobbies']);
      }

      // 创建用户对象
      final user = User(
        name: formData['name'] ?? '',
        gender: formData['gender'] ?? '',
        age: int.tryParse(formData['age']?.toString() ?? '0') ?? 0,
        occupation: formData['occupation'] ?? '',
        education: formData['education'] ?? '',
        hobbies: hobbies,
        avatar: formData['avatar'] ?? '',
        introduction: formData['introduction'] ?? '',
        city: formData['city'] ?? '',
      );

      // 调用API保存用户数据
      final createdUser = await UserService.createUser(user);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('用户添加成功！'), backgroundColor: Colors.green));

        // 返回上一页
        Navigator.pop(context, createdUser);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('添加失败: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新增用户'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConfigForm(formConfig: _getFormConfig(), onSubmit: _handleSubmit),
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
