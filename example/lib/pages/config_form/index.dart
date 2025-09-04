import 'package:example/pages/config_form/choose_asset.dart';
import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';

class ConfigFormPage extends StatefulWidget {
  const ConfigFormPage({super.key});
  @override
  State<ConfigFormPage> createState() => _ConfigFormPageState();
}

class _ConfigFormPageState extends State<ConfigFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ConfigFormController _formController = ConfigFormController();
  @override
  Widget build(BuildContext context) {
    final cfg = FormConfig(
      fields: [
        FormFieldConfig.text(name: 'title', label: '标题', placeholder: '请输入标题', required: true),
        FormFieldConfig.number(name: 'price', label: '价格', placeholder: '如 9.99', props: const NumberFieldProps(min: 0)),
        FormFieldConfig.integer(name: 'count', label: '数量', placeholder: '仅整数', props: const IntegerFieldProps(min: 0)),
        FormFieldConfig.textarea(name: 'desc', label: '描述', placeholder: '请输入描述', props: const TextareaFieldProps(maxLines: 4)),
        FormFieldConfig.select(
          name: 'cate',
          label: '分类',
          props: SelectFieldProps(
            options: const [
              SelectData(label: '数码', value: 'digital', data: 'digital'),
              SelectData(label: '服饰', value: 'clothes', data: 'clothes'),
              SelectData(label: '食品', value: 'food', data: 'food'),
            ],
          ),
        ),
        FormFieldConfig.checkbox(
          name: 'tags',
          label: '标签',
          props: CheckboxFieldProps(
            options: const [
              SelectData(label: '新品', value: 'new', data: 'new'),
              SelectData(label: '热卖', value: 'hot', data: 'hot'),
              SelectData(label: '推荐', value: 'recommend', data: 'recommend'),
            ],
          ),
        ),
        FormFieldConfig.radio(
          name: 'sex',
          label: '性别',
          props: RadioFieldProps(
            options: const [
              SelectData(label: '男', value: 'male', data: 'male'),
              SelectData(label: '女', value: 'female', data: 'female'),
            ],
          ),
        ),
        // 让原组件的表单项都至少展示一次：dropdown/date/time/datetime/upload
        // 自定义下拉：演示远程搜索
        FormFieldConfig.dropdown(
          name: 'customDrop',
          label: '选择水果(远程)',
          props: DropdownFieldProps(
            remote: true,
            singleTitleText: '远程搜索水果',
            placeholderText: '请输入关键字搜索水果',
            options: const [],
            onSingleSelected: (val) {
              print(val.label);
            },
            remoteFetch: (String keyword) async {
              await Future.delayed(const Duration(milliseconds: 400));
              final all = <SelectData<String>>[
                const SelectData(label: '苹果', value: 'apple', data: 'fruit'),
                const SelectData(label: '香蕉', value: 'banana', data: 'fruit'),
                const SelectData(label: '橙子', value: 'orange', data: 'fruit'),
                const SelectData(label: '葡萄', value: 'grape', data: 'fruit'),
                const SelectData(label: '西瓜', value: 'watermelon', data: 'fruit'),
                const SelectData(label: '樱桃', value: 'cherry', data: 'fruit'),
                const SelectData(label: '菠萝', value: 'pineapple', data: 'fruit'),
                const SelectData(label: '草莓', value: 'strawberry', data: 'fruit'),
                const SelectData(label: '芒果', value: 'mango', data: 'fruit'),
                const SelectData(label: '蓝莓', value: 'blueberry', data: 'fruit'),
              ];
              final kw = keyword.trim().toLowerCase();
              if (kw.isEmpty) {
                return all.take(6).toList();
              }
              return all
                  .where((e) => e.label.toLowerCase().contains(kw) || (e.value?.toLowerCase().contains(kw) ?? false))
                  .map((e) => SelectData<dynamic>(label: e.label, value: e.value, data: e.data))
                  .toList();
            },
          ),
        ),
        FormFieldConfig.date(name: 'bookDate', label: '日期'),
        FormFieldConfig.time(name: 'bookTime', label: '时间'),
        FormFieldConfig.datetime(name: 'bookDateTime', label: '日期时间'),
        FormFieldConfig.upload(
          name: 'attachment',
          label: '附件上传',
          props: const UploadFieldProps(uploadText: '上传文件', autoUpload: false),
        ),
        FormFieldConfig.custom(
          name: 'extra',
          label: '自定义区域',
          props: CustomFieldProps(
            contentBuilder: (context, value, onChanged) {
              return const ChooseAsset();
            },
          ),
        ),
        // 带校验的自定义字段示例
        FormFieldConfig.custom(
          name: 'customInput',
          label: '自定义输入(必填)',
          required: true,
          props: CustomFieldProps(
            contentBuilder: (context, value, onChanged) {
              return TextFormField(
                initialValue: value?.toString() ?? '',
                decoration: const InputDecoration(hintText: '请输入自定义内容', border: OutlineInputBorder()),
                onChanged: onChanged,
              );
            },
            validator: (value) {
              if (value == null || value.toString().trim().isEmpty) {
                return '自定义字段不能为空';
              }
              if (value.toString().length < 3) {
                return '自定义字段至少需要3个字符';
              }
              return null;
            },
          ),
        ),
        // 带复杂校验的自定义字段示例
        FormFieldConfig.custom(
          name: 'email',
          label: '邮箱地址(自定义校验)',
          required: true,
          props: CustomFieldProps(
            contentBuilder: (context, value, onChanged) {
              return TextFormField(
                initialValue: value?.toString() ?? '',
                decoration: const InputDecoration(hintText: '请输入邮箱地址', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
                onChanged: onChanged,
              );
            },
            validator: (value) {
              if (value == null || value.toString().trim().isEmpty) {
                return '邮箱地址不能为空';
              }
              final email = value.toString().trim();
              final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
              if (!emailRegex.hasMatch(email)) {
                return '请输入有效的邮箱地址';
              }
              return null;
            },
          ),
        ),
        // 模拟选择组件的自定义字段示例
        FormFieldConfig.custom(
          name: 'selectedItems',
          label: '选择项目(模拟)',
          required: true,
          props: CustomFieldProps(
            contentBuilder: (context, value, onChanged) {
              final selectedItems = (value as List<Map<String, dynamic>>?) ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedItems.isEmpty ? '请选择项目' : '已选择 ${selectedItems.length} 个项目',
                            style: TextStyle(color: selectedItems.isEmpty ? Colors.grey : Colors.black),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                  if (selectedItems.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: selectedItems
                          .map(
                            (item) => Chip(
                              label: Text(item['name'] ?? ''),
                              onDeleted: () {
                                final newItems = List<Map<String, dynamic>>.from(selectedItems);
                                newItems.removeWhere((e) => e['id'] == item['id']);
                                onChanged(newItems);
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      // 模拟选择对话框
                      final result = await showDialog<List<Map<String, dynamic>>>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('选择项目'),
                          content: SizedBox(
                            width: 300,
                            height: 200,
                            child: ListView(
                              children: [
                                ListTile(
                                  title: const Text('项目A'),
                                  onTap: () => Navigator.pop(context, [
                                    {'id': '1', 'name': '项目A', 'type': 'type1'},
                                  ]),
                                ),
                                ListTile(
                                  title: const Text('项目B'),
                                  onTap: () => Navigator.pop(context, [
                                    {'id': '2', 'name': '项目B', 'type': 'type2'},
                                  ]),
                                ),
                                ListTile(
                                  title: const Text('项目C'),
                                  onTap: () => Navigator.pop(context, [
                                    {'id': '3', 'name': '项目C', 'type': 'type3'},
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );

                      if (result != null) {
                        // 关键：调用 onChanged 更新表单字段值
                        onChanged(result);
                        print('选中的项目: $result');
                      }
                    },
                    child: const Text('选择项目'),
                  ),
                ],
              );
            },
            validator: (value) {
              if (value == null || (value is List && value.isEmpty)) {
                return '请至少选择一个项目';
              }
              return null;
            },
          ),
        ),
        // 演示外部设置值的自定义字段
        FormFieldConfig.custom(
          name: 'externalSetField',
          label: '外部设置字段',
          required: true,
          props: CustomFieldProps(
            contentBuilder: (context, value, onChanged) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('当前值: ${value?.toString() ?? 'null'}'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // 模拟外部设置值
                      final newValue = '外部设置的值 ${DateTime.now().millisecondsSinceEpoch}';
                      onChanged(newValue);
                      print('外部设置值: $newValue');
                    },
                    child: const Text('外部设置值'),
                  ),
                ],
              );
            },
            validator: (value) {
              print('外部设置字段校验器接收到的值: $value');
              if (value == null || value.toString().isEmpty) {
                return '外部设置字段不能为空';
              }
              return null;
            },
          ),
        ),
        FormFieldConfig.custom(
          name: 'action_buttons',
          isSaveInfo: false, // 不保存信息，仅用于展示按钮
          props: CustomFieldProps(
            contentBuilder: (context, value, onChanged) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _formKey.currentState?.reset();
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                    child: Text('重置'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final ok = _formKey.currentState?.validate() ?? false;
                      if (!ok) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请完成必填项'), duration: Duration(milliseconds: 1200)));
                      } else {
                        debugPrint('表单值: ${_formController.values}');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('校验通过: ${_formController.values}'), duration: const Duration(milliseconds: 1500)));
                      }
                    },
                    child: Text('确定'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      // 演示通过控制器设置值
                      _formController.setValue('title', '通过控制器设置的标题');
                      _formController.setValue('price', '99.99');
                      _formController.setValue('count', '10');
                      _formController.setValue('desc', '这是通过控制器设置的描述内容');
                      _formController.setValue('cate', 'digital');
                      _formController.setValue('tags', ['new', 'hot']);
                      _formController.setValue('sex', 'male');
                      _formController.setValue('customInput', '控制器设置的自定义内容');
                      _formController.setValue('email', 'test@example.com');
                      _formController.setValue('selectedItems', [
                        {'id': '1', 'name': '项目A', 'type': 'type1'},
                        {'id': '2', 'name': '项目B', 'type': 'type2'},
                      ]);
                      _formController.setValue('externalSetField', '通过控制器设置的外部字段值');

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已通过控制器设置表单值'), duration: Duration(milliseconds: 1000)));
                    },
                    child: Text('设置值'),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(title: const Text('表单配置')),
      body: SingleChildScrollView(
        child: Column(
          children: [ConfigForm(formConfig: cfg, formKey: _formKey, controller: _formController)],
        ),
      ),
    );
  }

  SelectData<String>? singleSelected;
  // 我整理的开始
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
}
