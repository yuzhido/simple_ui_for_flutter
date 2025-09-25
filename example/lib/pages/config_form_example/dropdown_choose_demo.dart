import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';

class DropdownChooseDemoPage extends StatefulWidget {
  const DropdownChooseDemoPage({super.key});
  @override
  State<DropdownChooseDemoPage> createState() => _DropdownChooseDemoPageState();
}

class _DropdownChooseDemoPageState extends State<DropdownChooseDemoPage> {
  final ConfigFormController _formController = ConfigFormController();
  final List<SelectData<String>> _deptOptions = const [
    SelectData(label: '销售部', value: 'sale', data: 'sale'),
    SelectData(label: '技术部', value: 'tech', data: 'tech'),
    SelectData(label: '人事部', value: 'hr', data: 'hr'),
    SelectData(label: '行政部', value: 'admin', data: 'admin'),
  ];

  Map<String, dynamic> _formData = {};

  Future<List<SelectData<String>>> _remoteSearch(String keyword) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (keyword.isEmpty) return _deptOptions;
    return _deptOptions.where((e) => e.label.contains(keyword) || e.value.contains(keyword)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final configs = <FormConfig>[
      FormConfig.dropdown<String>(
        DropdownFieldConfig<String>(
          name: 'deptSingle',
          label: '部门(单选)',
          required: true,
          tips: '请选择部门',
          options: _deptOptions,
          defaultValue: const SelectData(label: '技术部', value: 'tech', data: 'tech'),
          onSingleChanged: (value, data, full) {},
        ),
      ),
      FormConfig.dropdown<String>(
        DropdownFieldConfig<String>(
          name: 'deptMulti',
          label: '部门(多选/本地过滤)',
          multiple: true,
          filterable: true,
          tips: '可输入关键字过滤',
          options: _deptOptions,
          defaultValue: const [
            SelectData(label: '销售部', value: 'sale', data: 'sale'),
            SelectData(label: '技术部', value: 'tech', data: 'tech'),
          ],
        ),
      ),
      FormConfig.dropdown<String>(
        DropdownFieldConfig<String>(
          name: 'deptRemote',
          label: '部门(远程搜索)',
          required: true,
          remote: true,
          remoteSearch: _remoteSearch,
          tips: '支持远程搜索',
          showAdd: true,
          onAdd: (text) {
            // 示例：添加一条新选项（仅示例，本地集合未持久化）
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('新增: $text')));
          },
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('DropdownChoose 表单示例')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConfigForm(
          configs: configs,
          controller: _formController,
          onChanged: (data) => setState(() => _formData = data),
          submitBuilder: (data) {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 校验表单
                  final valid = _formController.validate();
                  if (!valid) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请完善必填项')));
                    return;
                  }
                  // 这里只是展示当前表单数据
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('当前表单数据'),
                      content: Text(data.toString()),
                      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('确定'))],
                    ),
                  );
                },
                child: const Text('提交'),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(padding: const EdgeInsets.all(12), child: Text('实时数据: $_formData')),
    );
  }
}
