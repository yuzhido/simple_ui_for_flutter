import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';

/// 日期时间字段组件
class DateTimeFieldWidget extends StatefulWidget {
  final FormBuilderConfig config;
  final dynamic value;
  final Function(dynamic) onChanged;

  const DateTimeFieldWidget({super.key, required this.config, this.value, required this.onChanged});

  @override
  State<DateTimeFieldWidget> createState() => _DateTimeFieldWidgetState();
}

class _DateTimeFieldWidgetState extends State<DateTimeFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return _buildDateTapContainer(
      placeholder: widget.value?.toString() ?? '请选择日期时间',
      hasValue: widget.value != null,
      icon: Icons.event,
      onTap: () async {
        final now = DateTime.now();
        final pickedDate = await showDatePicker(context: context, initialDate: now, firstDate: DateTime(1900), lastDate: DateTime(2100), locale: const Locale('zh', 'CN'));

        if (pickedDate != null && mounted) {
          final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());

          if (pickedTime != null && mounted) {
            final dateTimeValue =
                '${pickedDate.year}年${pickedDate.month}月${pickedDate.day}日 ${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
            widget.onChanged(dateTimeValue);
          }
        }
      },
    );
  }

  Widget _buildDateTapContainer({required String placeholder, required bool hasValue, required IconData icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(placeholder, style: TextStyle(fontSize: 16, color: hasValue ? Colors.black87 : Colors.grey.shade500)),
            ),
            Icon(icon, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
