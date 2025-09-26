import 'package:flutter/material.dart';
import 'package:simple_ui/src/custom_form/models/custom_form_config.dart';
import 'package:simple_ui/src/custom_form/widgets/error_info.dart';
import 'package:simple_ui/src/custom_form/widgets/label_info.dart';
import 'package:simple_ui/src/widgets/choose_container.dart';

class DateForDateTime extends StatefulWidget {
  final FormFiledConfig config;
  const DateForDateTime({super.key, required this.config});
  @override
  State<DateForDateTime> createState() => _DateForDateTimeState();
}

class _DateForDateTimeState extends State<DateForDateTime> {
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
              LabelInfo(label: '时间日期选择', required: true),
              ChooseContainer(
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (pickedDate == null) return;
                  if (!context.mounted) return;
                  final TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (pickedTime == null) return;
                  two(int v) => v.toString().padLeft(2, '0');
                  final dateStr = '${pickedDate.year}-${two(pickedDate.month)}-${two(pickedDate.day)}';
                  final timeStr = '${two(pickedTime.hour)}:${two(pickedTime.minute)}';
                  final dateTimeStr = '$dateStr $timeStr';
                  print(dateTimeStr);
                },
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
