import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';

class DropdownSelectPage extends StatefulWidget {
  const DropdownSelectPage({super.key});
  @override
  State<DropdownSelectPage> createState() => _DropdownSelectPageState();
}

class _DropdownSelectPageState extends State<DropdownSelectPage> {
  // 下拉选择数据
  final List<SelectData<String>> singleChoose = const [
    SelectData(label: '选项1', value: '1', data: 'data1'),
    SelectData(label: '选项2', value: '2', data: 'data2'),
    SelectData(label: '选项3', value: '3', data: 'data3'),
    SelectData(label: '选项4', value: '4', data: 'data4'),
    SelectData(label: '选项5', value: '5', data: 'data5'),
    SelectData(label: '苹果', value: 'apple', data: 'fruit'),
    SelectData(label: '香蕉', value: 'banana', data: 'fruit'),
    SelectData(label: '橙子', value: 'orange', data: 'fruit'),
    SelectData(label: '葡萄', value: 'grape', data: 'fruit'),
    SelectData(label: '西瓜', value: 'watermelon', data: 'fruit'),
  ];

  // 当前选中的值
  SelectData<String>? selectedValue;
  SelectData<String>? filteredValue;

  @override
  void initState() {
    super.initState();
    // 设置默认选中第一个选项
    selectedValue = singleChoose.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('下拉选择组件示例'), backgroundColor: const Color(0xFF007AFF), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DropdownChoose 组件使用示例', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // 基础单选示例
            _buildSectionTitle('1. 基础单选'),
            const SizedBox(height: 8),
            Text(
              '当前选择: ${selectedValue?.label ?? '未选择'}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            DropdownChoose<String>(
              list: singleChoose,
              defaultValue: selectedValue,
              onSingleSelected: (val) {
                setState(() {
                  selectedValue = val;
                });
                _showToast('选择了：${val.label}');
              },
            ),
            const SizedBox(height: 24),

            // 本地搜索过滤示例
            _buildSectionTitle('2. 本地搜索过滤（filterable: true）'),
            const SizedBox(height: 8),
            Text(
              '当前选择: ${filteredValue?.label ?? '未选择'}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            DropdownChoose<String>(
              list: singleChoose,
              filterable: true,
              defaultValue: filteredValue,
              onSingleSelected: (val) {
                setState(() {
                  filteredValue = val;
                });
                _showToast('过滤选择了：${val.label}');
              },
            ),
            const SizedBox(height: 24),

            // 使用说明
            _buildSectionTitle('使用说明'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2196F3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '组件特性：',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
                  ),
                  SizedBox(height: 8),
                  Text('• list: 传入选项数据列表'),
                  Text('• defaultValue: 设置默认选中值'),
                  Text('• filterable: 启用本地搜索过滤功能'),
                  Text('• onSingleSelected: 单选回调函数'),
                  Text('• 支持自定义样式和交互'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
    );
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF007AFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
