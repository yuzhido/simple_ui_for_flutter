// 树结构数据模型
class TreeNode {
  final String label;
  final dynamic id; // 支持int或String类型
  final List<TreeNode>? children;
  final bool hasChildren; // 新增：是否有子节点（用于懒加载）

  TreeNode({
    required this.label, 
    required this.id, 
    this.children,
    this.hasChildren = false, // 默认为false，向后兼容
  }) : assert(id is String || id is int, 'id must be either String or int');

  // 从JSON创建TreeNode
  factory TreeNode.fromJson(Map<String, dynamic> json) {
    List<TreeNode>? childrenList;
    if (json['children'] != null) {
      childrenList = (json['children'] as List).map((child) => TreeNode.fromJson(child)).toList();
    }

    return TreeNode(
      label: json['label'], 
      id: json['id'], 
      children: childrenList,
      hasChildren: json['hasChildren'] ?? (childrenList != null && childrenList.isNotEmpty), // 从JSON读取或根据children判断
    );
  }

  // 创建一个带有新children的副本（用于懒加载更新）
  TreeNode copyWith({
    String? label,
    String? id,
    List<TreeNode>? children,
    bool? hasChildren,
  }) {
    return TreeNode(
      label: label ?? this.label,
      id: id ?? this.id,
      children: children ?? this.children,
      hasChildren: hasChildren ?? this.hasChildren,
    );
  }
}
