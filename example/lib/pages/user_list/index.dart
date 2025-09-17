import 'package:flutter/material.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});
  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('用户管理页面')),
      body: const Text('页面内容正在开发中...'),
    );
  }
}
