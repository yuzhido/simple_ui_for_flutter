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
        FormFieldConfig.custom(
          name: 'extra',
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
