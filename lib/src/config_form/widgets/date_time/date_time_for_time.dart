import 'package:flutter/material.dart';
import 'package:simple_ui/src/config_form/utils/basic_style.dart';
import 'package:simple_ui/src/config_form/utils/validation_utils.dart';
import 'package:simple_ui/src/config_form/widgets/index.dart';
import '../base_field_widget.dart';

class DateTimeForTime extends BaseFieldWidget {
  const DateTimeForTime({super.key, required super.config, required super.controller, required super.onChanged});

  @override
  Widget buildField(BuildContext context) {
    return FormField<String>(
      initialValue: controller.text,
      validator: ValidationUtils.getValidator(config),
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 18),
                  child: TextFormField(
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
