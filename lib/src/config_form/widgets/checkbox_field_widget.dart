import 'package:flutter/material.dart';
import 'package:simple_ui/models/field_configs.dart';
import 'package:simple_ui/models/select_data.dart';
import 'package:simple_ui/src/config_form/utils/basic_style.dart';
import 'package:simple_ui/src/config_form/utils/validation_utils.dart';
import 'package:simple_ui/src/config_form/utils/data_conversion_utils.dart';
import 'package:simple_ui/models/form_type.dart';
import 'base_field_widget.dart';

class CheckboxFieldWidget<T> extends BaseFieldWidget {
  const CheckboxFieldWidget({super.key, required super.config, required super.controller, required super.onChanged});

  @override
  Widget buildField(BuildContext context) {
    final checkboxConfig = config.config as CheckboxFieldConfig<T>;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        // 使用统一的数据处理工具，智能处理controller文本
        String currentValue = DataConversionUtils.smartProcessControllerText(value.text, FormType.checkbox);

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

            final Set<String> selected = {...((currentValue.isNotEmpty) ? currentValue.split(',').map((e) => e.trim()) : <String>[])};

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputDecorator(
                  decoration: BasicStyle.inputStyle(config.label ?? config.name),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: checkboxConfig.options.map((opt) {
                      final isChecked = selected.contains(opt.value.toString());
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        value: isChecked,
                        title: Text(opt.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        onChanged: (bool? v) {
                          if (v == null) return;
                          if (v) {
                            selected.add(opt.value.toString());
                          } else {
                            selected.remove(opt.value.toString());
                          }
                          final valueStr = selected.join(',');
                          controller.text = valueStr;
                          onChanged(valueStr);

                          // 更新选中的数据列表
                          final List<SelectData<T>> updatedSelectedData = checkboxConfig.options.where((option) => selected.contains(option.value.toString())).toList();

                          // 调用回调函数，传递三个参数: (List<value>, List<data>, List<SelectData>)
                          if (checkboxConfig.onChanged != null) {
                            checkboxConfig.onChanged!(updatedSelectedData.map((e) => e.value).toList(), updatedSelectedData.map((e) => e.data).toList(), updatedSelectedData);
                          }

                          state.didChange(valueStr);
                        },
                      );
                    }).toList(),
                  ),
                ),
                if (state.errorText != null) ...[const SizedBox(height: 4), Text(state.errorText!, style: const TextStyle(color: Colors.red, fontSize: 12))],
              ],
            );
          },
        );
      },
    );
  }
}
