import 'package:flutter/material.dart';
import 'package:simple_ui/src/custom_form/widgets/error_info.dart';
import 'package:simple_ui/src/custom_form/widgets/label_info.dart';
import 'package:simple_ui/src/widgets/dropdown_container.dart';
import 'package:simple_ui/src/custom_form/models/custom_form_config.dart';

class SelectForMultiple extends StatefulWidget {
  final FormFiledConfig config;
  const SelectForMultiple({super.key, required this.config});
  @override
  State<SelectForMultiple> createState() => _SelectForMultipleState();
}

class _SelectForMultipleState extends State<SelectForMultiple> {
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
              LabelInfo(label: '下拉多选', required: true),
              const DropdownContainer(),
            ],
          ),
        ),
        // 错误信息
        Positioned(bottom: 0, left: 0, child: ErrorInfo('校验失败')),
      ],
    );
  }
}
