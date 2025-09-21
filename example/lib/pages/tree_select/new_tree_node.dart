import 'package:example/pages/tree_select/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';
import '../../api/index.dart';

class NewTreeNodePage extends StatefulWidget {
  const NewTreeNodePage({super.key});
  @override
  State<NewTreeNodePage> createState() => _NewTreeNodePageState();
}

class _NewTreeNodePageState extends State<NewTreeNodePage> {
  TreeNode? selectedRemoteNode;
  TreeNode? selectedLocalNode;

  // 真实的远程搜索函数，使用AreaLocationApi
  Future<List<TreeNode>> _remoteSearch(String keyword) async {
    try {
      List<TreeNode> results = [];

      // 根据是否有关键词选择不同的API
      final response = keyword.trim().isEmpty ? await AreaLocationApi.getTopLevelAreas(limit: 50) : await AreaLocationApi.searchAreaLocations(keyword: keyword, limit: 50);

      if (response['success'] == true && response['data'] != null && response['data']['list'] != null) {
        final List<dynamic> list = response['data']['list'];

        for (final item in list) {
          final areaLocation = AreaLocation.fromJson(item);

          // 只显示激活的区域
          if (areaLocation.isActive == true && areaLocation.id != null && areaLocation.label != null) {
            results.add(TreeNode(id: areaLocation.id!, label: areaLocation.label!));
          }
        }
      }

      return results;
    } catch (e) {
      print('远程搜索失败: $e');
      // 返回空列表而不是抛出异常，避免界面崩溃
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TreeSelect 远程搜索与本地过滤示例'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 远程搜索示例
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cloud_download, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Text(
                          '远程搜索示例',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('启用远程搜索功能，调用真实的区域位置API获取数据。无关键词时显示顶级区域，有关键词时进行模糊搜索', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    TreeSelect(
                      data: const [], // 远程搜索时初始数据可以为空
                      remote: true, // 启用远程搜索
                      remoteFetch: _remoteSearch, // 真实的远程搜索函数
                      placeholder: '请选择区域位置（支持远程搜索）',
                      initialValue: selectedRemoteNode,
                      onValueChanged: (value) {
                        setState(() {
                          selectedRemoteNode = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    if (selectedRemoteNode != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '远程搜索选中结果:',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                            ),
                            const SizedBox(height: 4),
                            Text('ID: ${selectedRemoteNode!.id}'),
                            Text('标签: ${selectedRemoteNode!.label}'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 本地过滤示例
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.filter_list, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        Text(
                          '本地过滤示例',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('启用本地过滤功能，在本地数据中进行实时搜索过滤', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    TreeSelect(
                      data: localData, // 提供本地数据
                      filterable: true, // 启用本地过滤
                      placeholder: '请选择城市（支持本地过滤）',
                      initialValue: selectedLocalNode,
                      onValueChanged: (value) {
                        setState(() {
                          selectedLocalNode = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    if (selectedLocalNode != null)
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
                              '本地过滤选中结果:',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700),
                            ),
                            const SizedBox(height: 4),
                            Text('ID: ${selectedLocalNode!.id}'),
                            Text('标签: ${selectedLocalNode!.label}'),
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
                          '功能说明',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('• 远程搜索：调用真实的区域位置API，支持关键词模糊搜索'),
                    const SizedBox(height: 4),
                    const Text('• 本地过滤：在本地数据中进行实时搜索过滤'),
                    const SizedBox(height: 4),
                    const Text('• 两种模式不能同时启用'),
                    const SizedBox(height: 4),
                    const Text('• 远程搜索：无关键词时显示顶级区域，有关键词时进行搜索'),
                    const SizedBox(height: 4),
                    const Text('• 远程搜索：自动获取子级区域作为树形结构'),
                    const SizedBox(height: 4),
                    const Text('• 本地过滤模式下，需要提供完整的本地数据'),
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
