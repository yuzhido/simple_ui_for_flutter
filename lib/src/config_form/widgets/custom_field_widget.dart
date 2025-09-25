import 'package:flutter/material.dart';
import 'package:simple_ui/models/field_configs.dart';
import 'package:simple_ui/src/config_form/utils/validation_utils.dart';
import 'base_field_widget.dart';

class CustomFieldWidget extends BaseFieldWidget {
  const CustomFieldWidget({super.key, required super.config, required super.controller, required super.onChanged});

  @override
  Widget buildField(BuildContext context) {
    final CustomFieldConfig customCfg = config.config as CustomFieldConfig;
    return FormField<String>(
      initialValue: controller.text,
      validator: ValidationUtils.getValidator(config),
      builder: (state) {
        final child = customCfg.contentBuilder(config, controller, (val) {
          // 避免在build期间调用 setState，延后
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onChanged(val);
            state.didChange(val);
          });
        });
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            child,
            if (state.errorText != null) ...[const SizedBox(height: 4), Text(state.errorText!, style: const TextStyle(color: Colors.red, fontSize: 12))],
          ],
        );
      },
    );
  }
}
