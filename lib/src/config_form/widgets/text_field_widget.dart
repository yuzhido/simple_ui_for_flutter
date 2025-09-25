import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_ui/src/config_form/utils/basic_style.dart';
import 'base_field_widget.dart';
import 'package:simple_ui/src/config_form/utils/validation_utils.dart';

class TextFieldWidget extends BaseFieldWidget {
  const TextFieldWidget({super.key, required super.config, required super.controller, required super.onChanged});

  @override
  Widget buildField(BuildContext context) {
    // 根据字段名称设置不同的输入限制
    TextInputType keyboardType = TextInputType.text;
    List<TextInputFormatter>? inputFormatters;

    if (config.name.toLowerCase() == 'phone') {
      keyboardType = TextInputType.phone;
      inputFormatters = [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)];
    } else if (config.name.toLowerCase() == 'email') {
      keyboardType = TextInputType.emailAddress;
    }

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
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
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
