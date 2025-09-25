import 'package:flutter/material.dart';
import 'package:simple_ui/src/config_form/utils/basic_style.dart';
import 'package:simple_ui/src/config_form/utils/validation_utils.dart';
import 'base_field_widget.dart';

class TextareaFieldWidget extends BaseFieldWidget {
  const TextareaFieldWidget({super.key, required super.config, required super.controller, required super.onChanged});

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
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              decoration: BasicStyle.inputStyle(config.label ?? config.name),
              onChanged: (val) {
                onChanged(val);
                state.didChange(val);
              },
            ),
            if (state.errorText != null) ...[const SizedBox(height: 4), Text(state.errorText!, style: const TextStyle(color: Colors.red, fontSize: 12))],
          ],
        );
      },
    );
  }
}
