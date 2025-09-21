import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:simple_ui/simple_ui.dart';

class TreeSelectPage extends StatefulWidget {
  const TreeSelectPage({super.key});
  @override
  State<TreeSelectPage> createState() => _TreeSelectPageState();
}

class _TreeSelectPageState extends State<TreeSelectPage> {
  List<TreeNode> list = [];
  List<TreeNode> list1 = [];
  TreeNode? selectedNode;
  String _dynamicInitialValue = 'beijing'; // 用于动态更新initialValue的演示
  String? _bidirectionalValue; // 用于演示initialValue双向绑定

  // 模拟后端返回的JSON数据
  final String rawJsonData = '''
  [
    {
      "label": "北京市",
      "id": "beijing",
      "children": [
        {
          "label": "朝阳区",
          "id": "chaoyang",
          "children": [
            {
              "label": "三里屯街道",
              "id": "sanlitun",
              "children": [
                {
                  "label": "三里屯社区",
                  "id": "sanlitun_community"
                },
                {
                  "label": "工体社区",
                  "id": "gongti_community"
                }
              ]
            },
            {
              "label": "建外街道",
              "id": "jianwai",
              "children": [
                {
                  "label": "建外社区",
                  "id": "jianwai_community"
                },
                {
                  "label": "永安里社区",
                  "id": "yonganli_community"
                }
              ]
            }
          ]
        },
        {
          "label": "海淀区",
          "id": "haidian",
          "children": [
            {
              "label": "中关村街道",
              "id": "zhongguancun",
              "children": [
                {
                  "label": "中关村社区",
                  "id": "zhongguancun_community"
                },
                {
                  "label": "清华园社区",
                  "id": "qinghuayuan_community"
                }
              ]
            },
            {
              "label": "学院路街道",
              "id": "xueyuanlu",
              "children": [
                {
                  "label": "学院路社区",
                  "id": "xueyuanlu_community"
                },
                {
                  "label": "北航社区",
                  "id": "beihang_community"
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "label": "上海市",
      "id": "shanghai",
      "children": [
        {
          "label": "浦东新区",
          "id": "pudong",
          "children": [
            {
              "label": "陆家嘴街道",
              "id": "lujiazui",
              "children": [
                {
                  "label": "陆家嘴社区",
                  "id": "lujiazui_community"
                },
                {
                  "label": "滨江社区",
                  "id": "binjiang_community"
                }
              ]
            },
            {
              "label": "花木街道",
              "id": "huamu",
              "children": [
                {
                  "label": "花木社区",
                  "id": "huamu_community"
                },
                {
                  "label": "联洋社区",
                  "id": "lianyang_community"
                }
              ]
            }
          ]
        },
        {
          "label": "黄浦区",
          "id": "huangpu",
          "children": [
            {
              "label": "外滩街道",
              "id": "waitan",
              "children": [
                {
                  "label": "外滩社区",
                  "id": "waitan_community"
                },
                {
                  "label": "南京东路社区",
                  "id": "nanjingdonglu_community"
                }
              ]
            },
            {
              "label": "豫园街道",
              "id": "yuyuan",
              "children": [
                {
                  "label": "豫园社区",
                  "id": "yuyuan_community"
                },
                {
                  "label": "老城厢社区",
                  "id": "laochengxiang_community"
                }
              ]
            }
          ]
        }
      ]
    }
  ]
  ''';
  final String ffff = '''
[
        {
          "label": "海淀区",
          "id": "haidian",
          "children": [
            {
              "label": "中关村街道",
              "id": "zhongguancun",
              "children": [
                {
                  "label": "中关村社区",
                  "id": "zhongguancun_community"
                },
                {
                  "label": "清华园社区",
                  "id": "qinghuayuan_community"
                }
              ]
            },
            {
              "label": "学院路街道",
              "id": "xueyuanlu",
              "children": [
                {
                  "label": "学院路社区",
                  "id": "xueyuanlu_community"
                },
                {
                  "label": "北航社区",
                  "id": "beihang_community"
                }
              ]
            }
          ]
        }
        ]
''';
  @override
  void initState() {
    super.initState();
    // 解析JSON数据
    _parseJsonData();

    // 预设一个选中值来测试自动展开功能
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && list.isNotEmpty) {
        setState(() {
          selectedNode = list[0].children![0].children![0]; // 选择"三里屯街道"
        });
      }
    });
  }

  // 解析JSON数据的方法
  void _parseJsonData() {
    try {
      final List<dynamic> jsonList = json.decode(rawJsonData);
      list = jsonList.map((json) => TreeNode.fromJson(json)).toList();
      final List<dynamic> jsonList1 = json.decode(ffff);
      list1 = jsonList1.map((json) => TreeNode.fromJson(json)).toList();
      setState(() {});
    } catch (e) {
      print('解析JSON数据失败: $e');
    }
  }

  // 获取指定ID的节点（用于演示）
  TreeNode? _getNodeById(String id) {
    return _findNodeById(list, id);
  }

  TreeNode? _findNodeById(List<TreeNode> nodes, String targetId) {
    for (var node in nodes) {
      if (node.id == targetId) {
        return node;
      }
      if (node.children != null) {
        final result = _findNodeById(node.children!, targetId);
        if (result != null) {
          return result;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('级联选择'), elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black87),
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.account_tree_rounded, color: Colors.blue.shade600, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '树形选择器',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('提示：每一级节点都可以选中作为最终结果', style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4)),
                    const SizedBox(height: 8),
                    const Text('新功能：选中项会自动展开路径并滚动到对应位置', style: TextStyle(fontSize: 12, color: Colors.blue, height: 1.4)),
                    const SizedBox(height: 20),
                    TreeSelect(
                      data: list,
                      placeholder: '请选择地区',
                      initialValue: selectedNode,
                      onValueChanged: (node) {
                        setState(() {
                          selectedNode = node;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text('已选择: ${node.label}'),
                              ],
                            ),
                            backgroundColor: Colors.green.shade600,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    // 演示initialValue功能的TreeSelect
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.blue.shade600, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '演示：使用initialValue自动选中',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue.shade700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('支持两种方式：1) 传入ID字符串 2) 传入TreeNode对象', style: TextStyle(fontSize: 12, color: Colors.blue.shade600, height: 1.4)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TreeSelect(
                                  data: list,
                                  placeholder: '通过ID自动选中',
                                  initialValueId: 'zhongguancun', // 通过ID自动选中"中关村街道"
                                  onValueChanged: (node) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('选择了: ${node.label}'),
                                        backgroundColor: Colors.blue.shade600,
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TreeSelect(
                                  data: list,
                                  placeholder: '通过对象自动选中',
                                  initialValue: _getNodeById('lujiazui'), // 通过TreeNode对象自动选中"陆家嘴街道"
                                  onValueChanged: (node) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('选择了: ${node.label}'),
                                        backgroundColor: Colors.blue.shade600,
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 演示initialValue双向绑定功能的TreeSelect
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade200, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.link, color: Colors.purple.shade600, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '演示：initialValue双向绑定',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.purple.shade700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('这个变量既作为初始值，又存储用户选择的值', style: TextStyle(fontSize: 12, color: Colors.purple.shade600, height: 1.4)),
                          const SizedBox(height: 8),
                          Text('工作原理：1) 有值时自动选中 2) 用户选择后自动更新变量 3) 支持动态修改', style: TextStyle(fontSize: 11, color: Colors.purple.shade500, height: 1.4)),
                          const SizedBox(height: 12),
                          // 状态指示器
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _bidirectionalValue == null ? Colors.grey.shade200 : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _bidirectionalValue == null ? Colors.grey.shade400 : Colors.green.shade400, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _bidirectionalValue == null ? Icons.circle_outlined : Icons.check_circle,
                                  size: 16,
                                  color: _bidirectionalValue == null ? Colors.grey.shade600 : Colors.green.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _bidirectionalValue == null ? '未选中' : '已选中',
                                  style: TextStyle(fontSize: 12, color: _bidirectionalValue == null ? Colors.grey.shade600 : Colors.green.shade600, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          TreeSelect(
                            data: list,
                            placeholder: '请选择地区',
                            initialValueId: _bidirectionalValue,
                            onValueChanged: (value) {
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => setState(() => _bidirectionalValue = 'beijing'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                child: const Text('预设北京'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () => setState(() => _bidirectionalValue = null),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                child: const Text('清空选择'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _bidirectionalValue = 'shanghai';
                                  });
                                  // 延迟一下再清空，测试状态同步
                                  Future.delayed(const Duration(milliseconds: 100), () {
                                    if (mounted) {
                                      setState(() {
                                        _bidirectionalValue = null;
                                      });
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                child: const Text('测试清空'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.purple.shade100, borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '当前存储的值:',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.purple.shade700),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _bidirectionalValue?.toString() ?? '未选择',
                                  style: TextStyle(fontSize: 14, color: Colors.purple.shade800, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '状态: ${_bidirectionalValue == null ? "已清空" : "有值"}',
                                  style: TextStyle(fontSize: 12, color: _bidirectionalValue == null ? Colors.red.shade600 : Colors.green.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 动态更新initialValue的演示
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.update, color: Colors.green.shade600, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '演示：动态更新initialValue',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green.shade700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('点击按钮可以动态改变组件的初始选中值', style: TextStyle(fontSize: 12, color: Colors.green.shade600, height: 1.4)),
                          const SizedBox(height: 16),
                          TreeSelect(data: list, placeholder: '动态初始值', initialValueId: _dynamicInitialValue),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ElevatedButton(
                                onPressed: () => setState(() => _dynamicInitialValue = 'beijing'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                child: const Text('选中北京'),
                              ),
                              ElevatedButton(
                                onPressed: () => setState(() => _dynamicInitialValue = 'shanghai'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                child: const Text('选中上海'),
                              ),
                              ElevatedButton(
                                onPressed: () => setState(() => _dynamicInitialValue = 'sanlitun_community'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                child: const Text('选中三里屯社区'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 演示远程搜索功能的TreeSelect
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.cloud_done, color: Colors.orange.shade600, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '演示：远程搜索功能',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.orange.shade700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('模拟从远程API搜索数据，输入关键词后点击搜索按钮', style: TextStyle(fontSize: 12, color: Colors.orange.shade600, height: 1.4)),
                          const SizedBox(height: 12),
                          TreeSelect(
                            data: list,
                            placeholder: '远程搜索地区',
                            remote: true,
                            remoteFetch: (keyword) async {
                              // 模拟网络延迟
                              await Future.delayed(const Duration(milliseconds: 800));

                              return list1;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 演示本地过滤功能的TreeSelect
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.teal.shade200, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.filter_list, color: Colors.teal.shade600, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '演示：本地过滤功能',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.teal.shade700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('在本地数据中实时过滤，输入关键词即可看到结果', style: TextStyle(fontSize: 12, color: Colors.teal.shade600, height: 1.4)),
                          const SizedBox(height: 12),
                          TreeSelect(
                            data: list,
                            placeholder: '本地过滤地区',
                            filterable: true,
                            onValueChanged: (node) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('本地过滤选择了: ${node.label}'),
                                  backgroundColor: Colors.teal.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (selectedNode != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade200, width: 1),
                    boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.blue.shade600, borderRadius: BorderRadius.circular(6)),
                            child: const Icon(Icons.info_outline, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '当前选择',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('ID', selectedNode!.id),
                      const SizedBox(height: 8),
                      _buildInfoRow('名称', selectedNode!.label),
                      const SizedBox(height: 8),
                      _buildInfoRow('是否有子节点', selectedNode!.children != null && selectedNode!.children!.isNotEmpty ? '是' : '否'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        ),
      ],
    );
  }
}
