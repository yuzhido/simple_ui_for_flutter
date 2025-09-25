import 'package:flutter/material.dart';
import 'package:simple_ui/models/select_data.dart';
import 'package:simple_ui/src/config_form/utils/basic_style.dart';
import 'package:simple_ui/src/custom_form/index.dart';

class SelectForRadio extends StatefulWidget {
  const SelectForRadio({super.key});
  @override
  State<SelectForRadio> createState() => _SelectForRadioState();
}

class _SelectForRadioState extends State<SelectForRadio> {
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
              LabelInfo(label: '单选', required: true),
              InputDecorator(
                decoration: BasicStyle.inputStyle(''),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: options.map((opt) {
                    final String valueStr = opt.value.toString();
                    return InkWell(
                      onTap: () {},
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(opt.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          ),
                          Radio<String>(
                            value: valueStr,
                            groupValue: 'groupValue',
                            onChanged: (val) {
                              if (val == null) return;
                            },
                          ),
                        ],
                      ),
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
