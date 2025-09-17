import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';

/// 时间字段组件
class TimeFieldWidget extends StatelessWidget {
  final FormBuilderConfig config;
  final dynamic value;
  final Function(dynamic) onChanged;

  const TimeFieldWidget({super.key, required this.config, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _buildDateTapContainer(
      placeholder: value?.toString() ?? '请选择时间',
      hasValue: value != null,
      icon: Icons.access_time,
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
        if (picked != null) {
          final timeValue = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          onChanged(timeValue);
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
