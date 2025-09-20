import 'package:flutter/material.dart';
import 'dart:async';
import 'package:simple_ui/models/index.dart';

class TreeSelect extends StatefulWidget {
  final List<TreeNode> data;
  final Function(TreeNode)? onSelect;
  final String? placeholder;
  final String? selectedValue;
  final dynamic initialValue; // 既作为初始值，又存储用户选择的值
  final Function(dynamic)? onValueChanged; // 新增：值变化时的回调

  // 新增：远程搜索相关属性
  final bool remote; // 是否启用远程搜索
  final Future<List<TreeNode>> Function(String keyword)? remoteFetch; // 远程搜索函数
  final bool filterable; // 是否启用本地过滤

  const TreeSelect({
    super.key,
    required this.data,
    this.onSelect,
    this.placeholder,
    this.selectedValue,
    this.initialValue,
    this.onValueChanged,
    this.remote = false,
    this.remoteFetch,
    this.filterable = false,
  }) : assert(
         !(remote && filterable), // remote和filterable不能同时为true
         'remote和filterable不能同时为true',
       ),
       assert(
         !remote || remoteFetch != null, // remote为true时，remoteFetch必须提供
         'remote为true时，remoteFetch必须提供',
       );

  @override
  State<TreeSelect> createState() => _TreeSelectState();
}

class _TreeSelectState extends State<TreeSelect> with TickerProviderStateMixin {
  String? selectedLabel;
  TreeNode? selectedNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // 新增：搜索相关状态
  final TextEditingController _searchController = TextEditingController();
  List<TreeNode> _displayData = []; // 当前显示的数据
  bool _isSearching = false; // 是否正在搜索
  String _searchKeyword = ''; // 搜索关键词

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // 初始化显示数据
    _displayData = widget.data;

    // 处理初始值
    _handleInitialValue();
  }

  // 处理初始值
  void _handleInitialValue() {
    // 优先处理initialValue
    if (widget.initialValue != null) {
      if (widget.initialValue is TreeNode) {
        // 如果传入的是TreeNode对象
        final node = widget.initialValue as TreeNode;
        selectedNode = node;
        selectedLabel = node.label;
      } else if (widget.initialValue is String) {
        // 如果传入的是ID字符串
        _findSelectedNode(widget.data, widget.initialValue as String);
      }
    } else {
      // 如果initialValue为null，清空内部状态
      selectedNode = null;
      selectedLabel = null;
    }

    // 如果没有initialValue，则使用selectedValue（向后兼容）
    if (widget.initialValue == null && widget.selectedValue != null) {
      _findSelectedNode(widget.data, widget.selectedValue!);
    }
  }

  @override
  void didUpdateWidget(TreeSelect oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果数据或初始值发生变化，重新处理
    if (oldWidget.data != widget.data || oldWidget.initialValue != widget.initialValue) {
      _displayData = widget.data; // 更新显示数据
      _handleInitialValue();
    }
  }

  // 处理选中事件
  void _handleSelection(TreeNode node) {
    setState(() {
      selectedNode = node;
      selectedLabel = node.label;
    });

    // 调用原有的onSelect回调
    widget.onSelect?.call(node);

    // 调用新的onValueChanged回调，传递选中的值
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

  void _findSelectedNode(List<TreeNode> nodes, String targetId) {
    bool found = false;
    for (var node in nodes) {
      if (node.id == targetId) {
        selectedNode = node;
        selectedLabel = node.label;
        found = true;
        break;
      }
      if (node.children != null) {
        found = _findSelectedNodeInChildren(node.children!, targetId);
        if (found) break;
      }
    }

    // 如果没找到，清空状态
    if (!found) {
      selectedNode = null;
      selectedLabel = null;
    }
  }

  // 在子节点中查找
  bool _findSelectedNodeInChildren(List<TreeNode> nodes, String targetId) {
    for (var node in nodes) {
      if (node.id == targetId) {
        selectedNode = node;
        selectedLabel = node.label;
        return true;
      }
      if (node.children != null) {
        if (_findSelectedNodeInChildren(node.children!, targetId)) {
          return true;
        }
      }
    }
    return false;
  }

  // 找到选中项的完整路径
  List<String> _findSelectedPath(List<TreeNode> nodes, String targetId) {
    for (var node in nodes) {
      if (node.id == targetId) {
        return [node.id];
      }
      if (node.children != null) {
        final path = _findSelectedPath(node.children!, targetId);
        if (path.isNotEmpty) {
          return [node.id, ...path];
        }
      }
    }
    return [];
  }

  void _showTreeBottomSheet() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // 获取选中项的路径
    List<String> selectedPath = [];
    if (selectedNode != null) {
      selectedPath = _findSelectedPath(_displayData, selectedNode!.id);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TreeBottomSheet(
        data: _displayData, // 使用搜索后的数据
        selectedNode: selectedNode,
        selectedPath: selectedPath,
        onSelect: _handleSelection,
        remote: widget.remote,
        filterable: widget.filterable,
        searchController: _searchController,
        onSearch: _handleSearch,
        onClearSearch: _clearSearch,
        isSearching: _isSearching,
        searchKeyword: _searchKeyword,
        remoteFetch: widget.remoteFetch,
      ),
    );
  }

  // 处理搜索
  void _handleSearch() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      setState(() {
        _displayData = widget.data;
        _searchKeyword = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchKeyword = keyword;
    });

    try {
      if (widget.remote && widget.remoteFetch != null) {
        // 远程搜索
        final results = await widget.remoteFetch!(keyword);
        setState(() {
          _displayData = results;
          _isSearching = false;
        });
      } else if (widget.filterable) {
        // 本地过滤
        final results = _filterLocalData(widget.data, keyword);
        setState(() {
          _displayData = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });

      // 显示用户友好的错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('搜索失败，请稍后重试', style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(label: '重试', textColor: Colors.white, onPressed: () => _handleSearch()),
          ),
        );
      }

      // 记录详细错误信息（开发环境）
      debugPrint('TreeSelect搜索失败: $e');

      // 可以在这里添加错误上报逻辑
      // _reportError('search_error', e.toString(), keyword);
    }
  }

  // 本地过滤数据
  List<TreeNode> _filterLocalData(List<TreeNode> nodes, String keyword) {
    List<TreeNode> results = [];

    for (var node in nodes) {
      // 检查当前节点是否匹配
      if (node.label.toLowerCase().contains(keyword.toLowerCase()) || node.id.toLowerCase().contains(keyword.toLowerCase())) {
        // 如果当前节点匹配，直接添加该节点（包含其所有子节点）
        results.add(node);
      } else if (node.children != null) {
        // 如果当前节点不匹配，递归检查子节点
        final childResults = _filterLocalData(node.children!, keyword);
        if (childResults.isNotEmpty) {
          // 如果子节点有匹配，只添加匹配的子节点，不添加父节点
          results.addAll(childResults);
        }
      }
    }

    return results;
  }

  // 清空搜索
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _displayData = widget.data;
      _searchKeyword = '';
    });
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

class _TreeBottomSheet extends StatefulWidget {
  final List<TreeNode> data;
  final TreeNode? selectedNode;
  final Function(TreeNode) onSelect;
  final List<String> selectedPath;

  // 搜索相关属性
  final bool remote;
  final bool filterable;
  final TextEditingController searchController;
  final Function() onSearch;
  final Function() onClearSearch;
  final bool isSearching;
  final String searchKeyword;

  // 新增：远程搜索函数，直接传递给弹窗
  final Future<List<TreeNode>> Function(String keyword)? remoteFetch;

  const _TreeBottomSheet({
    required this.data,
    required this.selectedNode,
    required this.onSelect,
    required this.selectedPath,
    this.remote = false,
    this.filterable = false,
    required this.searchController,
    required this.onSearch,
    required this.onClearSearch,
    required this.isSearching,
    required this.searchKeyword,
    this.remoteFetch,
  });

  @override
  State<_TreeBottomSheet> createState() => _TreeBottomSheetState();
}

class _TreeBottomSheetState extends State<_TreeBottomSheet> with TickerProviderStateMixin {
  Set<String> expandedNodes = {};
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late ScrollController _scrollController;

  // 新增：搜索相关状态
  List<TreeNode> _currentData = [];
  bool _isSearching = false;
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _scrollController = ScrollController();
    _slideController.forward();

    // 初始化当前数据
    _currentData = widget.data;
    _isSearching = widget.isSearching;
    _searchKeyword = widget.searchKeyword;

    // 根据选中路径自动展开节点
    _expandSelectedPath();

    // 延迟滚动到选中项位置
    if (widget.selectedNode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedItem();
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_TreeBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果数据发生变化，更新当前数据
    if (oldWidget.data != widget.data) {
      setState(() {
        _currentData = widget.data;
      });
    }

    // 如果搜索状态发生变化，更新搜索状态
    if (oldWidget.isSearching != widget.isSearching) {
      setState(() {
        _isSearching = widget.isSearching;
      });
    }
  }

  // 根据选中路径自动展开节点
  void _expandSelectedPath() {
    if (widget.selectedPath.isNotEmpty) {
      // 展开选中路径上的所有父节点（除了最后一个节点，因为它是选中项本身）
      for (int i = 0; i < widget.selectedPath.length - 1; i++) {
        expandedNodes.add(widget.selectedPath[i]);
      }
    }
  }

  // 处理搜索
  void _handleSearch() async {
    final keyword = widget.searchController.text.trim();
    if (keyword.isEmpty) {
      setState(() {
        _currentData = widget.data;
        _searchKeyword = '';
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchKeyword = keyword;
    });

    try {
      if (widget.remote && widget.remoteFetch != null) {
        // 远程搜索 - 直接调用远程搜索函数
        final results = await widget.remoteFetch!(keyword);
        if (mounted) {
          setState(() {
            _currentData = results;
            _isSearching = false;
          });
        }
      } else if (widget.filterable) {
        // 本地过滤
        final results = _filterLocalData(widget.data, keyword);
        setState(() {
          _currentData = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });

        // 显示用户友好的错误提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('搜索失败，请稍后重试', style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(label: '重试', textColor: Colors.white, onPressed: () => _handleSearch()),
          ),
        );
      }

      // 记录详细错误信息（开发环境）
      debugPrint('TreeSelect弹窗搜索失败: $e');

      // 可以在这里添加错误上报逻辑
      // _reportError('search_error', e.toString(), keyword);
    }
  }

  // 本地过滤数据
  List<TreeNode> _filterLocalData(List<TreeNode> nodes, String keyword) {
    List<TreeNode> results = [];

    for (var node in nodes) {
      // 检查当前节点是否匹配
      if (node.label.toLowerCase().contains(keyword.toLowerCase()) || node.id.toLowerCase().contains(keyword.toLowerCase())) {
        // 如果当前节点匹配，直接添加该节点（包含其所有子节点）
        results.add(node);
      } else if (node.children != null) {
        // 如果当前节点不匹配，递归检查子节点
        final childResults = _filterLocalData(node.children!, keyword);
        if (childResults.isNotEmpty) {
          // 如果子节点有匹配，只添加匹配的子节点，不添加父节点
          results.addAll(childResults);
        }
      }
    }

    return results;
  }

  // 清空搜索
  void _clearSearch() {
    widget.searchController.clear();
    setState(() {
      _currentData = widget.data;
      _searchKeyword = '';
    });
  }

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

  void _toggleExpanded(String nodeId) {
    setState(() {
      if (expandedNodes.contains(nodeId)) {
        expandedNodes.remove(nodeId);
      } else {
        expandedNodes.add(nodeId);
      }
    });
  }

  Widget _buildTreeItem(TreeNode node, int level) {
    final hasChildren = node.children != null && node.children!.isNotEmpty;
    final isExpanded = expandedNodes.contains(node.id);
    final isSelected = widget.selectedNode?.id == node.id;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              widget.onSelect(node);
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
                      child: AnimatedRotation(
                        turns: isExpanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.keyboard_arrow_right_rounded, size: 22, color: Colors.grey.shade600),
                      ),
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
            child: Column(children: node.children!.map((child) => _buildTreeItem(child, level + 1)).toList()),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 16, bottom: 8),
              width: 32,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            // 标题栏
            Container(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Row(
                children: [
                  // 标题区域
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '请选择',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.grey.shade900, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '从以下选项中选择您需要的内容',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  // 关闭按钮
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(Icons.close_rounded, color: Colors.grey.shade600, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 搜索输入框
            if (widget.remote || widget.filterable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.searchController,
                        decoration: InputDecoration(
                          hintText: widget.remote ? '输入关键词搜索' : '输入关键词过滤',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                          suffixIcon: _searchKeyword.isNotEmpty
                              ? IconButton(
                                  onPressed: _clearSearch,
                                  icon: Icon(Icons.clear, color: Colors.grey.shade400, size: 20),
                                  tooltip: '清除搜索',
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            _handleSearch();
                          }
                        },
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
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (widget.remote)
                      ElevatedButton(
                        onPressed: _isSearching ? null : _handleSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: _isSearching
                            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : const Text('搜索'),
                      ),
                  ],
                ),
              ),
            // 树形列表
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _currentData.length,
                itemBuilder: (context, index) {
                  return _buildTreeItem(_currentData[index], 0);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
