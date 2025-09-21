import 'package:flutter/material.dart';
import 'dart:async';
import 'package:simple_ui/simple_ui.dart';
import 'package:simple_ui/src/tree_select/utils/search.dart';
import 'package:simple_ui/src/tree_select/widgets/tree_list.dart';

class TreeSelect extends StatefulWidget {
  final List<TreeNode> data;
  final String? placeholder;
  final TreeNode? initialValue; // 初始选中的节点
  final dynamic initialValueId; // 初始选中节点的ID（支持int、String或null）
  final Function(TreeNode)? onValueChanged; // 值变化时的回调

  // 远程搜索相关属性
  final bool remote; // 是否启用远程搜索
  final Future<List<TreeNode>> Function(String keyword)? remoteFetch; // 远程搜索函数
  final bool filterable; // 是否启用本地过滤

  // 懒加载相关属性
  final bool isLazyLoading; // 是否启用懒加载
  final Future<List<TreeNode>> Function(TreeNode parent)? lazyLoadChildren; // 懒加载子节点函数
  final Set<Object>? loadingNodes; // 正在加载的节点ID集合
  final Map<Object, List<TreeNode>>? loadedChildren; // 已加载的子节点缓存

  // 数据加载完成回调
  final Function(List<TreeNode>)? onDataLoaded; // 远程数据加载完成时的回调

  const TreeSelect({
    super.key,
    required this.data,
    this.placeholder,
    this.initialValue,
    this.initialValueId,
    this.onValueChanged,
    this.remote = false,
    this.remoteFetch,
    this.filterable = false,
    this.isLazyLoading = false, // 默认不启用懒加载
    this.lazyLoadChildren,
    this.loadingNodes,
    this.loadedChildren,
    this.onDataLoaded,
  }) : assert(
         !(remote && filterable), // remote和filterable不能同时为true
         'remote和filterable不能同时为true',
       ),
       assert(
         !remote || remoteFetch != null, // remote为true时，remoteFetch必须提供
         'remote为true时，remoteFetch必须提供',
       ),
       assert(
         !isLazyLoading || lazyLoadChildren != null, // isLazyLoading为true时，lazyLoadChildren必须提供
         'isLazyLoading为true时，lazyLoadChildren必须提供',
       ),
       assert(
         initialValue == null || initialValueId == null, // initialValue和initialValueId不能同时设置
         'initialValue和initialValueId不能同时设置',
       ),
       assert(
         initialValueId == null || initialValueId is String || initialValueId is int, // initialValueId只能是null、String或int
         'initialValueId只能是null、String或int类型',
       );

  @override
  State<TreeSelect> createState() => _TreeSelectState();
}

class _TreeSelectState extends State<TreeSelect> with TickerProviderStateMixin {
  String? selectedLabel;
  TreeNode? selectedNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // 搜索相关状态
  final TextEditingController _searchController = TextEditingController();
  List<TreeNode> _displayData = []; // 当前显示的数据
  late TreeSearchController _searchManager; // 搜索管理器

  // 统一的数据缓存机制
  List<TreeNode>? _cachedData; // 统一的数据缓存（远程搜索或懒加载的顶级数据）
  bool _hasLoadedInitialData = false; // 是否已加载过初始数据

  // 懒加载相关状态
  final Set<Object> _loadingNodes = {}; // 正在加载子节点的节点ID集合
  final Map<Object, List<TreeNode>> _loadedChildren = {}; // 已加载的子节点缓存 nodeId -> children

  // 选中路径缓存（用于懒加载模式下的路径展开）
  List<Object>? _cachedSelectedPath;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // 初始化显示数据
    _initializeDisplayData();

    // 初始化搜索管理器
    _initializeSearchManager();

    // 处理初始值
    _handleInitialValue();
  }

  // 初始化显示数据
  void _initializeDisplayData() {
    if (widget.remote || widget.isLazyLoading) {
      // 远程模式或懒加载模式：优先使用缓存数据，如果没有缓存则使用传入的data
      _displayData = _cachedData ?? widget.data;
    } else {
      // 本地模式：直接使用传入的data
      _displayData = widget.data;
    }
  }

  // 初始化搜索管理器
  void _initializeSearchManager() {
    final sourceData = (widget.remote || widget.isLazyLoading) ? (_cachedData ?? widget.data) : widget.data;
    _searchManager = TreeSearchUtils.createController(
      searchController: _searchController,
      originalData: sourceData,
      remote: widget.remote,
      filterable: widget.filterable,
      remoteFetch: widget.remoteFetch,
      context: mounted ? context : null,
      onStateChanged: () {
        if (mounted) {
          setState(() {
            _displayData = _searchManager.currentData;
          });
        }
      },
    );
  }

  // 处理初始值
  void _handleInitialValue() {
    if (widget.initialValue != null) {
      // 直接使用传入的TreeNode对象
      selectedNode = widget.initialValue;
      selectedLabel = widget.initialValue!.label;

      // 在懒加载模式下，如果有初始值但没有缓存数据，预设选中路径
      if (widget.isLazyLoading && _cachedData == null) {
        _cachedSelectedPath = [widget.initialValue!.id];
      }
    } else if (widget.initialValueId != null) {
      // 根据ID查找对应的节点
      final searchData = (widget.remote || widget.isLazyLoading) ? (_cachedData ?? widget.data) : widget.data;
      _findSelectedNodeById(searchData, widget.initialValueId!);

      // 在懒加载模式下，如果有初始值ID但没有缓存数据，预设选中路径
      if (widget.isLazyLoading && _cachedData == null) {
        _cachedSelectedPath = [widget.initialValueId!];
      }
    } else {
      // 如果都为null，清空内部状态
      selectedNode = null;
      selectedLabel = null;
      _cachedSelectedPath = null;
    }
  }

  @override
  void didUpdateWidget(TreeSelect oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果data发生变化，重新处理数据
    if (oldWidget.data != widget.data) {
      // 如果是远程模式或懒加载模式且data发生变化，清空缓存重新初始化
      if (widget.remote || widget.isLazyLoading) {
        _cachedData = null;
        _hasLoadedInitialData = false;
        _loadedChildren.clear();
        _loadingNodes.clear();
      }
      _initializeDisplayData(); // 重新初始化显示数据
    }

    // 如果初始值发生变化，重新处理初始值（但不重置缓存数据）
    if (oldWidget.initialValue != widget.initialValue || oldWidget.initialValueId != widget.initialValueId) {
      _handleInitialValue();
    }

    // 如果remote或isLazyLoading属性发生变化，重置相关状态
    if (oldWidget.remote != widget.remote || oldWidget.isLazyLoading != widget.isLazyLoading) {
      if (!widget.remote && !widget.isLazyLoading) {
        // 从远程模式或懒加载模式切换到本地模式，清空缓存
        _cachedData = null;
        _hasLoadedInitialData = false;
        _loadedChildren.clear();
        _loadingNodes.clear();
        _cachedSelectedPath = null;
      }
      _initializeDisplayData();
    }
  }

  // 处理选中事件
  void _handleSelection(TreeNode node, {List<Object>? selectedPath}) {
    setState(() {
      selectedNode = node;
      selectedLabel = node.label;
      
      // 在懒加载模式下，缓存选中路径以便下次展开
      if (widget.isLazyLoading && selectedPath != null && selectedPath.isNotEmpty) {
        _cachedSelectedPath = selectedPath;
      }
    });

    // 调用值变化回调
    widget.onValueChanged?.call(node);

    // 关闭弹窗
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// 根据ID查找并设置选中的节点
  /// 确保基于id相等进行选中判断
  void _findSelectedNodeById(List<TreeNode> nodes, String targetId) {
    final foundNode = _searchNodeById(nodes, targetId);
    if (foundNode != null) {
      selectedNode = foundNode;
      selectedLabel = foundNode.label;
    } else {
      // 如果没找到，清空状态
      selectedNode = null;
      selectedLabel = null;
    }
  }

  /// 递归搜索指定ID的节点
  TreeNode? _searchNodeById(List<TreeNode> nodes, dynamic targetId) {
    for (var node in nodes) {
      // 严格基于id相等进行判断（支持int和String类型的比较）
      if (node.id == targetId) {
        return node;
      }
      // 递归搜索子节点
      if (node.children != null && node.children!.isNotEmpty) {
        final foundInChildren = _searchNodeById(node.children!, targetId);
        if (foundInChildren != null) {
          return foundInChildren;
        }
      }
    }
    return null;
  }

  /// 处理初始数据加载完成
  void _handleInitialDataLoaded(List<TreeNode> data) {
    // 防止重复加载相同数据
    if (_cachedData != null && _listEquals(_cachedData!, data)) {
      return;
    }

    // 批量更新状态，减少重绘次数
    setState(() {
      _cachedData = data;
      _displayData = data;
      _hasLoadedInitialData = true;
    });

    // 更新搜索管理器的源数据
    _searchManager.updateSourceData(data);

    // 如果有默认值且之前没找到，重新查找
    if (widget.initialValueId != null && selectedNode == null) {
      _findSelectedNodeById(data, widget.initialValueId!);
      // 在懒加载模式下，如果找到了节点，计算并缓存完整路径
      if (widget.isLazyLoading && selectedNode != null) {
        final fullPath = _findSelectedPath(data, selectedNode!.id);
        if (fullPath.isNotEmpty) {
          _cachedSelectedPath = fullPath;
        }
      }
    } else if (widget.initialValue != null && selectedNode == null) {
      // 如果有初始值对象但之前没设置，重新设置
      selectedNode = widget.initialValue;
      selectedLabel = widget.initialValue!.label;
      // 在懒加载模式下，计算并缓存完整路径
      if (widget.isLazyLoading) {
        final fullPath = _findSelectedPath(data, widget.initialValue!.id);
        if (fullPath.isNotEmpty) {
          _cachedSelectedPath = fullPath;
        }
      }
    }

    // 触发自定义回调（如果有）
    widget.onDataLoaded?.call(data);
  }

  /// 比较两个TreeNode列表是否相等（基于ID）
  bool _listEquals(List<TreeNode> list1, List<TreeNode> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id) return false;
    }
    return true;
  }

  /// 找到选中项的完整路径（从根节点到目标节点的ID路径）
  /// 确保基于id相等进行路径查找（支持int和String类型的ID）
  List<Object> _findSelectedPath(List<TreeNode> nodes, dynamic targetId) {
    for (var node in nodes) {
      // 严格基于id相等进行判断
      if (node.id == targetId) {
        return [node.id];
      }
      // 递归搜索子节点
      if (node.children != null && node.children!.isNotEmpty) {
        final path = _findSelectedPath(node.children!, targetId);
        if (path.isNotEmpty) {
          return [node.id, ...path];
        }
      }
    }
    return [];
  }

  void _showTreeBottomSheet() async {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // 获取选中项的路径
    List<Object> selectedPath = [];
    if (selectedNode != null) {
      if (widget.isLazyLoading) {
        // 懒加载模式下的路径处理
        if (_cachedSelectedPath != null) {
          // 优先使用缓存路径，这是最可靠的
          selectedPath = _cachedSelectedPath!;
        } else if (_displayData.isNotEmpty) {
          // 如果没有缓存路径但有显示数据，尝试计算完整路径
          selectedPath = _findSelectedPath(_displayData, selectedNode!.id);
          // 如果找到了路径，缓存起来
          if (selectedPath.isNotEmpty) {
            _cachedSelectedPath = selectedPath;
          }
        } else {
          // 否则只提供选中节点的ID
          selectedPath = [selectedNode!.id];
        }
      } else {
        // 普通模式下直接计算路径
        selectedPath = _findSelectedPath(_displayData, selectedNode!.id);
      }
    }

    // 立即显示弹窗，不等待数据加载
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TreeBottomSheet(
        data: _displayData, // 使用当前的数据（可能为空）
        selectedNode: selectedNode,
        expandPath: selectedPath,
        onValueChanged: _handleSelection,
        remote: widget.remote,
        filterable: widget.filterable,
        searchController: _searchController,
        remoteFetch: widget.remoteFetch,
        isLazyLoading: widget.isLazyLoading,
        lazyLoadChildren: widget.lazyLoadChildren,
        loadingNodes: widget.loadingNodes ?? _loadingNodes,
        loadedChildren: widget.loadedChildren ?? _loadedChildren,
        // 传递是否需要初始加载的标志
        needsInitialLoad: (widget.remote || widget.isLazyLoading) && !_hasLoadedInitialData,
        onInitialDataLoaded: _handleInitialDataLoaded,
        // 传递主组件的搜索管理器，避免重新创建
        searchManager: _searchManager,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            onTap: _showTreeBottomSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selectedLabel != null ? Colors.blue.shade300 : Colors.grey.shade300, width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedLabel ?? widget.placeholder ?? '请选择',
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedLabel != null ? Colors.grey.shade800 : Colors.grey.shade500,
                        fontWeight: selectedLabel != null ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.keyboard_arrow_down_rounded, color: selectedLabel != null ? Colors.blue.shade600 : Colors.grey.shade400, size: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
