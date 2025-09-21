import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';
import '../../api/index.dart';

class LazyLoadingExamplePage extends StatefulWidget {
  const LazyLoadingExamplePage({super.key});

  @override
  State<LazyLoadingExamplePage> createState() => _LazyLoadingExamplePageState();
}

class _LazyLoadingExamplePageState extends State<LazyLoadingExamplePage> {
  TreeNode? selectedNode;
  List<TreeNode> topLevelData = [];
  bool isLoadingTopLevel = false;
  String? loadError;

  // 懒加载状态管理
  final Set<String> loadingNodes = <String>{};
  final Map<String, List<TreeNode>> loadedChildren = <String, List<TreeNode>>{};

  @override
  void initState() {
    super.initState();
    // 移除初始化时的数据加载，改为懒加载模式
  }

  // 统一的远程数据获取函数
  Future<List<TreeNode>> _remoteFetch(String keyword) async {
    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 800));

      if (keyword.isEmpty) {
        // 空关键词：加载顶级数据
        final response = await AreaLocationApi.getTopLevelAreas(limit: 50);

        if (response['success'] == true && response['data'] != null && response['data']['list'] != null) {
          final List<dynamic> list = response['data']['list'];
          final List<TreeNode> nodes = [];

          for (final item in list) {
            final areaLocation = AreaLocation.fromJson(item);

            // 只显示激活的区域
            if (areaLocation.isActive == true && areaLocation.id != null && areaLocation.label != null) {
              nodes.add(TreeNode(id: areaLocation.id!, label: areaLocation.label!, hasChildren: areaLocation.hasChildren ?? false));
            }
          }

          return nodes;
        } else {
          throw Exception('加载顶级数据失败');
        }
      } else {
        // 非空关键词：进行搜索
        // 这里可以调用搜索API，暂时返回空列表
        // final searchResults = await AreaLocationApi.searchAreas(keyword);
        return [];
      }
    } catch (e) {
      throw Exception('获取数据失败: $e');
    }
  }

  // 懒加载子节点函数
  Future<List<TreeNode>> _lazyLoadChildren(TreeNode parent) async {
    try {
      // 模拟网速慢，延迟500毫秒
      await Future.delayed(const Duration(milliseconds: 500));

      final response = await AreaLocationApi.getAreaLocationList(parentId: parent.id, limit: 50);

      if (response['success'] == true && response['data'] != null && response['data']['list'] != null) {
        final List<dynamic> list = response['data']['list'];
        final List<TreeNode> children = [];

        for (final item in list) {
          final areaLocation = AreaLocation.fromJson(item);

          // 只显示激活的区域
          if (areaLocation.isActive == true && areaLocation.id != null && areaLocation.label != null) {
            children.add(TreeNode(id: areaLocation.id!, label: areaLocation.label!, hasChildren: areaLocation.hasChildren ?? false));
          }
        }

        return children;
      } else {
        throw Exception('API返回失败');
      }
    } catch (e) {
      throw Exception('加载子节点失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TreeSelect 懒加载示例'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 懒加载示例
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.dynamic_feed, color: Colors.purple.shade600),
                        const SizedBox(width: 8),
                        Text(
                          '懒加载示例',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('启用懒加载功能，使用真实API数据，根据hasChildren字段显示下拉箭头，点击展开时动态加载子节点', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),

                    const SizedBox(height: 12),
                    if (selectedNode != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '懒加载选中结果:',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple.shade700),
                            ),
                            const SizedBox(height: 4),
                            Text('ID: ${selectedNode!.id}'),
                            Text('标签: ${selectedNode!.label}'),
                            Text('有子节点: ${selectedNode!.hasChildren ? "是" : "否"}'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            TreeSelect(
              data: [], // 远程模式下不需要初始数据
              remote: true, // 启用远程模式
              remoteFetch: _remoteFetch, // 统一的远程数据获取函数
              isLazyLoading: true, // 启用懒加载
              lazyLoadChildren: _lazyLoadChildren, // 懒加载函数
              loadingNodes: loadingNodes, // 加载状态管理
              loadedChildren: loadedChildren, // 已加载子节点缓存
              placeholder: '请选择地区（支持懒加载）',
              initialValue: selectedNode,
              onValueChanged: (TreeNode value) {
                print(value.label);
                print(value.id);
                print(value.hasChildren);
                setState(() {
                  selectedNode = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // 新增：立即显示弹窗示例
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flash_on, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        Text(
                          '立即显示弹窗示例',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('点击时立即显示弹窗，在弹窗中显示加载动画，数据加载完成后刷新弹窗内容', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    TreeSelect(
                      data: [], // 远程模式下不需要初始数据
                      remote: true, // 启用远程模式
                      remoteFetch: _remoteFetch, // 统一的远程数据获取函数
                      placeholder: '点击立即显示弹窗（真实接口）',
                      onValueChanged: (TreeNode value) {
                        print('立即显示弹窗示例选中: ${value.label} (${value.id})');
                        setState(() {
                          selectedNode = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '功能特点:',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700),
                          ),
                          const SizedBox(height: 4),
                          const Text('• 点击时立即显示弹窗，无需等待数据加载'),
                          const Text('• 弹窗中显示加载动画，用户体验更好'),
                          const Text('• 数据加载完成后自动刷新弹窗内容'),
                          const Text('• 使用真实API接口，模拟实际使用场景'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 功能说明
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade600),
                        const SizedBox(width: 8),
                        Text(
                          '懒加载功能说明',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('• 根据TreeNode的hasChildren字段判断是否显示下拉箭头'),
                    const SizedBox(height: 4),
                    const Text('• 点击下拉箭头时动态加载子节点，显示加载动画'),
                    const SizedBox(height: 4),
                    const Text('• 已加载的子节点会被缓存，避免重复加载'),
                    const SizedBox(height: 4),
                    const Text('• 支持加载失败的错误处理和重试机制'),
                    const SizedBox(height: 4),
                    const Text('• 使用真实的API数据，支持错误处理和重试机制'),
                    const SizedBox(height: 4),
                    const Text('• 懒加载模式与远程搜索、本地过滤功能独立'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 数据结构说明
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_tree, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        Text(
                          '数据结构示例',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        '''TreeNode(\n  id: '1',\n  label: '北京市',\n  hasChildren: true, // 关键字段\n)''',
                        style: TextStyle(fontFamily: 'monospace', fontSize: 14, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('hasChildren字段来自API数据，为true时显示下拉箭头，为false时不显示', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
