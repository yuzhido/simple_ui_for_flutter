import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_type.dart';
import 'package:simple_ui/src/custom_form/models/custom_form_config.dart';
export 'package:simple_ui/src/custom_form/models/custom_form_config.dart';
import 'package:simple_ui/src/custom_form/widgets/index.dart';

class CustomForm extends StatefulWidget {
  final List<FormFiledConfig> configList;
  const CustomForm({super.key, this.configList = const []});
  @override
  State<CustomForm> createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  // 表单配置列表
  List<FormFiledConfig> configList = [];
  @override
  void initState() {
    super.initState();
    configList = List.from(widget.configList);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: configList.map((item) {
        if (item.type == FormType.text) return InputForText();
        if (item.type == FormType.number) return InputForNumber();
        if (item.type == FormType.integer) return InputForInteger();
        if (item.type == FormType.textarea) return InputForTextarea();
        if (item.type == FormType.radio) return SelectForRadio();
        if (item.type == FormType.checkbox) return SelectForCheckbox();
        if (item.type == FormType.select) return SelectForSingle();
        if (item.type == FormType.dropdown) return SelectForDropdown();
        if (item.type == FormType.date) return DateForDate();
        if (item.type == FormType.time) return DateForTime();
        if (item.type == FormType.datetime) return DateForDateTime();
        if (item.type == FormType.upload) return FileForUpload();
        if (item.type == FormType.treeSelect) return SelectForTree();
        if (item.type == FormType.custom) return InputForInteger();
        return InputForInteger();
      }).toList(),
    );
  }
}
