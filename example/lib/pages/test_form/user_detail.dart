import 'package:example/models/user.dart';
import 'package:example/pages/test_form/user_edit.dart';
import 'package:example/services/user_service.dart';
import 'package:flutter/material.dart';

class UserDetailPage extends StatefulWidget {
  final User user;
  const UserDetailPage({super.key, required this.user});
  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  User? _userDetail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserDetail();
  }

  Future<void> _loadUserDetail() async {
    if (widget.user.id == null) {
      setState(() {
        _userDetail = widget.user;
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userDetail = await UserService.getUserDetail(widget.user.id!);

      setState(() {
        _userDetail = userDetail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '获取用户详情失败: $e';
        _isLoading = false;
        // 如果获取详情失败，使用传入的用户数据
        _userDetail = widget.user;
      });
    }
  }

  // 显示删除确认对话框
  void _showDeleteConfirmDialog() {
    final user = _userDetail ?? widget.user;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除用户 "${user.name}" 吗？此操作不可撤销。'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUser();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  // 删除用户
  Future<void> _deleteUser() async {
    final user = _userDetail ?? widget.user;
    print(user.toJson());
    if (user.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('无法删除：用户没有ID'), backgroundColor: Colors.orange));
      return;
    }

    try {
      // 显示删除中状态
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('正在删除用户...'), duration: Duration(seconds: 2)));

      // 调用删除API
      await UserService.deleteUser(user.id!);

      if (mounted) {
        // 显示删除成功消息
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('用户 "${user.name}" 已成功删除'), backgroundColor: Colors.green));

        // 返回上一页并传递删除的用户信息
        Navigator.pop(context, {'action': 'delete', 'user': user});
      }
    } catch (e) {
      if (mounted) {
        // 显示删除失败消息
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('删除失败: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户详情'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUserDetail, tooltip: '刷新'),
          IconButton(icon: const Icon(Icons.delete), onPressed: () => _showDeleteConfirmDialog(), tooltip: '删除用户'),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => UserEditPage(user: _userDetail ?? widget.user)));

              // 如果返回了更新后的用户数据，刷新详情
              if (result != null && result is User) {
                print('收到更新后的用户，ID: ${result.id}');
                setState(() {
                  _userDetail = result;
                });

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('用户 "${result.name}" 信息已更新'), backgroundColor: Colors.green));
              }
            },
            tooltip: '编辑用户',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator(), SizedBox(height: 16), Text('正在加载用户详情...')],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.orange),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadUserDetail, child: Text('重试')),
          ],
        ),
      );
    }

    final user = _userDetail ?? widget.user;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserHeader(user),
          const SizedBox(height: 24),
          _buildUserInfo(user),
          if (user.hobbies.isNotEmpty) ...[const SizedBox(height: 24), _buildHobbiesSection(user.hobbies)],
          if (user.introduction.isNotEmpty) ...[const SizedBox(height: 24), _buildIntroductionSection(user.introduction)],
        ],
      ),
    );
  }

  Widget _buildUserHeader(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _buildAvatar(user.avatar),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '${user.age}岁 · ${user.gender} · ${user.city}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  if (user.id != null) ...[
                    const SizedBox(height: 4),
                    Text('ID: ${user.id}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500])),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String avatarUrl) {
    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(avatarUrl),
        onBackgroundImageError: (exception, stackTrace) {
          // 头像加载失败时显示默认头像
        },
      );
    } else {
      return CircleAvatar(
        radius: 40,
        backgroundColor: Colors.blue[100],
        child: Icon(Icons.person, size: 40, color: Colors.blue[700]),
      );
    }
  }

  Widget _buildUserInfo(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('基本信息', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildInfoRow('职业', user.occupation),
            _buildInfoRow('教育背景', user.education),
          ],
        ),
      ),
    );
  }

  Widget _buildHobbiesSection(List<String> hobbies) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('兴趣爱好', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: hobbies
                  .map(
                    (hobby) => Chip(
                      label: Text(hobby),
                      backgroundColor: Colors.blue[100],
                      side: BorderSide(color: Colors.blue[300]!),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroductionSection(String introduction) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('个人介绍', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(introduction, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
          ),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.titleMedium)),
        ],
      ),
    );
  }
}
