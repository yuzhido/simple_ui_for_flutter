import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_ui/src/config_form/utils/basic_style.dart';
import 'package:simple_ui/src/custom_form/widgets/error_info.dart';
import 'package:simple_ui/src/custom_form/widgets/label_info.dart';
import 'package:simple_ui/src/custom_form/models/custom_form_config.dart';

class InputForNumber extends StatefulWidget {
  final FormFiledConfig config;
  const InputForNumber({super.key, required this.config});
  @override
  State<InputForNumber> createState() => _InputForNumberState();
}

class _InputForNumberState extends State<InputForNumber> {
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
              LabelInfo(label: '数字输入', required: true),
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                decoration: BasicStyle.inputStyle('请输入'),
                onChanged: (val) {},
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
