import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';
import 'package:simple_ui/models/field_configs.dart';

class TreeSelectDemoPage extends StatefulWidget {
  const TreeSelectDemoPage({super.key});
  @override
  State<TreeSelectDemoPage> createState() => _TreeSelectDemoPageState();
}

class _TreeSelectDemoPageState extends State<TreeSelectDemoPage> {
  final ConfigFormController _formController = ConfigFormController();
  Map<String, dynamic> _formData = {};
  List<String> _callbackLogs = [];

  // 模拟树形数据
  final List<SelectData<String>> _treeData = [
    SelectData<String>(
      label: '技术部',
      value: 'tech',
      data: 'tech',
      hasChildren: true,
      children: [
        SelectData<String>(
          label: '前端组',
          value: 'frontend',
          data: 'frontend',
          hasChildren: true,
          children: [
            SelectData<String>(label: 'React开发', value: 'react', data: 'react'),
            SelectData<String>(label: 'Vue开发', value: 'vue', data: 'vue'),
            SelectData<String>(label: 'Flutter开发', value: 'flutter', data: 'flutter'),
          ],
        ),
        SelectData<String>(
          label: '后端组',
          value: 'backend',
          data: 'backend',
          hasChildren: true,
          children: [
            SelectData<String>(label: 'Java开发', value: 'java', data: 'java'),
            SelectData<String>(label: 'Python开发', value: 'python', data: 'python'),
            SelectData<String>(label: 'Node.js开发', value: 'nodejs', data: 'nodejs'),
          ],
        ),
        SelectData<String>(
          label: '测试组',
          value: 'test',
          data: 'test',
          hasChildren: true,
          children: [
            SelectData<String>(label: '功能测试', value: 'functional', data: 'functional'),
            SelectData<String>(label: '性能测试', value: 'performance', data: 'performance'),
            SelectData<String>(label: '自动化测试', value: 'automation', data: 'automation'),
          ],
        ),
      ],
    ),
    SelectData<String>(
      label: '产品部',
      value: 'product',
      data: 'product',
      hasChildren: true,
      children: [
        SelectData<String>(label: '产品经理', value: 'pm', data: 'pm'),
        SelectData<String>(label: 'UI设计师', value: 'ui', data: 'ui'),
        SelectData<String>(label: 'UX设计师', value: 'ux', data: 'ux'),
      ],
    ),
    SelectData<String>(
      label: '运营部',
      value: 'operation',
      data: 'operation',
      hasChildren: true,
      children: [
        SelectData<String>(label: '内容运营', value: 'content', data: 'content'),
        SelectData<String>(label: '用户运营', value: 'user', data: 'user'),
        SelectData<String>(label: '活动运营', value: 'activity', data: 'activity'),
      ],
    ),
  ];

  void _addLog(String message) {
    setState(() {
      _callbackLogs.insert(0, '${DateTime.now().toString().substring(11, 19)}: $message');
      if (_callbackLogs.length > 10) {
        _callbackLogs = _callbackLogs.take(10).toList();
      }
    });
  }

  // 表单配置
  List<FormConfig> get _formConfigs => [
    // 单选树选择
    FormConfig.treeSelect(
      TreeSelectFieldConfig(
        name: 'department',
        label: '所属部门',
        required: true,
        options: _treeData,
        multiple: false,
        title: '选择部门',
        hintText: '请输入部门名称搜索',
        filterable: true,
        onSingleChanged: (value, data, selectedData) {
          print('单选回调 - 选中部门: ${selectedData.label}');
          print('多选回调 - 选中技能: $value');
          print('多选回调 - 选中技能: $data');
          print('多选回调 - 选中技能: $selectedData');
        },
      ),
    ),

    // 多选树选择
    FormConfig.treeSelect(
      TreeSelectFieldConfig(
        name: 'skills',
        label: '技能标签',
        required: false,
        options: _treeData,
        multiple: true,
        title: '选择技能',
        hintText: '请输入技能名称搜索',
        filterable: true,
        defaultValue: [
          SelectData<String>(label: 'React开发', value: 'react', data: 'react'),
          SelectData<String>(label: 'Java开发', value: 'java', data: 'java'),
        ],
        onMultipleChanged: (values, datas, selectedDataList) {
          _addLog('多选回调 - 选中技能: $values');
          _addLog('多选回调 - 选中技能: $datas');
          _addLog('多选回调 - 选中技能: $selectedDataList');
          final labels = selectedDataList.map((item) => item.label).join(', ');
          _addLog('多选回调 - 选中技能: $labels');
        },
      ),
    ),

    // 普通文本字段
    FormConfig.text(TextFieldConfig(name: 'name', label: '姓名', required: true)),

    // 普通文本字段
    FormConfig.text(TextFieldConfig(name: 'email', label: '邮箱', required: true)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TreeSelect 表单集成示例'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: Column(
        children: [
          // 主要内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 功能说明
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('功能说明：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('• 单选树选择：支持搜索过滤，选择后自动关闭'),
                        Text('• 多选树选择：支持搜索过滤，可多选，带默认值'),
                        Text('• 表单验证：支持必填验证和自定义验证器'),
                        Text('• 回调函数：实时监听选择变化'),
                        Text('• 数据获取：通过 ConfigFormController 获取表单数据'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 表单
                  ConfigForm(
                    configs: _formConfigs,
                    controller: _formController,
                    onChanged: (data) {
                      setState(() {
                        _formData = data;
                      });
                    },
                    submitBuilder: (formData) => Column(
                      children: [
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleSubmit,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                            child: const Text('提交表单'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 表单数据展示
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('当前表单数据：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(_formData.toString(), style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleReset,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                          child: const Text('重置表单'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleValidate,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          child: const Text('验证表单'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 分割线
          Container(height: 1, color: Colors.grey[300]),

          // 底部回调日志区域
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('回调日志：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _callbackLogs.clear();
                        });
                      },
                      child: const Text('清空'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _callbackLogs.isEmpty
                        ? const Center(
                            child: Text(
                              '暂无回调日志\n请操作上方的表单字段',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _callbackLogs.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  _callbackLogs[index],
                                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.black87),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (_formController.validate()) {
      final formData = _formController.getFormData();
      _addLog('表单提交成功');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('提交成功'),
          content: Text('表单数据：\n${formData.toString()}'),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('确定'))],
        ),
      );
    } else {
      _addLog('表单验证失败');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请填写必填字段'), backgroundColor: Colors.red));
    }
  }

  void _handleReset() {
    _formController.reset();
    setState(() {
      _formData = {};
    });
    _addLog('表单已重置');
  }

  void _handleValidate() {
    final isValid = _formController.validate();
    _addLog(isValid ? '表单验证通过' : '表单验证失败');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isValid ? '表单验证通过' : '表单验证失败'), backgroundColor: isValid ? Colors.green : Colors.red));
  }
}
