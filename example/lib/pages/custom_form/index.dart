import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_type.dart';
import 'package:simple_ui/simple_ui.dart';

class CustomFormPage extends StatefulWidget {
  const CustomFormPage({super.key});
  @override
  State<CustomFormPage> createState() => _CustomFormPageState();
}

class _CustomFormPageState extends State<CustomFormPage> {
  // 创建表单配置列表
  List<FormFiledConfig> get formConfigs => [
    // 文本输入
    FormFiledConfig(label: '用户名', prop: 'username', type: FormType.text, required: true, value: ''),

    // 数字输入
    FormFiledConfig(label: '年龄', prop: 'age', type: FormType.number, required: true, value: 0),

    // 整数输入
    FormFiledConfig(label: '身高(cm)', prop: 'height', type: FormType.integer, required: false, value: 170),

    // 多行文本
    FormFiledConfig(label: '个人简介', prop: 'description', type: FormType.textarea, required: false, value: ''),

    // 单选
    FormFiledConfig(label: '性别', prop: 'gender', type: FormType.radio, required: true, value: 'male'),

    // 多选
    FormFiledConfig(label: '兴趣爱好', prop: 'hobbies', type: FormType.checkbox, required: false, value: []),

    // 下拉选择
    FormFiledConfig(label: '学历', prop: 'education', type: FormType.select, required: true, value: ''),

    // 自定义下拉
    FormFiledConfig(label: '职业', prop: 'profession', type: FormType.dropdown, required: false, value: ''),

    // 日期
    FormFiledConfig(label: '出生日期', prop: 'birthday', type: FormType.date, required: true, value: null),

    // 时间
    FormFiledConfig(label: '工作时间', prop: 'workTime', type: FormType.time, required: false, value: null),

    // 日期时间
    FormFiledConfig(label: '注册时间', prop: 'registerTime', type: FormType.datetime, required: false, value: null),

    // 文件上传
    FormFiledConfig(label: '头像上传', prop: 'avatar', type: FormType.upload, required: false, value: null),

    // 树选择
    FormFiledConfig(label: '所在地区', prop: 'region', type: FormType.treeSelect, required: false, value: ''),

    // 自定义字段
    FormFiledConfig(label: '自定义字段', prop: 'custom', type: FormType.custom, required: false, value: ''),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CustomForm 使用示例'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题说明
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CustomForm 组件示例',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                  ),
                  const SizedBox(height: 8),
                  Text('这个示例展示了 CustomForm 组件支持的所有表单字段类型，包括文本、数字、日期、选择等各种输入控件。', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                ],
              ),
            ),

            // CustomForm 组件
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '表单字段',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                    ),
                    const SizedBox(height: 16),
                    CustomForm(configList: formConfigs),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 配置信息展示
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '配置信息',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                    ),
                    const SizedBox(height: 12),
                    Text('表单包含 ${formConfigs.length} 个字段，涵盖了所有支持的表单类型：', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    const SizedBox(height: 8),
                    ...formConfigs
                        .map(
                          (config) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(color: config.required ? Colors.red : Colors.green, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text('${config.label} (${config.type.name})', style: const TextStyle(fontSize: 12))),
                                if (config.required)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(4)),
                                    child: Text('必填', style: TextStyle(fontSize: 10, color: Colors.red.shade700)),
                                  ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
