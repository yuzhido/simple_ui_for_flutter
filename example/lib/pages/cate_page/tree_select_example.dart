import 'package:example/pages/cascading_select/index.dart';
import 'package:example/pages/tree_select/index.dart';
import 'package:example/pages/tree_select/lazy_loading_example.dart';
import 'package:example/pages/tree_select/new_tree_node.dart';
import 'package:flutter/material.dart';

class TreeSelectExamplePage extends StatefulWidget {
  const TreeSelectExamplePage({super.key});
  @override
  State<TreeSelectExamplePage> createState() => _TreeSelectExamplePageState();
}

class _TreeSelectExamplePageState extends State<TreeSelectExamplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('多级选择示例')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CascadingSelectPage())),
            child: const Text('三级级联多选（CascadingSelect）示例'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TreeSelectPage()));
            },
            child: Text('跳转查看树形选择（TreeSelect）示例'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NewTreeNodePage()));
            },
            child: Text('跳转查看TreeSelect远程搜索与本地过滤示例'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LazyLoadingExamplePage()));
            },
            child: Text('跳转查看TreeSelect懒加载功能示例'),
          ),
        ],
      ),
    );
  }
}
