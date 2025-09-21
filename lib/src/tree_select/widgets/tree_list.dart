import 'package:flutter/material.dart';
import 'dart:async';
import 'package:simple_ui/simple_ui.dart';
import 'package:simple_ui/src/tree_select/utils/tips.dart';
import 'package:simple_ui/src/tree_select/utils/search.dart';
import 'package:simple_ui/src/tree_select/widgets/is_expanded.dart';
import 'package:simple_ui/src/widgets/circle_loading.dart';
import 'package:simple_ui/src/widgets/header_title.dart';
import 'package:simple_ui/src/widgets/no_data.dart';

class TreeBottomSheet extends StatefulWidget {
  final List<TreeNode> data;
  final TreeNode? selectedNode;
  final Function(TreeNode) onValueChanged;
  final List<Object> expandPath;

  // 搜索相关属性
  final bool remote;
  final bool filterable;
  final TextEditingController searchController;

  // 新增：远程搜索函数，直接传递给弹窗
  final Future<List<TreeNode>> Function(String keyword)? remoteFetch;

  // 新增：懒加载相关属性
  final bool isLazyLoading;
  final Future<List<TreeNode>> Function(TreeNode parent)? lazyLoadChildren;
  final Set<Object> loadingNodes;
  final Map<Object, List<TreeNode>> loadedChildren;

  // 新增：初始数据加载相关属性
  final bool needsInitialLoad;
  final Function(List<TreeNode>)? onInitialDataLoaded;

  const TreeBottomSheet({
    super.key,
    required this.data,
    required this.selectedNode,
    required this.onValueChanged,
    required this.expandPath,
    this.remote = false,
    this.filterable = false,
    required this.searchController,
    this.remoteFetch,
    this.isLazyLoading = false,
    this.lazyLoadChildren,
    required this.loadingNodes,
    required this.loadedChildren,
    this.needsInitialLoad = false,
    this.onInitialDataLoaded,
  });

  @override
  State<TreeBottomSheet> createState() => _TreeBottomSheetState();
}

class _TreeBottomSheetState extends State<TreeBottomSheet> with TickerProviderStateMixin {
  Set<Object> expandedNodes = {};
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late ScrollController _scrollController;

  // 搜索相关状态
  List<TreeNode> _currentData = [];
  late TreeSearchController _searchManager;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _scrollController = ScrollController();
    _slideController.forward();

    // 初始化当前数据
    _currentData = widget.data;
    
    // 初始化搜索管理器
    _searchManager = TreeSearchUtils.createController(
      searchController: widget.searchController,
      originalData: widget.data,
      remote: widget.remote,
      filterable: widget.filterable,
      remoteFetch: widget.remoteFetch,
      context: mounted ? context : null,
      onStateChanged: () {
        if (mounted) {
          setState(() {
            _currentData = _searchManager.currentData;
          });
        }
      },
    );

    // 如果需要初始加载数据，则在弹窗显示后立即开始加载
    if (widget.needsInitialLoad && widget.remoteFetch != null) {
      _loadInitialData();
    }

    // 根据选中路径自动展开节点
    _expandSelectedPath();

    // 延迟滚动到选中项位置
    if (widget.selectedNode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedItem();
      });
    }
  }

  // 加载初始数据
  Future<void> _loadInitialData() async {
    // 使用搜索管理器进行初始数据加载
    await _searchManager.search('');

    // 通知主组件数据已加载
    widget.onInitialDataLoaded?.call(_searchManager.currentData);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TreeBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果数据发生变化，更新搜索管理器的源数据
    if (oldWidget.data != widget.data) {
      _searchManager.updateSourceData(widget.data);
    }
  }

  // 根据选中路径自动展开节点
  void _expandSelectedPath() {
    if (widget.expandPath.isNotEmpty) {
      // 展开选中路径上的所有父节点（除了最后一个节点，因为它是选中项本身）
      for (int i = 0; i < widget.expandPath.length - 1; i++) {
        final nodeId = widget.expandPath[i];
        expandedNodes.add(nodeId);

        // 懒加载模式下，如果节点还没有加载子节点，则触发懒加载
        if (widget.isLazyLoading && !widget.loadedChildren.containsKey(nodeId)) {
          _lazyLoadChildren(nodeId);
        }
      }
    }
  }

  // 处理搜索
  void _handleSearch() => _searchManager.search();



  // 清空搜索
  void _clearSearch() => _searchManager.clear();

  // 滚动到选中项位置
  void _scrollToSelectedItem() {
    if (widget.selectedNode != null) {
      // 延迟一点时间确保布局完成
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          // 计算选中项在列表中的位置
          final position = _calculateSelectedItemPosition();
          if (position != -1) {
            // 将位置转换为像素位置（每个项目大约60像素高）
            final pixelPosition = position * 60.0;
            _scrollController.animateTo(pixelPosition, duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic);
          }
        }
      });
    }
  }

  // 计算选中项在列表中的位置
  int _calculateSelectedItemPosition() {
    int position = 0;
    return _findItemPosition(widget.data, widget.selectedNode!.id, position);
  }

  int _findItemPosition(List<TreeNode> nodes, String targetId, int currentPosition) {
    for (var node in nodes) {
      if (node.id == targetId) {
        return currentPosition;
      }
      currentPosition++;
      if (node.children != null && expandedNodes.contains(node.id)) {
        final result = _findItemPosition(node.children!, targetId, currentPosition);
        if (result != -1) {
          return result;
        }
        // 如果没找到，继续计算位置
        currentPosition = _countExpandedItems(node.children!);
      }
    }
    return -1;
  }

  int _countExpandedItems(List<TreeNode> nodes) {
    int count = 0;
    for (var node in nodes) {
      count++;
      if (expandedNodes.contains(node.id) && node.children != null) {
        count += _countExpandedItems(node.children!);
      }
    }
    return count;
  }

  void _toggleExpanded(dynamic nodeId) {
    setState(() {
      if (expandedNodes.contains(nodeId)) {
        expandedNodes.remove(nodeId);
      } else {
        expandedNodes.add(nodeId);

        // 懒加载模式下，如果节点还没有加载子节点，则触发懒加载
        if (widget.isLazyLoading && !widget.loadedChildren.containsKey(nodeId)) {
          _lazyLoadChildren(nodeId);
        }
      }
    });
  }

  // 获取节点的子节点（懒加载模式下从缓存获取，普通模式从node.children获取）
  List<TreeNode> _getNodeChildren(TreeNode node) {
    if (widget.isLazyLoading) {
      return widget.loadedChildren[node.id] ?? [];
    } else {
      return node.children ?? [];
    }
  }

  // 懒加载子节点
  void _lazyLoadChildren(dynamic nodeId) async {
    if (widget.lazyLoadChildren == null || widget.loadingNodes.contains(nodeId)) {
      return;
    }

    // 找到对应的节点
    TreeNode? targetNode = _findNodeById(_currentData, nodeId);
    if (targetNode == null) return;

    // 标记为加载中
    widget.loadingNodes.add(nodeId);
    setState(() {});

    try {
      // 调用懒加载函数
      final children = await widget.lazyLoadChildren!(targetNode);

      // 更新缓存
      widget.loadedChildren[nodeId] = children;

      // 移除加载状态
      widget.loadingNodes.remove(nodeId);
      setState(() {});
    } catch (e) {
      // 加载失败，移除加载状态
      widget.loadingNodes.remove(nodeId);
      setState(() {});

      // 显示错误提示
      if (mounted) {
        tips(context, '加载子节点失败，请稍后重试');
      }

      debugPrint('懒加载子节点失败: $e');
    }
  }

  // 在数据中查找指定ID的节点
  TreeNode? _findNodeById(List<TreeNode> nodes, String targetId) {
    for (var node in nodes) {
      if (node.id == targetId) {
        return node;
      }

      // 获取子节点（考虑懒加载模式）
      List<TreeNode> children = [];
      if (widget.isLazyLoading) {
        children = widget.loadedChildren[node.id] ?? [];
      } else {
        children = node.children ?? [];
      }

      if (children.isNotEmpty) {
        final result = _findNodeById(children, targetId);
        if (result != null) {
          return result;
        }
      }
    }
    return null;
  }

  Widget _buildTreeItem(TreeNode node, int level) {
    // 懒加载模式下的hasChildren判断逻辑
    final bool hasChildren;
    if (widget.isLazyLoading) {
      // 懒加载模式：根据hasChildren字段或已加载的子节点判断
      hasChildren = node.hasChildren || (widget.loadedChildren[node.id]?.isNotEmpty ?? false);
    } else {
      // 普通模式：根据children属性判断
      hasChildren = node.children != null && node.children!.isNotEmpty;
    }

    final isExpanded = expandedNodes.contains(node.id);
    final isSelected = widget.selectedNode?.id == node.id;
    final isLoading = widget.loadingNodes.contains(node.id);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              widget.onValueChanged(node);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              padding: EdgeInsets.only(left: 16 + (level * 24), right: 16, top: 14, bottom: 14),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade50.withValues(alpha: 0.8) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected ? Border.all(color: Colors.blue.shade200, width: 1) : null,
              ),
              child: Row(
                children: [
                  if (hasChildren)
                    GestureDetector(
                      onTapDown: (details) {
                        _toggleExpanded(node.id);
                      },
                      child: isLoading ? CircleLoading() : IsExpanded(isExpanded),
                    )
                  else
                    const SizedBox(width: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      node.label,
                      style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? Colors.blue.shade700 : Colors.grey.shade800),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.blue.shade600, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 16),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (hasChildren && isExpanded)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Column(children: _getNodeChildren(node).map((child) => _buildTreeItem(child, level + 1)).toList()),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child: Column(
          children: [
            // 标题栏
            HeaderTitle(),
            // 搜索输入框
            if (widget.remote || widget.filterable)
              InputSearch(
                remote: widget.remote,
                isLoading: _searchManager.isSearching,
                controller: widget.searchController,
                hintText: widget.remote ? '输入关键词搜索' : '输入关键词过滤',
                onChanged: (value) {
                  if (widget.filterable) {
                    // 本地过滤时实时响应输入变化
                    if (value.isEmpty) {
                      _clearSearch();
                    } else {
                      // 延迟搜索，避免频繁调用
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (widget.searchController.text == value) {
                          _handleSearch();
                        }
                      });
                    }
                  }
                },
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _handleSearch();
                  }
                },
                onClear: _clearSearch,
                remoteFetch: _handleSearch,
                showClearButton: widget.searchController.text.isNotEmpty,
              ),
            // 树形列表
            Expanded(
              child: _searchManager.currentData.isEmpty && _searchManager.isSearching
                  ? LoadingData()
                  : _searchManager.currentData.isEmpty
                  ? NoData()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _searchManager.currentData.length,
                      itemBuilder: (context, index) {
                        return _buildTreeItem(_searchManager.currentData[index], 0);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
