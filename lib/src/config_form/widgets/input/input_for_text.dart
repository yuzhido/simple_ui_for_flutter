import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_ui/src/config_form/utils/basic_style.dart';
import 'package:simple_ui/models/field_configs.dart';
import 'package:simple_ui/src/config_form/widgets/index.dart';
import '../base_field_widget.dart';
import 'package:simple_ui/src/config_form/utils/validation_utils.dart';

class InputForText extends BaseFieldWidget {
  const InputForText({super.key, required super.config, required super.controller, required super.onChanged});

  @override
  Widget buildField(BuildContext context) {
    final textConfig = config.config as TextFieldConfig;

    // 优先使用配置中指定的键盘类型和输入格式化器
    TextInputType keyboardType = textConfig.keyboardType ?? TextInputType.text;
    List<TextInputFormatter>? inputFormatters = textConfig.inputFormatters;

    return FormField<String>(
      initialValue: controller.text,
      validator: (v) {
        final fn = ValidationUtils.getValidator(config);
        return fn?.call(controller.text);
      },
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
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    decoration: BasicStyle.inputStyle(config.label ?? config.name),
                    onChanged: (val) {
                      onChanged(val);
                      state.didChange(val);
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
