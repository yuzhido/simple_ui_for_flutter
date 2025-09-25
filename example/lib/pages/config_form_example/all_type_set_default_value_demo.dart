import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';

class AllTypeSetDefaultValueDemoPage extends StatefulWidget {
  const AllTypeSetDefaultValueDemoPage({super.key});
  @override
  State<AllTypeSetDefaultValueDemoPage> createState() => _AllTypeSetDefaultValueDemoPageState();
}

class _AllTypeSetDefaultValueDemoPageState extends State<AllTypeSetDefaultValueDemoPage> {
  final ConfigFormController _formController = ConfigFormController();

  // 一份基准默认值
  final Map<String, dynamic> _baseDefaults = {
    'text': '默认文本',
    'textarea': '默认多行文本',
    'number': 12.34,
    'integer': 7,
    'date': '2025-01-01',
    'time': '08:30',
    'datetime': '2025-01-01 08:30',
    'radio': 'A',
    'checkbox': ['apple', 'banana'],
    'select': '2',
    'dropdown': ['hz', 'sh'],
    'tree': ['sh', 'hz'],
  };

  Map<String, dynamic> _currentDefaults = {};

  @override
  void initState() {
    super.initState();
    _currentDefaults = Map<String, dynamic>.from(_baseDefaults);
  }

  void _setDefaults() {
    // 设置一组新的默认值
    final next = {
      'text': '新默认文本',
      'textarea': '新默认多行',
      'number': 66.6,
      'integer': 18,
      'date': '2026-06-06',
      'time': '12:00',
      'datetime': '2026-06-06 12:00',
      'radio': 'B',
      'checkbox': ['orange'],
      'select': '3',
      'dropdown': ['bj'],
      'tree': ['bj'],
    };
    setState(() {
      _currentDefaults = {..._currentDefaults, ...next};
    });
    // 写入到表单
    _formController.setFieldValues(_currentDefaults);
  }

  void _clearDefaults() {
    // 清空所有字段
    _formController.clearAllFields();
  }

  void _restoreDefaults() {
    // 恢复基准默认值
    setState(() {
      _currentDefaults = Map<String, dynamic>.from(_baseDefaults);
    });
    _formController.setFieldValues(_currentDefaults);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置默认值示例')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(onPressed: _setDefaults, child: const Text('修改默认值')),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _clearDefaults, child: const Text('清除默认值')),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _restoreDefaults, child: const Text('恢复默认值')),
              ],
            ),
            const SizedBox(height: 16),
            ConfigForm(
              controller: _formController,
              initialValues: _currentDefaults,
              configs: [
                FormConfig.text(const TextFieldConfig(name: 'text', label: '文本', required: true)),
                FormConfig.textarea(const TextareaFieldConfig(name: 'textarea', label: '多行文本', rows: 3, required: true)),
                FormConfig.number(const NumberFieldConfig(name: 'number', label: '数字', decimalPlaces: 2, required: true)),
                FormConfig.integer(const IntegerFieldConfig(name: 'integer', label: '整数', required: true)),
                FormConfig.date(const DateFieldConfig(name: 'date', label: '日期', required: true)),
                FormConfig.time(const TimeFieldConfig(name: 'time', label: '时间', required: true)),
                FormConfig.datetime(const DateTimeFieldConfig(name: 'datetime', label: '日期时间', required: true)),
                FormConfig.radio<String>(
                  RadioFieldConfig<String>(
                    name: 'radio',
                    label: '单选',
                    required: true,
                    options: const [
                      SelectData(label: 'A', value: 'A', data: 'A'),
                      SelectData(label: 'B', value: 'B', data: 'B'),
                    ],
                    onChanged: (value, data, selectData) {
                      print('单选回调 - value: $value, data: $data, selectData: $selectData');
                    },
                  ),
                ),
                FormConfig.checkbox<String>(
                  CheckboxFieldConfig<String>(
                    name: 'checkbox',
                    label: '多选',
                    required: true,
                    options: const [
                      SelectData(label: '苹果', value: 'apple', data: 'apple'),
                      SelectData(label: '香蕉', value: 'banana', data: 'banana'),
                      SelectData(label: '橙子', value: 'orange', data: 'orange'),
                    ],
                    onChanged: (values, dataList, selectDataList) {
                      print('多选回调 - values: $values, dataList: $dataList, selectDataList: $selectDataList');
                    },
                  ),
                ),
                FormConfig.select<String>(
                  SelectFieldConfig<String>(
                    name: 'select',
                    label: '下拉选择',
                    required: true,
                    options: const [
                      SelectData(label: '一', value: '1', data: '1'),
                      SelectData(label: '二', value: '2', data: '2'),
                      SelectData(label: '三', value: '3', data: '3'),
                    ],
                    onSingleChanged: (value, data, selectData) {
                      print('下拉选择回调 - value: $value, data: $data, selectData: $selectData');
                    },
                  ),
                ),
                FormConfig.select<String>(
                  SelectFieldConfig<String>(
                    name: 'select',
                    label: '下拉选择',
                    required: true,
                    multiple: true,
                    options: const [
                      SelectData(label: '一', value: '1', data: '1'),
                      SelectData(label: '二', value: '2', data: '2'),
                      SelectData(label: '三', value: '3', data: '3'),
                    ],
                    onMultipleChanged: (value, data, selectData) {
                      print('下拉选择回调 - value: $value, data: $data, selectData: $selectData');
                    },
                  ),
                ),
                FormConfig.dropdown<String>(
                  DropdownFieldConfig<String>(
                    name: 'dropdown',
                    label: '选择城市',
                    required: true,
                    options: const [
                      SelectData(label: '杭州', value: 'hz', data: 'hz'),
                      SelectData(label: '上海', value: 'sh', data: 'sh'),
                      SelectData(label: '北京', value: 'bj', data: 'bj'),
                    ],
                    multiple: true,
                  ),
                ),
                FormConfig.treeSelect<String>(
                  TreeSelectFieldConfig<String>(
                    name: 'tree',
                    label: '树选择',
                    required: true,
                    options: const [
                      SelectData(
                        label: '华东',
                        value: 'east',
                        data: 'east',
                        children: [
                          SelectData(label: '上海', value: 'sh', data: 'sh'),
                          SelectData(label: '杭州', value: 'hz', data: 'hz'),
                        ],
                      ),
                      SelectData(
                        label: '华北',
                        value: 'north',
                        data: 'north',
                        children: [SelectData(label: '北京', value: 'bj', data: 'bj')],
                      ),
                    ],
                    multiple: true,
                    checkable: true,
                  ),
                ),
              ],
              submitBuilder: (formData) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'submitDefaults',
            onPressed: () {
              if (_formController.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('校验通过，已提交')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请检查填写项')));
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('提交'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'viewDefaults',
            onPressed: () {
              final data = _formController.getFormData() ?? {};
              showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: const Text('当前表单数据'),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [...data.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('${e.key}: ${e.value} : ${e.value.runtimeType}')))],
                      ),
                    ),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭'))],
                  );
                },
              );
            },
            icon: const Icon(Icons.visibility),
            label: const Text('查看数据'),
          ),
        ],
      ),
    );
  }
}
