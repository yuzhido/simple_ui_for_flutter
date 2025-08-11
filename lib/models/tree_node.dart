// 树结构数据模型
class TreeNode {
  final String label;
  final String id;
  final List<TreeNode>? children;

  TreeNode({required this.label, required this.id, this.children});

  // 从JSON创建TreeNode
  factory TreeNode.fromJson(Map<String, dynamic> json) {
    List<TreeNode>? childrenList;
    if (json['children'] != null) {
      childrenList = (json['children'] as List).map((child) => TreeNode.fromJson(child)).toList();
    }

    return TreeNode(label: json['label'], id: json['id'], children: childrenList);
  }
}
