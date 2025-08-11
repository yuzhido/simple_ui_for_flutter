import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';

class CascadingSelectPage extends StatefulWidget {
  const CascadingSelectPage({super.key});
  @override
  State<CascadingSelectPage> createState() => _CascadingSelectPageState();
}

class _CascadingSelectPageState extends State<CascadingSelectPage> {
  // 多选模式状态
  final List<dynamic> _multipleSelected = [];

  // 单级模式状态
  final List<CascadingItem<String>> _singleSelected = [];

  // 自定义数据状态
  final List<dynamic> _customSelected = [];
  final List<CascadingItem<String>> _customSingleSelected = [];

  // 基础示例数据
  final List<CascadingItem<String>> _basicOptions = [
    CascadingItem(
      label: '北京市',
      value: 'beijing',
      children: [
        CascadingItem(
          label: '朝阳区',
          value: 'chaoyang',
          children: const [
            CascadingItem(label: '三里屯街道', value: 'sanlitun'),
            CascadingItem(label: '建外街道', value: 'jianwai'),
            CascadingItem(label: '朝外街道', value: 'chaowai'),
          ],
        ),
        CascadingItem(
          label: '海淀区',
          value: 'haidian',
          children: const [
            CascadingItem(label: '中关村街道', value: 'zhongguancun'),
            CascadingItem(label: '学院路街道', value: 'xueyuanlu'),
            CascadingItem(label: '清华园街道', value: 'qinghuayuan'),
          ],
        ),
      ],
    ),
    CascadingItem(
      label: '上海市',
      value: 'shanghai',
      children: [
        CascadingItem(
          label: '浦东新区',
          value: 'pudong',
          children: const [
            CascadingItem(label: '陆家嘴街道', value: 'lujiazui'),
            CascadingItem(label: '花木街道', value: 'huamu'),
            CascadingItem(label: '金桥街道', value: 'jinqiao'),
          ],
        ),
        CascadingItem(
          label: '黄浦区',
          value: 'huangpu',
          children: const [
            CascadingItem(label: '外滩街道', value: 'waitan'),
            CascadingItem(label: '南京东路街道', value: 'nanjingdonglu'),
            CascadingItem(label: '豫园街道', value: 'yuyuan'),
          ],
        ),
      ],
    ),
  ];

  // 商品分类数据
  final List<CascadingItem<String>> _productOptions = [
    CascadingItem(
      label: '电子产品',
      value: 'electronics',
      children: [
        CascadingItem(
          label: '手机数码',
          value: 'mobile',
          children: const [
            CascadingItem(label: '智能手机', value: 'smartphone'),
            CascadingItem(label: '平板电脑', value: 'tablet'),
            CascadingItem(label: '智能手表', value: 'smartwatch'),
            CascadingItem(label: '蓝牙耳机', value: 'earphone'),
          ],
        ),
        CascadingItem(
          label: '电脑办公',
          value: 'computer',
          children: const [
            CascadingItem(label: '笔记本电脑', value: 'laptop'),
            CascadingItem(label: '台式电脑', value: 'desktop'),
            CascadingItem(label: '显示器', value: 'monitor'),
            CascadingItem(label: '键盘鼠标', value: 'keyboard'),
          ],
        ),
      ],
    ),
    CascadingItem(
      label: '服装鞋帽',
      value: 'clothing',
      children: [
        CascadingItem(
          label: '男装',
          value: 'mens',
          children: const [
            CascadingItem(label: 'T恤', value: 'tshirt'),
            CascadingItem(label: '衬衫', value: 'shirt'),
            CascadingItem(label: '牛仔裤', value: 'jeans'),
            CascadingItem(label: '运动鞋', value: 'sneakers'),
          ],
        ),
        CascadingItem(
          label: '女装',
          value: 'womens',
          children: const [
            CascadingItem(label: '连衣裙', value: 'dress'),
            CascadingItem(label: '上衣', value: 'top'),
            CascadingItem(label: '半身裙', value: 'skirt'),
            CascadingItem(label: '高跟鞋', value: 'heels'),
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('级联选择组件示例'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('基础用法'),
            const SizedBox(height: 16),

            _buildExampleCard(
              title: '多选模式（第三级多选）',
              description: '支持第三级多选，包含"不限"选项',
              child: CascadingSelect<String>(
                options: _basicOptions,
                title: '选择地区',
                multiple: true,
                showUnlimited: true,
                defaultSelectedValues: _multipleSelected,
                onConfirm: (selected) {
                  setState(() {
                    _multipleSelected.clear();
                    _multipleSelected.addAll(selected.map((e) => e.value));
                  });
                  _showResult('多选结果', selected.map((e) => e.label).join(', '));
                },
              ),
            ),

            const SizedBox(height: 16),

            _buildExampleCard(
              title: '单级模式（每级单选）',
              description: '每级独立选择，不自动选中下级',
              child: CascadingSelect<String>(
                options: _basicOptions,
                title: '选择地区',
                multiple: false,
                onConfirm: (selected) {
                  setState(() {
                    _singleSelected.clear();
                    _singleSelected.addAll(selected);
                  });
                  _showResult('单选路径', selected.map((e) => e.label).join(' / '));
                },
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('高级用法'),
            const SizedBox(height: 16),

            _buildExampleCard(
              title: '不显示"不限"选项',
              description: '多选模式下隐藏"不限"选项',
              child: CascadingSelect<String>(
                options: _productOptions,
                title: '选择商品分类',
                multiple: true,
                showUnlimited: false,
                defaultSelectedValues: _customSelected,
                onConfirm: (selected) {
                  setState(() {
                    _customSelected.clear();
                    _customSelected.addAll(selected.map((e) => e.value));
                  });
                  _showResult('商品分类', selected.map((e) => e.label).join(', '));
                },
              ),
            ),

            const SizedBox(height: 16),

            _buildExampleCard(
              title: '单级模式 - 商品分类',
              description: '用于商品分类等场景',
              child: CascadingSelect<String>(
                options: _productOptions,
                title: '选择商品分类',
                multiple: false,
                onConfirm: (selected) {
                  setState(() {
                    _customSingleSelected.clear();
                    _customSingleSelected.addAll(selected);
                  });
                  _showResult('商品分类路径', selected.map((e) => e.label).join(' / '));
                },
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('选择结果展示'),
            const SizedBox(height: 16),

            if (_multipleSelected.isNotEmpty) ...[
              _buildResultCard(
                title: '多选结果',
                content: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _multipleSelected
                      .map(
                        (val) => Chip(
                          label: Text(_findLabelByValue(val) ?? val.toString()),
                          backgroundColor: const Color(0xFFEEF4FF),
                          labelStyle: const TextStyle(color: Color(0xFF007AFF)),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_singleSelected.isNotEmpty) ...[
              _buildResultCard(
                title: '单选路径',
                content: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F8FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF007AFF), width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _singleSelected.map((e) => e.label).join(' / '),
                          style: const TextStyle(color: Color(0xFF007AFF), fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_customSelected.isNotEmpty) ...[
              _buildResultCard(
                title: '商品分类多选',
                content: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _customSelected
                      .map(
                        (val) => Chip(
                          label: Text(_findProductLabelByValue(val) ?? val.toString()),
                          backgroundColor: const Color(0xFFE8F5E8),
                          labelStyle: const TextStyle(color: Color(0xFF2E7D32)),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_customSingleSelected.isNotEmpty) ...[
              _buildResultCard(
                title: '商品分类路径',
                content: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF4CAF50), width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.category, color: Colors.green[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _customSingleSelected.map((e) => e.label).join(' / '),
                          style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
            _buildSectionTitle('使用说明'),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '组件特性：',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureItem('• 支持左右滑动查看多层级数据'),
                  _buildFeatureItem('• 多选模式：第三级多选 + "不限"选项'),
                  _buildFeatureItem('• 单级模式：每级独立选择，不自动选中下级'),
                  _buildFeatureItem('• 支持自定义标题和样式'),
                  _buildFeatureItem('• 响应式布局，适配不同屏幕尺寸'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
      ),
    );
  }

  Widget _buildExampleCard({required String title, required String description, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 4),
          Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildResultCard({required String title, required Widget content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF1976D2))),
    );
  }

  void _showResult(String title, String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(content, style: const TextStyle(fontSize: 12)),
          ],
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFF007AFF),
      ),
    );
  }

  String? _findLabelByValue(dynamic value) {
    for (final first in _basicOptions) {
      for (final second in first.children) {
        for (final third in second.children) {
          if (third.value == value) return third.label;
        }
      }
    }
    return null;
  }

  String? _findProductLabelByValue(dynamic value) {
    for (final first in _productOptions) {
      for (final second in first.children) {
        for (final third in second.children) {
          if (third.value == value) return third.label;
        }
      }
    }
    return null;
  }
}
