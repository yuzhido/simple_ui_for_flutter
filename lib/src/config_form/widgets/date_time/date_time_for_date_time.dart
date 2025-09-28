import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_config.dart';
import 'package:simple_ui/src/config_form/utils/basic_style.dart';
import 'package:simple_ui/src/config_form/widgets/index.dart';

class DateTimeForDateTime extends StatefulWidget {
  final FormConfig config;
  final ConfigFormController controller;
  final Function(Map<String, dynamic>)? onChanged;

  const DateTimeForDateTime({super.key, required this.config, required this.controller, required this.onChanged});
  @override
  State<DateTimeForDateTime> createState() => _DateTimeForDateTimeState();
}

class _DateTimeForDateTimeState extends State<DateTimeForDateTime> {
  late ValueNotifier<Map<String, String>> countNotifier;
  @override
  void initState() {
    countNotifier = ValueNotifier(widget.controller.errors);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final errorsInfo = widget.controller.errors;
    return ValueListenableBuilder(
      valueListenable: countNotifier,
      builder: (context, _, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            LabelInfo(widget.config.label, widget.config.required),
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 18),
                  child: TextFormField(
                    readOnly: true,
                    decoration: BasicStyle.inputStyle(widget.config.label, suffixIcon: const Icon(Icons.event)),
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
                      widget.controller.setFieldValue(widget.config.name, dateTimeStr);
                    },
                  ),
                ),
                if (errorsInfo[config.name] != null) Positioned(bottom: 0, left: 0, child: ErrorInfo(errorsInfo[config.name]!)),
              ],
            ),
          ],
        );
      },
    );
  }
}
