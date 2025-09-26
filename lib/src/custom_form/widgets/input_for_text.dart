import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_ui/src/config_form/utils/basic_style.dart';
import 'package:simple_ui/src/custom_form/widgets/error_info.dart';
import 'package:simple_ui/src/custom_form/widgets/label_info.dart';

class InputForText extends StatefulWidget {
  const InputForText({super.key});
  @override
  State<InputForText> createState() => _InputForTextState();
}

class _InputForTextState extends State<InputForText> {
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
              LabelInfo(label: '普通单行输入', required: true),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
