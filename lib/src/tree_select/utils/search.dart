import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';
import 'package:simple_ui/src/tree_select/utils/tips.dart';

/// 树形选择搜索控制器
/// 统一管理搜索状态和逻辑，简化使用
class TreeSearchController {
  final TextEditingController searchController;
  List<TreeNode> originalData;
  final bool remote;
  final bool filterable;
  final Future<List<TreeNode>> Function(String)? remoteFetch;

  // 搜索状态
  List<TreeNode> _currentData;
  String _searchKeyword = '';
  bool _isSearching = false;

  // 回调函数
  final VoidCallback? onStateChanged;
  final BuildContext? context;

  TreeSearchController({
    required this.searchController,
    required this.originalData,
    this.remote = false,
    this.filterable = true,
    this.remoteFetch,
    this.onStateChanged,
    this.context,
  }) : _currentData = originalData;

  // Getters
  List<TreeNode> get currentData => _currentData;
  String get searchKeyword => _searchKeyword;
  bool get isSearching => _isSearching;

  /// 执行搜索
  Future<void> search([String? keyword]) async {
    final searchText = keyword ?? searchController.text.trim();

    // 只有在非远程搜索模式下，空输入才清空搜索
    // 远程搜索模式下，空输入应该执行搜索（通常返回默认数据）
    if (searchText.isEmpty && !remote) {
      clear();
      return;
    }

    _setSearching(true);
    _searchKeyword = searchText;

    try {
      List<TreeNode> results;

      if (remote && remoteFetch != null) {
        // 远程搜索
        results = await remoteFetch!(searchText);
      } else if (filterable) {
        // 本地过滤
        results = _filterData(originalData, searchText);
      } else {
        results = originalData;
      }

      _currentData = results;
      _setSearching(false);
    } catch (e) {
      _setSearching(false);

      // 显示错误提示
      if (context != null) {
        tips(context!, '搜索失败，请稍后重试');
      }

      debugPrint('TreeSearch搜索失败: $e');
    }
  }

  /// 更新源数据
  void updateSourceData(List<TreeNode> newData) {
    originalData = newData;
    if (!isSearching) {
      _currentData = newData;
      onStateChanged?.call();
    }
  }

  /// 清空搜索
  void clear() {
    searchController.clear();
    _currentData = originalData;
    _searchKeyword = '';
    _setSearching(false);
  }

  /// 设置搜索状态
  void _setSearching(bool searching) {
    _isSearching = searching;
    onStateChanged?.call();
  }

  /// 本地数据过滤
  List<TreeNode> _filterData(List<TreeNode> nodes, String keyword) {
    List<TreeNode> results = [];
    final lowerKeyword = keyword.toLowerCase();

    for (var node in nodes) {
      // 检查当前节点是否匹配
      if (node.label.toLowerCase().contains(lowerKeyword) || node.id.toLowerCase().contains(lowerKeyword)) {
        // 如果当前节点匹配，直接添加该节点（包含其所有子节点）
        results.add(node);
      } else if (node.children != null) {
        // 如果当前节点不匹配，递归检查子节点
        final childResults = _filterData(node.children!, keyword);
        if (childResults.isNotEmpty) {
          // 如果子节点有匹配，只添加匹配的子节点，不添加父节点
          results.addAll(childResults);
        }
      }
    }

    return results;
  }

  /// 释放资源
  void dispose() {
    // 搜索控制器由外部管理，这里不释放
  }
}

/// 简化的搜索工具类
/// 提供静态方法用于快速创建搜索功能
class TreeSearchUtils {
  /// 创建搜索控制器
  static TreeSearchController createController({
    required TextEditingController searchController,
    required List<TreeNode> originalData,
    bool remote = false,
    bool filterable = true,
    Future<List<TreeNode>> Function(String)? remoteFetch,
    VoidCallback? onStateChanged,
    BuildContext? context,
  }) {
    return TreeSearchController(
      searchController: searchController,
      originalData: originalData,
      remote: remote,
      filterable: filterable,
      remoteFetch: remoteFetch,
      onStateChanged: onStateChanged,
      context: context,
    );
  }

  /// 快速过滤数据（静态方法，用于简单场景）
  static List<TreeNode> quickFilter(List<TreeNode> nodes, String keyword) {
    if (keyword.isEmpty) return nodes;

    List<TreeNode> results = [];
    final lowerKeyword = keyword.toLowerCase();

    for (var node in nodes) {
      if (node.label.toLowerCase().contains(lowerKeyword) || node.id.toLowerCase().contains(lowerKeyword)) {
        results.add(node);
      } else if (node.children != null) {
        final childResults = quickFilter(node.children!, keyword);
        if (childResults.isNotEmpty) {
          results.addAll(childResults);
        }
      }
    }

    return results;
  }
}
