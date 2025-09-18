import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';
import 'package:intl/intl.dart';

/// 日期字段组件
class DateFieldWidget extends StatelessWidget {
  final FormBuilderConfig config;
  final dynamic value;
  final Function(dynamic) onChanged;

  const DateFieldWidget({super.key, required this.config, this.value, required this.onChanged});

  /// 格式化日期
  String _formatDate(DateTime date) {
    if (config.valueFormat != null && config.valueFormat!.isNotEmpty) {
      try {
        return DateFormat(config.valueFormat!).format(date);
      } catch (e) {
        // 如果格式化失败，使用默认格式
        return '${date.year}年${date.month}月${date.day}日';
      }
    }
    return '${date.year}年${date.month}月${date.day}日';
  }

  @override
  Widget build(BuildContext context) {
    return _buildDateTapContainer(
      placeholder: value?.toString() ?? '请选择日期',
      hasValue: value != null,
      icon: Icons.calendar_today,
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(context: context, initialDate: now, firstDate: DateTime(1900), lastDate: DateTime(2100), locale: const Locale('zh', 'CN'));
        if (picked != null) {
          final dateValue = _formatDate(picked);
          onChanged(dateValue);
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
