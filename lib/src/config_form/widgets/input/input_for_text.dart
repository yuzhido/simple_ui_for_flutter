import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_ui/models/form_config.dart';
import 'package:simple_ui/src/config_form/config_form_controller.dart';
import 'package:simple_ui/src/config_form/utils/basic_style.dart';
import 'package:simple_ui/src/config_form/utils/validation_utils.dart';
import 'package:simple_ui/src/config_form/widgets/index.dart';

class InputForText extends StatefulWidget {
  final FormConfig config;
  final ConfigFormController controller;
  final Function(Map<String, dynamic>)? onChanged;

  const InputForText({super.key, required this.config, required this.controller, required this.onChanged});

  @override
  State<InputForText> createState() => _InputForTextState();
}

class _InputForTextState extends State<InputForText> {
  @override
  Widget build(BuildContext context) {
    final textConfig = widget.config;

    // 优先使用配置中指定的键盘类型和输入格式化器
    TextInputType keyboardType = textConfig.props.keyboardType ?? TextInputType.text;
    List<TextInputFormatter>? inputFormatters = textConfig.props.inputFormatters;

    return FormField<String>(
      initialValue: widget.controller.getValue(widget.config.name) ?? '',
      validator: (v) {
        final fn = ValidationUtils.getValidator(widget.config);
        return fn?.call(v ?? '');
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
                    initialValue: widget.controller.getValue(widget.config.name) ?? '',
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    decoration: BasicStyle.inputStyle(widget.config.label),
                    onChanged: (val) {
                      widget.controller.setFieldValue(widget.config.name, val);
                      state.didChange(val);
                      widget.onChanged?.call(widget.controller.getFormData());
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
