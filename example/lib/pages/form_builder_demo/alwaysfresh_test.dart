import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';
import 'package:simple_ui/models/select_data.dart';
import 'package:simple_ui/src/form_builder/index.dart';
import '../../api/user_api.dart';
import '../../api/models/user.dart';

class AlwaysFreshTestPage extends StatefulWidget {
  const AlwaysFreshTestPage({super.key});

  @override
  State<AlwaysFreshTestPage> createState() => _AlwaysFreshTestPageState();
}

class _AlwaysFreshTestPageState extends State<AlwaysFreshTestPage> {
  final FormBuilderController _controller = FormBuilderController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 模拟远程数据获取
  Future<List<SelectData<User>>> _fetchMockUsers(String keyword) async {
    print('🔄 正在获取模拟用户数据，关键词: $keyword');
    await Future.delayed(const Duration(seconds: 1)); // 模拟网络延迟

    final users = [
      User(id: '1', name: '张三', age: 25, address: '北京市朝阳区', school: '清华大学', birthday: '1998-01-15'),
      User(id: '2', name: '李四', age: 28, address: '上海市浦东新区', school: '复旦大学', birthday: '1995-05-20'),
      User(id: '3', name: '王五', age: 22, address: '广州市天河区', school: '中山大学', birthday: '2001-09-10'),
      User(id: '4', name: '赵六', age: 30, address: '深圳市南山区', school: '北京大学', birthday: '1993-12-03'),
    ];

    final filteredUsers = keyword.isEmpty
        ? users
        : users.where((user) => (user.name?.contains(keyword) ?? false) || (user.school?.contains(keyword) ?? false) || (user.address?.contains(keyword) ?? false)).toList();

    return filteredUsers.map((user) => SelectData<User>(label: '${user.name ?? '未知用户'} (${user.age ?? '未知年龄'}岁)', value: user.id ?? '', data: user)).toList();
  }

  // 真实接口获取数据
  Future<List<SelectData<User>>> _fetchRealUsers(String? keyword) async {
    try {
      print('🌐 正在从真实接口获取用户数据，关键词: $keyword');
      final response = await UserApi.getUserList(page: 1, limit: 20, name: keyword?.isNotEmpty == true ? keyword : null);

      // 检查响应结构
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        // 检查data是直接数组还是包含users字段的Map
        List<dynamic> usersData;
        if (data is List) {
          // data直接是用户数组
          usersData = data;
        } else if (data is Map<String, dynamic> && data['users'] is List) {
          // data是Map，包含users字段
          usersData = data['users'];
        } else {
          print('⚠️ 接口返回数据格式不符合预期: $data');
          return [];
        }

        if (usersData.isEmpty) {
          print('📭 接口返回空数据');
          return [];
        }

        print('✅ 成功获取到 ${usersData.length} 条用户数据');
        return usersData.map((userJson) {
          try {
            if (userJson is Map<String, dynamic>) {
              final user = User.fromJson(userJson);
              return SelectData<User>(label: '${user.name ?? '未知用户'} (${user.age ?? '未知年龄'}岁)', value: user.id ?? '', data: user);
            } else {
              return SelectData<User>(
                label: '数据格式错误',
                value: 'error',
                data: User(name: '数据格式错误', age: 0, address: '', school: '', birthday: ''),
              );
            }
          } catch (e) {
            print('❌ 解析用户数据失败: $e');
            return SelectData<User>(
              label: '解析失败的用户',
              value: 'error',
              data: User(name: '解析失败', age: 0, address: '', school: '', birthday: ''),
            );
          }
        }).toList();
      } else {
        print('❌ 接口返回失败: ${response['message'] ?? '未知错误'}');
        return [];
      }
    } catch (e) {
      print('❌ 网络请求失败: $e');
      return [];
    }
  }

  List<FormBuilderConfig> get _configs => [
    FormBuilderConfig.dropdown<User>(
      name: 'alwaysFreshMockUser',
      label: '模拟数据 - 每次获取最新 (alwaysFreshData: true)',
      required: false,
      remote: true,
      remoteFetch: _fetchMockUsers,
      alwaysFreshData: true, // 每次打开弹窗都获取最新数据
      placeholder: '请选择用户',
      onChange: (fieldName, value) {
        print('✅ 模拟数据 alwaysFreshData字段值变更: $fieldName = $value');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已选择模拟用户: $value'), duration: const Duration(seconds: 2), backgroundColor: Colors.green));
      },
    ),
    FormBuilderConfig.dropdown<User>(
      name: 'cachedMockUser',
      label: '模拟数据 - 使用缓存 (alwaysFreshData: false)',
      required: false,
      remote: true,
      remoteFetch: _fetchMockUsers,
      alwaysFreshData: false, // 只在第一次打开时获取数据
      placeholder: '请选择用户',
      onChange: (fieldName, value) {
        print('📦 模拟数据 缓存字段值变更: $fieldName = $value');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已选择模拟用户: $value'), duration: const Duration(seconds: 2), backgroundColor: Colors.blue));
      },
    ),
    FormBuilderConfig.dropdown<User>(
      name: 'alwaysFreshRealUser',
      label: '真实接口 - 每次获取最新 (alwaysFreshData: true)',
      required: false,
      remote: true,
      remoteFetch: _fetchRealUsers,
      alwaysFreshData: true, // 每次打开弹窗都获取最新数据
      placeholder: '请选择用户',
      onChange: (fieldName, value) {
        print('🌐 真实接口 alwaysFreshData字段值变更: $fieldName = $value');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已选择真实用户: $value'), duration: const Duration(seconds: 2), backgroundColor: Colors.orange));
      },
    ),
    FormBuilderConfig.dropdown<User>(
      name: 'cachedRealUser',
      label: '真实接口 - 使用缓存 (alwaysFreshData: false)',
      required: false,
      remote: true,
      remoteFetch: _fetchRealUsers,
      alwaysFreshData: false, // 只在第一次打开时获取数据
      placeholder: '请选择用户',
      onChange: (fieldName, value) {
        print('🌐 真实接口 缓存字段值变更: $fieldName = $value');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已选择真实用户: $value'), duration: const Duration(seconds: 2), backgroundColor: Colors.purple));
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AlwaysFreshData 功能测试'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('测试说明：', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 8),
                Text('📋 模拟数据示例：'),
                Text('  • 第1个下拉框：alwaysFreshData = true，每次打开都会重新获取数据'),
                Text('  • 第2个下拉框：alwaysFreshData = false，只在第一次打开时获取数据'),
                SizedBox(height: 8),
                Text('🌐 真实接口示例：'),
                Text('  • 第3个下拉框：调用真实API，alwaysFreshData = true'),
                Text('  • 第4个下拉框：调用真实API，alwaysFreshData = false'),
                SizedBox(height: 8),
                Text('💡 观察控制台输出，验证数据获取行为的差异'),
                Text('💡 不同颜色的提示条表示不同的数据源'),
              ],
            ),
          ),
          Expanded(
            child: FormBuilder(configs: _configs, controller: _controller, formKey: _formKey, autovalidate: true),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final values = _controller.values;
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('表单数据'),
                          content: SingleChildScrollView(child: Text(values.entries.map((e) => '${e.key}: ${e.value}').join('\n'))),
                          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('确定'))],
                        ),
                      );
                    },
                    child: const Text('查看表单数据'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _controller.clear();
                      _formKey.currentState?.reset();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text('重置表单'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
