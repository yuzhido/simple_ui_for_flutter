import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_config.dart';
import 'package:simple_ui/src/config_form/config_form_controller.dart';
import 'package:simple_ui/src/config_form/utils/basic_style.dart';
import 'package:simple_ui/src/config_form/utils/validation_utils.dart';
import 'package:simple_ui/src/config_form/widgets/index.dart';

class DateTimeForDate extends StatefulWidget {
  final FormConfig config;
  final ConfigFormController controller;
  final Function(Map<String, dynamic>)? onChanged;

  const DateTimeForDate({super.key, required this.config, required this.controller, required this.onChanged});
  @override
  State<DateTimeForDate> createState() => _DateTimeForDateState();
}

class _DateTimeForDateState extends State<DateTimeForDate> {
  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.controller.getValue(widget.config.name),
      validator: (v) {
        final fn = ValidationUtils.getValidator(widget.config);
        return fn?.call('controller.text');
      },
      builder: (state) {
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
                    decoration: BasicStyle.inputStyle(widget.config.label, suffixIcon: const Icon(Icons.calendar_today)),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (picked != null) {
                        final dateStr = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                        widget.controller.setFieldValue(widget.config.name, dateStr);
                        state.didChange(dateStr);
                      }
                    },
                  ),
                ),
                if (state.errorText != null) Positioned(bottom: 0, left: 0, child: ErrorInfo(state.errorText)),
              ],
            ),
          ],
        );
      },
    );
  }
}
