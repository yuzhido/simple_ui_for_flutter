// 模拟本地数据
import 'package:simple_ui/models/tree_node.dart';

final List<TreeNode> localData = [
  TreeNode(
    id: '1',
    label: '北京市',
    children: [
      TreeNode(
        id: '1-1',
        label: '朝阳区',
        children: [
          TreeNode(id: '1-1-1', label: '三里屯街道'),
          TreeNode(id: '1-1-2', label: '建外街道'),
          TreeNode(id: '1-1-3', label: '呼家楼街道'),
        ],
      ),
      TreeNode(
        id: '1-2',
        label: '海淀区',
        children: [
          TreeNode(id: '1-2-1', label: '中关村街道'),
          TreeNode(id: '1-2-2', label: '学院路街道'),
          TreeNode(id: '1-2-3', label: '清华园街道'),
        ],
      ),
      TreeNode(
        id: '1-3',
        label: '西城区',
        children: [
          TreeNode(id: '1-3-1', label: '西长安街街道'),
          TreeNode(id: '1-3-2', label: '新街口街道'),
        ],
      ),
    ],
  ),
  TreeNode(
    id: '2',
    label: '上海市',
    children: [
      TreeNode(
        id: '2-1',
        label: '浦东新区',
        children: [
          TreeNode(id: '2-1-1', label: '陆家嘴街道'),
          TreeNode(id: '2-1-2', label: '花木街道'),
        ],
      ),
      TreeNode(
        id: '2-2',
        label: '黄浦区',
        children: [
          TreeNode(id: '2-2-1', label: '南京东路街道'),
          TreeNode(id: '2-2-2', label: '外滩街道'),
        ],
      ),
    ],
  ),
  TreeNode(
    id: '3',
    label: '广州市',
    children: [
      TreeNode(
        id: '3-1',
        label: '天河区',
        children: [
          TreeNode(id: '3-1-1', label: '珠江新城街道'),
          TreeNode(id: '3-1-2', label: '天河南街道'),
        ],
      ),
      TreeNode(
        id: '3-2',
        label: '越秀区',
        children: [
          TreeNode(id: '3-2-1', label: '北京街道'),
          TreeNode(id: '3-2-2', label: '六榕街道'),
        ],
      ),
    ],
  ),
];
