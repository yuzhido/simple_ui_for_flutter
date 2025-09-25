import 'package:flutter/material.dart';
import 'package:simple_ui/models/select_data.dart';
import 'package:simple_ui/src/config_form/utils/basic_style.dart';
import 'package:simple_ui/src/custom_form/index.dart';

class SelectForCheckbox extends StatefulWidget {
  const SelectForCheckbox({super.key});
  @override
  State<SelectForCheckbox> createState() => _SelectForCheckboxState();
}

class _SelectForCheckboxState extends State<SelectForCheckbox> {
  final List<SelectData> options = [
    SelectData(label: '选项1', value: '1', data: null),
    SelectData(label: '选项2', value: '2', data: null),
    SelectData(label: '选项3', value: '3', data: null),
  ];
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelInfo(label: '多选', required: true),
              InputDecorator(
                decoration: BasicStyle.inputStyle(''),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: options.map((opt) {
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      value: true,
                      title: Text(opt.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      onChanged: (bool? v) {
                        if (v == null) return;
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        // 错误信息
        Positioned(bottom: 0, left: 0, child: ErrorInfo('校验失败')),
      ],
    );
  }
}
