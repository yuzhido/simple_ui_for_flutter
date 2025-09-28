import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_config.dart';
import 'package:simple_ui/src/config_form/utils/basic_style.dart';
import 'package:simple_ui/src/config_form/widgets/index.dart';

class SelectForRadio extends StatefulWidget {
  final FormConfig config;
  final ConfigFormController controller;
  final void Function(Map<String, dynamic>)? onChanged;
  const SelectForRadio({super.key, required this.config, required this.controller, required this.onChanged});
  @override
  State<SelectForRadio> createState() => _SelectForRadioState();
}

class _SelectForRadioState extends State<SelectForRadio> {
  late ValueNotifier<Map<String, String>> countNotifier;
  @override
  void initState() {
    countNotifier = ValueNotifier(widget.controller.errors);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final radioConfig = widget.config;

    final config = widget.config;
    final errorsInfo = widget.controller.errors;
    return ValueListenableBuilder(
      valueListenable: countNotifier,
      builder: (context, _, __) {
        final String groupValue = widget.controller.getValue<String?>(radioConfig.name) ?? '';

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
                    decoration: BasicStyle.inputStyle(radioConfig.label),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          (radioConfig.props as RadioProps?)?.options.map<Widget>((opt) {
                            final String valueStr = opt.value.toString();
                            return InkWell(
                              onTap: () {
                                widget.controller.setFieldValue(radioConfig.name, valueStr);
                                // 调用回调函数，传递三个参数: (value, data, SelectData)
                                if (widget.onChanged != null) {
                                  // widget.onChanged!(opt.value, opt.data, opt);
                                }
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(opt.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  ),
                                  Radio<String>(
                                    value: valueStr,
                                    groupValue: groupValue,
                                    onChanged: (val) {
                                      if (val == null) return;
                                      widget.controller.setFieldValue(radioConfig.name, val);
                                      // 调用回调函数，传递三个参数: (value, data, SelectData)
                                      if (widget.onChanged != null) {
                                        // widget.onChanged!(opt.value, opt.data, opt);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList() ??
                          <Widget>[],
                    ),
                  ),
                ),
                if (errorsInfo[config.name] != null) Positioned(bottom: 0, left: 0, child: ErrorInfo(errorsInfo[config.name]!)),
              ],
            ),
          ],
        );
      },
    );
  }
}
