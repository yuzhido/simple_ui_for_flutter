import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_config.dart';
import 'package:simple_ui/src/config_form/config_form_controller.dart';
import 'package:simple_ui/src/config_form/utils/basic_style.dart';
import 'package:simple_ui/src/config_form/utils/validation_utils.dart';
import 'package:simple_ui/src/config_form/widgets/index.dart';

class SelectForCheckbox extends StatefulWidget {
  final FormConfig config;
  final ConfigFormController controller;
  final Function(Map<String, dynamic>)? onChanged;

  const SelectForCheckbox({super.key, required this.config, required this.controller, required this.onChanged});
  @override
  State<SelectForCheckbox> createState() => _SelectForCheckboxState();
}

class _SelectForCheckboxState extends State<SelectForCheckbox> {
  @override
  Widget build(BuildContext context) {
    final checkboxConfig = widget.config;
    return FormField<List<String>>(
      validator: (v) {
        final fn = ValidationUtils.getValidator(checkboxConfig);
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
                  child: InputDecorator(
                    decoration: BasicStyle.inputStyle(checkboxConfig.label),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          (checkboxConfig.props as CheckboxFieldConfig?)?.options.map<Widget>((opt) {
                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              value: false,
                              title: Text(opt.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              onChanged: (bool? v) {
                                if (v == null) return;
                              },
                            );
                          }).toList() ??
                          <Widget>[],
                    ),
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
