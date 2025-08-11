import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';

class DropdownSelectPage extends StatefulWidget {
  const DropdownSelectPage({super.key});
  @override
  State<DropdownSelectPage> createState() => _DropdownSelectPageState();
}

class _DropdownSelectPageState extends State<DropdownSelectPage> {
  SelectData<String>? _singleSelected;
  final List<SelectData<String>> _multipleSelected = [];
  SelectData<String>? _remoteSelected;
  final List<SelectData<String>> _remoteMultipleSelected = [];

  // 新增：用于演示编辑时的数据回显
  final List<SelectData<String>> _editModeData = [
    SelectData(label: '编辑模式数据1', value: 'edit1', data: 'edit_data1'),
    SelectData(label: '编辑模式数据2', value: 'edit2', data: 'edit_data2'),
  ];

  // 新增：编辑模式的选择状态
  SelectData<String>? _editModeSingleSelected;
  final List<SelectData<String>> _editModeMultipleSelected = [];
  SelectData<String>? _editModeRemoteSelected;

  final List<SelectData<String>> _options = const [
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

  // 模拟远程数据获取
  Future<List<SelectData<String>>> _fetchRemoteData() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    // 模拟搜索关键词
    final keyword = _searchController.text.toLowerCase();
    if (keyword.isEmpty) {
      return _options;
    }

    return _options
        .where((item) => item.label.toLowerCase().contains(keyword) || item.value.toLowerCase().contains(keyword))
        .toList();
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 设置默认值
    _singleSelected = _options.first;
    _multipleSelected.addAll([_options.first, _options[1]]);

    // 初始化编辑模式的选择状态
    _editModeSingleSelected = _editModeData.first;
    _editModeMultipleSelected.addAll(_editModeData);
    _editModeRemoteSelected = _editModeData.first;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

            // 基础单选
            _buildSectionTitle('1. 基础单选'),
            const SizedBox(height: 8),
            DropdownChoose<String>(
              list: _options,
              multiple: false,
              defaultValue: _singleSelected,
              onSingleSelected: (val) {
                setState(() => _singleSelected = val);
                _toast('单选选择了：${val.label}');
              },
            ),
            const SizedBox(height: 24),

            // 基础多选
            _buildSectionTitle('2. 基础多选'),
            const SizedBox(height: 8),
            DropdownChoose<String>(
              list: _options,
              multiple: true,
              defaultValue: _options.first,
              onMultipleSelected: (vals) {
                setState(() {
                  _multipleSelected
                    ..clear()
                    ..addAll(vals);
                });
                _toast('多选结果：${vals.map((e) => e.label).join(', ')}');
              },
            ),
            const SizedBox(height: 24),

            // 本地筛选
            _buildSectionTitle('3. 本地筛选（filterable: true）'),
            const SizedBox(height: 8),
            DropdownChoose<String>(
              list: _options,
              multiple: true,
              filterable: true,
              onMultipleSelected: (vals) => _toast('筛选结果：${vals.map((e) => e.label).join(', ')}'),
            ),
            const SizedBox(height: 24),

            // 远程搜索
            _buildSectionTitle('4. 远程搜索（remote: true）'),
            const SizedBox(height: 8),
            DropdownChoose<String>(
              remote: true,
              remoteFetch: _fetchRemoteData,
              multiple: false,
              defaultValue: _remoteSelected,
              onSingleSelected: (val) {
                setState(() => _remoteSelected = val);
                _toast('远程搜索选择了：${val.label}');
              },
            ),
            const SizedBox(height: 24),

            // 远程多选
            _buildSectionTitle('5. 远程多选搜索'),
            const SizedBox(height: 8),
            DropdownChoose<String>(
              remote: true,
              remoteFetch: _fetchRemoteData,
              multiple: true,
              defaultValue: _options.first,
              onMultipleSelected: (vals) {
                setState(() {
                  _remoteMultipleSelected
                    ..clear()
                    ..addAll(vals);
                });
                _toast('远程多选结果：${vals.map((e) => e.label).join(', ')}');
              },
            ),
            const SizedBox(height: 24),

            // 无默认值
            _buildSectionTitle('6. 无默认值'),
            const SizedBox(height: 8),
            DropdownChoose<String>(list: _options, multiple: false, onSingleSelected: (val) => _toast('选择了：${val.label}')),
            const SizedBox(height: 24),

            // 编辑模式数据回显
            _buildSectionTitle('7. 编辑模式数据回显（defaultValue）'),
            const SizedBox(height: 8),
            DropdownChoose<String>(
              list: _options,
              multiple: false,
              defaultValue: _editModeSingleSelected,
              onSingleSelected: (val) {
                setState(() => _editModeSingleSelected = val);
                _toast('编辑模式选择了：${val.label}');
              },
            ),
            const SizedBox(height: 8),
            Text(
              '当前选择：${_editModeSingleSelected?.label ?? '未选择'}',
              style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            // 编辑模式多选数据回显
            _buildSectionTitle('8. 编辑模式多选数据回显'),
            const SizedBox(height: 8),
            DropdownChoose<String>(
              list: _options,
              multiple: true,
              defaultValue: _editModeMultipleSelected,
              onMultipleSelected: (vals) {
                setState(() {
                  _editModeMultipleSelected
                    ..clear()
                    ..addAll(vals);
                });
                _toast('编辑模式多选：${vals.map((e) => e.label).join(', ')}');
              },
            ),
            const SizedBox(height: 8),
            Text(
              '当前选择：${_editModeMultipleSelected.isEmpty ? '未选择' : _editModeMultipleSelected.map((e) => e.label).join(', ')}',
              style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            // 远程搜索 + 编辑模式数据回显
            _buildSectionTitle('9. 远程搜索 + 编辑模式数据回显'),
            const SizedBox(height: 8),
            DropdownChoose<String>(
              remote: true,
              remoteFetch: _fetchRemoteData,
              multiple: false,
              defaultValue: _editModeRemoteSelected,
              onSingleSelected: (val) {
                setState(() => _editModeRemoteSelected = val);
                _toast('远程+编辑模式选择了：${val.label}');
              },
            ),
            const SizedBox(height: 8),
            Text(
              '当前选择：${_editModeRemoteSelected?.label ?? '未选择'}',
              style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            // 模拟真实编辑场景
            _buildSectionTitle('10. 模拟真实编辑场景'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFF9800)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '场景说明：',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                  ),
                  const SizedBox(height: 8),
                  const Text('1. 新增时：用户通过远程搜索选择了"编辑模式数据1"'),
                  const Text('2. 编辑时：需要显示之前选择的"编辑模式数据1"'),
                  const Text('3. 即使远程搜索没有返回这个数据，也能正确显示'),
                  const SizedBox(height: 16),
                  DropdownChoose<String>(
                    remote: true,
                    remoteFetch: _fetchRemoteData,
                    multiple: false,
                    defaultValue: _editModeRemoteSelected,
                    onSingleSelected: (val) {
                      setState(() => _editModeRemoteSelected = val);
                      _toast('编辑场景选择了：${val.label}');
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '当前选择：${_editModeRemoteSelected?.label ?? '未选择'}',
                    style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 显示当前选择状态
            _buildSectionTitle('当前选择状态'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('单选：${_singleSelected?.label ?? '未选择'}'),
                  const SizedBox(height: 8),
                  Text('多选：${_multipleSelected.isEmpty ? '未选择' : _multipleSelected.map((e) => e.label).join(', ')}'),
                  const SizedBox(height: 8),
                  Text('远程单选：${_remoteSelected?.label ?? '未选择'}'),
                  const SizedBox(height: 8),
                  Text(
                    '远程多选：${_remoteMultipleSelected.isEmpty ? '未选择' : _remoteMultipleSelected.map((e) => e.label).join(', ')}',
                  ),
                ],
              ),
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
                  Text('• multiple: 控制单选/多选模式'),
                  Text('• filterable: 启用本地筛选功能'),
                  Text('• remote: 启用远程搜索功能'),
                  Text('• remoteFetch: 远程数据获取函数'),
                  Text('• defaultValue: 设置默认选中值（单选时传入SelectData<T>，多选时传入List<SelectData<T>>）'),
                  Text('• onSingleSelected: 单选回调'),
                  Text('• onMultipleSelected: 多选回调'),
                  SizedBox(height: 8),
                  Text(
                    '注意：filterable 和 remote 不能同时使用',
                    style: TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '编辑模式：使用defaultValue参数可以确保编辑时显示之前选择的数据，即使这些数据不在当前list或远程搜索结果中',
                    style: TextStyle(color: Color(0xFF1976D2), fontSize: 12),
                  ),
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

  void _toast(String msg) {
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
