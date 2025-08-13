import 'package:example/pages/test_form/add_user.dart';
import 'package:example/pages/test_form/user_detail.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';

class TestFormPage extends StatefulWidget {
  const TestFormPage({super.key});
  @override
  State<TestFormPage> createState() => _TestFormPageState();
}

class _TestFormPageState extends State<TestFormPage> {
  List<User> users = [];
  bool isLoading = true;
  String? errorMessage;

  // 缓存常用样式
  late final TextStyle _bodyStyle;
  late final TextStyle _labelStyle;

  @override
  void initState() {
    super.initState();
    _initializeStyles();
    fetchUsers();
  }

  void _initializeStyles() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _bodyStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
          _labelStyle = Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold) ?? const TextStyle();
        });
      }
    });
  }

  Future<void> fetchUsers() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final fetchedUsers = await UserService.getUsers();

      setState(() {
        users = fetchedUsers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = '获取数据失败: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户数据展示'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchUsers, tooltip: '刷新数据'),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddUserPage()));

              // 如果返回了新用户数据，刷新列表
              if (result != null && result is User) {
                setState(() {
                  users.insert(0, result); // 将新用户添加到列表顶部
                });

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('新用户已添加到列表'), backgroundColor: Colors.green));
              }
            },
            tooltip: '新增用户',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('正在加载数据...')]),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: fetchUsers, child: Text('重试')),
          ],
        ),
      );
    }

    if (users.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return RefreshIndicator(
      onRefresh: fetchUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => UserDetailPage(user: user)));

        // 处理从详情页面返回的结果
        if (result != null && result is Map<String, dynamic>) {
          if (result['action'] == 'delete') {
            // 从列表中移除被删除的用户
            setState(() {
              users.removeWhere((u) => u.id == result['user'].id);
            });

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('用户 "${result['user'].name}" 已从列表中移除'), backgroundColor: Colors.blue));
          }
        } else if (result != null && result is User) {
          // 处理从编辑页面返回的更新结果
          print('列表页面收到更新后的用户，ID: ${result.id}');
          setState(() {
            // 更新列表中的用户信息
            final index = users.indexWhere((u) => u.id == result.id);
            if (index != -1) {
              users[index] = result;
              print('已更新列表中的用户，索引: $index');
            } else {
              print('未找到匹配的用户ID: ${result.id}');
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('用户 "${result.name}" 信息已更新'), backgroundColor: Colors.green));
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildUserHeader(user), const SizedBox(height: 16), _buildInfoRow('职业', user.occupation), _buildInfoRow('教育', user.education)],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(User user) {
    return Row(
      children: [
        _buildAvatar(user.avatar),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('${user.age}岁 · ${user.gender} · ${user.city}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String avatarUrl) {
    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(avatarUrl),
        onBackgroundImageError: (exception, stackTrace) {
          // 头像加载失败时显示默认头像
        },
      );
    } else {
      return CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30));
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 60, child: Text('$label:', style: _labelStyle)),
          Expanded(child: Text(value, style: _bodyStyle)),
        ],
      ),
    );
  }
}
