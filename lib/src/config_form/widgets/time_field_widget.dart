import 'package:flutter/material.dart';
import 'package:simple_ui/src/config_form/utils/basic_style.dart';
import 'package:simple_ui/src/config_form/utils/validation_utils.dart';
import 'base_field_widget.dart';

class TimeFieldWidget extends BaseFieldWidget {
  const TimeFieldWidget({super.key, required super.config, required super.controller, required super.onChanged});

  @override
  Widget buildField(BuildContext context) {
    return FormField<String>(
      initialValue: controller.text,
      validator: ValidationUtils.getValidator(config),
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: controller,
              readOnly: true,
              decoration: BasicStyle.inputStyle(config.label ?? config.name, suffixIcon: const Icon(Icons.access_time)),
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (picked != null) {
                  two(int v) => v.toString().padLeft(2, '0');
                  final timeStr = '${two(picked.hour)}:${two(picked.minute)}';
                  controller.text = timeStr;
                  onChanged(timeStr);
                  state.didChange(timeStr);
                }
              },
            ),
            if (state.errorText != null) ...[const SizedBox(height: 4), Text(state.errorText!, style: const TextStyle(color: Colors.red, fontSize: 12))],
          ],
        );
      },
    );
  }
}
