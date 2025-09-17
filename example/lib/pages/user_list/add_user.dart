import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';
import 'package:simple_ui/simple_ui.dart';
import '../../api/user_api.dart';
import '../../api/models/user.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});
  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FormBuilderController _controller = FormBuilderController();
  bool _isSubmitting = false;

  // 表单配置
  List<FormBuilderConfig> get _formConfigs => [
    FormBuilderConfig(name: 'name', label: '姓名', type: FormBuilderType.text, required: true, placeholder: '请输入姓名'),
    FormBuilderConfig(name: 'age', label: '年龄', type: FormBuilderType.integer, required: true, placeholder: '请输入年龄'),
    FormBuilderConfig(name: 'address', label: '地址', type: FormBuilderType.text, required: true, placeholder: '请输入地址'),
    FormBuilderConfig(name: 'school', label: '学校', type: FormBuilderType.text, required: true, placeholder: '请输入学校'),
    FormBuilderConfig(name: 'birthday', label: '生日', type: FormBuilderType.date, required: true, placeholder: '请选择生日'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 提交表单
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final values = _controller.values;
      print('表单数据: $values');

      // 创建User对象
      final user = User(
        name: values['name']?.toString(),
        age: values['age'] != null ? int.tryParse(values['age'].toString()) : null,
        address: values['address']?.toString(),
        school: values['school']?.toString(),
        birthday: '1998-01-01',
      );

      print('创建的User对象: name=${user.name}, age=${user.age}, address=${user.address}, school=${user.school}, birthday=${user.birthday}');

      // 调用API创建用户
      final response = await UserApi.createUser(user);
      print('API响应: $response');

      if (mounted) {
        // 显示成功消息
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('用户创建成功！'), backgroundColor: Colors.green));

        // 返回上一页
        Navigator.of(context).pop(true); // 传递true表示创建成功
      }
    } catch (e) {
      print('创建用户错误: $e');
      if (mounted) {
        // 显示错误消息
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('创建用户失败: $e'), backgroundColor: Colors.red));
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
      appBar: AppBar(title: const Text('新增用户'), backgroundColor: Colors.blue[600], foregroundColor: Colors.white, elevation: 0),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.blue[50]!, Colors.white]),
        ),
        child: Column(
          children: [
            Expanded(
              child: FormBuilder(
                formKey: _formKey,
                controller: _controller,
                configs: _formConfigs,
                autovalidate: true,
                padding: const EdgeInsets.all(16),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, -2))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                            )
                          : const Text('保存'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
