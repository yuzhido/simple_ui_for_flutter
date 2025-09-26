import 'package:flutter/material.dart';
import 'package:simple_ui/src/custom_form/widgets/error_info.dart';
import 'package:simple_ui/src/custom_form/widgets/label_info.dart';
import 'package:simple_ui/src/widgets/dropdown_container.dart';

class SelectForDropdown extends StatefulWidget {
  const SelectForDropdown({super.key});
  @override
  State<SelectForDropdown> createState() => _SelectForDropdownState();
}

class _SelectForDropdownState extends State<SelectForDropdown> {
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
              LabelInfo(label: '自定义下拉单选多选', required: true),
              const DropdownContainer(),
            ],
          ),
        ),
        // 错误信息
        if (true == false) Positioned(bottom: 0, left: 0, child: ErrorInfo('校验失败')),
      ],
    );
  }
}
