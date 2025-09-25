import 'package:flutter/material.dart';
import 'package:simple_ui/src/config_form/utils/basic_style.dart';
import 'package:simple_ui/src/config_form/utils/validation_utils.dart';
import 'base_field_widget.dart';

class DateTimeFieldWidget extends BaseFieldWidget {
  const DateTimeFieldWidget({super.key, required super.config, required super.controller, required super.onChanged});

  @override
  Widget buildField(BuildContext context) {
    return FormField<String>(
      initialValue: controller.text,
      validator: (v) {
        final fn = ValidationUtils.getValidator(config);
        return fn?.call(controller.text);
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: controller,
              readOnly: true,
              decoration: BasicStyle.inputStyle(config.label ?? config.name, suffixIcon: const Icon(Icons.event)),
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
                controller.text = dateTimeStr;
                onChanged(dateTimeStr);
                state.didChange(dateTimeStr);
              },
            ),
            if (state.errorText != null) ...[const SizedBox(height: 4), Text(state.errorText!, style: const TextStyle(color: Colors.red, fontSize: 12))],
          ],
        );
      },
    );
  }
}
