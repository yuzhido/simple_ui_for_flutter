import 'package:flutter/material.dart';
import 'package:simple_ui/models/field_configs.dart';
import 'package:simple_ui/src/config_form/utils/basic_style.dart';
import 'package:simple_ui/src/config_form/utils/validation_utils.dart';
import 'package:simple_ui/src/config_form/utils/data_conversion_utils.dart';
import 'package:simple_ui/models/form_type.dart';
import 'package:simple_ui/src/config_form/widgets/index.dart';
import '../base_field_widget.dart';

class SelectForRadio<T> extends BaseFieldWidget {
  const SelectForRadio({super.key, required super.config, required super.controller, required super.onChanged});

  @override
  Widget buildField(BuildContext context) {
    final radioConfig = config.config as RadioFieldConfig<T>;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        // 使用统一的数据处理工具，智能处理controller文本
        String currentValue = DataConversionUtils.smartProcessControllerText(value.text, FormType.radio);

        return FormField<String>(
          initialValue: currentValue,
          validator: (v) {
            final fn = ValidationUtils.getValidator(config);
            return fn?.call(controller.text);
          },
          builder: (state) {
            // 手动同步状态，确保FormField的状态与controller.text一致
            if (state.value != currentValue) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                state.didChange(currentValue);
              });
            }

            final String groupValue = currentValue;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 18),
                      child: InputDecorator(
                        decoration: BasicStyle.inputStyle(config.label ?? config.name),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: radioConfig.options.map((opt) {
                            final String valueStr = opt.value.toString();
                            return InkWell(
                              onTap: () {
                                controller.text = valueStr;
                                onChanged(valueStr);
                                // 调用回调函数，传递三个参数: (value, data, SelectData)
                                if (radioConfig.onChanged != null) {
                                  radioConfig.onChanged!(opt.value, opt.data, opt);
                                }
                                state.didChange(valueStr);
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
                                      controller.text = val;
                                      onChanged(val);
                                      // 调用回调函数，传递三个参数: (value, data, SelectData)
                                      if (radioConfig.onChanged != null) {
                                        radioConfig.onChanged!(opt.value, opt.data, opt);
                                      }
                                      state.didChange(val);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
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
      },
    );
  }
}
