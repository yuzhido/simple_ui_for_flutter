import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';
import 'package:simple_ui/simple_ui.dart';
import '../../api/user_api.dart';
import '../../api/models/user.dart';

class UserEditPage extends StatefulWidget {
  final User user;

  const UserEditPage({super.key, required this.user});

  @override
  State<UserEditPage> createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FormBuilderController _controller = FormBuilderController();
  bool _isSubmitting = false;
  bool _isLoading = true;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;

    // 预填充表单数据
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 模拟网络延迟 3 秒后再赋值
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      _controller.setValues({
        'name': _currentUser.name ?? '',
        'age': _currentUser.age?.toString() ?? '',
        'address': _currentUser.address ?? '',
        'school': _currentUser.school ?? '',
        'birthday': _currentUser.birthday ?? '',
      });
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // 表单配置
  List<FormBuilderConfig> get _formConfigs => [
    FormBuilderConfig(name: 'name', label: '姓名', type: FormBuilderType.text, defaultValue: _currentUser.name, required: true, placeholder: '请输入姓名'),
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

      // 创建更新的User对象
      final updatedUser = User(
        id: _currentUser.id,
        name: values['name']?.toString(),
        age: values['age'] != null ? int.tryParse(values['age'].toString()) : null,
        address: values['address']?.toString(),
        school: values['school']?.toString(),
        birthday: values['birthday']?.toString(),
      );

      print(
        '更新的User对象: name=${updatedUser.name}, age=${updatedUser.age}, address=${updatedUser.address}, school=${updatedUser.school}, birthday=${updatedUser.birthday}',
      );

      // 调用API更新用户
      final response = await UserApi.updateUser(_currentUser.id!, updatedUser);
      print('API响应: $response');

      if (mounted) {
        // 显示成功消息
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('用户更新成功！'), backgroundColor: Colors.green));

        // 返回上一页，传递更新后的用户数据
        Navigator.of(context).pop(updatedUser);
      }
    } catch (e) {
      print('更新用户错误: $e');
      if (mounted) {
        // 显示错误消息
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('更新用户失败: $e'), backgroundColor: Colors.red));
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
      appBar: AppBar(title: const Text('编辑用户'), backgroundColor: Colors.blue[600], foregroundColor: Colors.white, elevation: 0),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.blue[50]!, Colors.white]),
        ),
        child: Stack(
          children: [
            Column(
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
                          onPressed: (_isSubmitting || _isLoading) ? null : _submitForm,
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
            if (_isLoading)
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: Container(
                    color: Colors.white.withOpacity(0.6),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('正在加载默认值...', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
