import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_config.dart';
import 'package:simple_ui/src/config_form/config_form_controller.dart';
import 'package:simple_ui/src/config_form/utils/validation_utils.dart';
import 'package:simple_ui/src/config_form/widgets/index.dart';

class CustomForAny extends StatefulWidget {
  final FormConfig config;
  final ConfigFormController controller;
  final Function(Map<String, dynamic>)? onChanged;

  const CustomForAny({super.key, required this.config, required this.controller, required this.onChanged});
  @override
  State<CustomForAny> createState() => _CustomForAnyState();
}

class _CustomForAnyState extends State<CustomForAny> {
  @override
  Widget build(BuildContext context) {
    final FormConfig customCfg = widget.config;
    return FormField<String>(
      initialValue: widget.controller.getValue(customCfg.name),
      validator: (value) {
        // 使用FormField的当前值而不是controller.text
        final fn = ValidationUtils.getValidator(customCfg);
        return fn?.call(value ?? widget.controller.getValue(customCfg.name));
      },
      builder: (state) {
        final child = customCfg.props.contentBuilder(customCfg, widget.controller, (val) {
          // 避免在build期间调用 setState，延后
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.controller.setFieldValue(customCfg.name, val);
            state.didChange(val);
          });
        });
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.config.label != '') LabelInfo(widget.config.label, widget.config.required),
            Stack(
              children: [
                Container(padding: EdgeInsets.only(bottom: 18), child: child),
                if (state.errorText != null) Positioned(bottom: 0, left: 0, child: ErrorInfo(state.errorText)),
              ],
            ),
          ],
        );
      },
    );
  }
}
