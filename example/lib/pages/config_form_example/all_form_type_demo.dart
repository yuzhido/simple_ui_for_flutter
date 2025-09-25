import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';

class AllFormTypeDemoPage extends StatefulWidget {
  const AllFormTypeDemoPage({super.key});
  @override
  State<AllFormTypeDemoPage> createState() => _AllFormTypeDemoPageState();
}

class _AllFormTypeDemoPageState extends State<AllFormTypeDemoPage> {
  final ConfigFormController _formController = ConfigFormController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ConfigForm 全类型示例')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConfigForm(
          controller: _formController,
          configs: [
            // 文本
            FormConfig.text(const TextFieldConfig(name: 'text', label: '文本')),
            // 多行文本
            FormConfig.textarea(const TextareaFieldConfig(name: 'textarea', label: '多行文本', rows: 3)),
            // 数字
            FormConfig.number(const NumberFieldConfig(name: 'number', label: '数字', decimalPlaces: 2)),
            // 整数
            FormConfig.integer(const IntegerFieldConfig(name: 'integer', label: '整数')),
            // 日期
            FormConfig.date(const DateFieldConfig(name: 'date', label: '日期')),
            // 时间
            FormConfig.time(const TimeFieldConfig(name: 'time', label: '时间')),
            // 日期时间
            FormConfig.datetime(const DateTimeFieldConfig(name: 'datetime', label: '日期时间')),
            // 单选
            FormConfig.radio<String>(
              RadioFieldConfig<String>(
                name: 'radio',
                label: '单选',
                options: const [
                  SelectData(label: 'A', value: true, data: 'A'),
                  SelectData(label: 'B', value: 'B', data: 'B'),
                ],
              ),
            ),
            // 多选
            FormConfig.checkbox<String>(
              CheckboxFieldConfig<String>(
                name: 'checkbox',
                label: '多选',
                options: const [
                  SelectData(label: '苹果', value: 'apple', data: 'apple'),
                  SelectData(label: '香蕉', value: 'banana', data: 'banana'),
                  SelectData(label: '橙子', value: 'orange', data: 'orange'),
                ],
              ),
            ),
            // 下拉选择（简单）
            FormConfig.select<String>(
              SelectFieldConfig<String>(
                name: 'select',
                label: '下拉选择',
                options: const [
                  SelectData(label: '一', value: '1', data: '1'),
                  SelectData(label: '二', value: '2', data: '2'),
                  SelectData(label: '三', value: '3', data: '3'),
                ],
              ),
            ),
            // 自定义下拉 DropdownChoose（可多选/本地）
            FormConfig.dropdown<String>(
              DropdownFieldConfig<String>(
                name: 'dropdown',
                label: 'Dropdown 选择',
                options: const [
                  SelectData(label: '杭州', value: 'hz', data: 'hz'),
                  SelectData(label: '上海', value: 'sh', data: 'sh'),
                  SelectData(label: '北京', value: 'bj', data: 'bj'),
                ],
                multiple: true,
              ),
            ),
            // 上传（演示：不自动上传，仅选择文件）
            FormConfig.upload(const UploadFieldConfig(name: 'upload', label: '文件上传', maxFiles: 2, autoUpload: false)),
            // 树选择（简单静态树）
            FormConfig.treeSelect<String>(
              TreeSelectFieldConfig<String>(
                name: 'tree',
                label: '树选择',
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
            // 自定义
            FormConfig.custom(
              CustomFieldConfig(
                name: 'custom',
                label: '自定义',
                required: true,
                contentBuilder: (cfg, controller, onChanged) {
                  return TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '输入自定义内容'),
                    onChanged: onChanged,
                  );
                },
              ),
            ),
          ],
          submitBuilder: (formData) {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formController.validate()) {
                    final data = _formController.getFormData();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('提交成功：\n${data.toString()}')));
                  }
                },
                child: const Text('提交'),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
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
    );
  }
}
