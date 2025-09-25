import 'package:flutter/material.dart';
import 'package:simple_ui/models/field_configs.dart';
import 'package:simple_ui/models/select_data.dart';
import 'package:simple_ui/models/config_form_model.dart';
import 'package:simple_ui/src/config_form/utils/validation_utils.dart';
import 'package:simple_ui/src/config_form/utils/data_conversion_utils.dart';
import 'package:simple_ui/src/dropdown_choose/index.dart';
import 'base_field_widget.dart';

class DropdownFieldWidget<T> extends BaseFieldWidget {
  const DropdownFieldWidget({super.key, required super.config, required super.controller, required super.onChanged});

  @override
  Widget buildField(BuildContext context) {
    final dropdownConfig = config.config as DropdownFieldConfig<T>;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        // 使用统一的数据处理工具，智能处理controller文本
        String currentValue = DataConversionUtils.smartProcessControllerText(value.text, FormType.dropdown);

        // 计算当前的结构化默认值
        final structuredDefault = _getDefaultValue(dropdownConfig, currentValue);

        return FormField<String>(
          initialValue: currentValue,
          validator: ValidationUtils.getValidator(config),
          builder: (state) {
            // 手动同步状态，确保FormField的状态与controller.text一致
            if (state.value != currentValue) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                state.didChange(currentValue);
              });
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownChoose<T>(
                  key: ValueKey('dropdown_${config.name}_$currentValue'), // 使用key强制重新创建组件
                  options: dropdownConfig.options,
                  multiple: dropdownConfig.multiple,
                  filterable: dropdownConfig.filterable,
                  remote: dropdownConfig.remote,
                  remoteSearch: dropdownConfig.remoteSearch,
                  showAdd: dropdownConfig.showAdd,
                  onAdd: dropdownConfig.onAdd,
                  tips: dropdownConfig.tips == '' ? '请选择${config.label}' : dropdownConfig.tips,
                  defaultValue: structuredDefault,
                  onSingleChanged: (dynamic value, T data, selected) {
                    final valueStr = value?.toString() ?? '';
                    controller.text = valueStr;
                    onChanged(valueStr);
                    state.didChange(valueStr);
                    dropdownConfig.onSingleChanged?.call(value, data, selected);
                  },
                  onMultipleChanged: (values, datas, selectedList) {
                    final valueStr = values.map((v) => v?.toString() ?? '').where((s) => s.isNotEmpty).join(',');
                    controller.text = valueStr;
                    onChanged(valueStr);
                    state.didChange(valueStr);
                    dropdownConfig.onMultipleChanged?.call(values, datas, selectedList);
                  },
                ),
                if (state.errorText != null) ...[const SizedBox(height: 4), Text(state.errorText!, style: const TextStyle(color: Colors.red, fontSize: 12))],
              ],
            );
          },
        );
      },
    );
  }

  dynamic _getDefaultValue(DropdownFieldConfig<T> dropdownConfig, String currentValue) {
    // 如果controller有值，根据当前值计算结构化默认值
    if (currentValue.isNotEmpty) {
      if (dropdownConfig.multiple) {
        // 多选：将逗号分隔的字符串转换为SelectData列表
        final values = currentValue.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        return dropdownConfig.options.where((opt) => values.contains(opt.value.toString())).toList();
      } else {
        // 单选：找到对应的SelectData
        return dropdownConfig.options.firstWhere((opt) => opt.value.toString() == currentValue, orElse: () => dropdownConfig.options.first);
      }
    }

    // 如果controller为空，使用config.defaultValue
    if (config.defaultValue == null) return null;
    if (dropdownConfig.multiple) {
      // Ensure typed as List<SelectData<T>> to satisfy DropdownChoose's assertion
      if (config.defaultValue is List<SelectData<T>>) {
        return List<SelectData<T>>.from(config.defaultValue as List<SelectData<T>>);
      }
      if (config.defaultValue is List) {
        return (config.defaultValue as List).cast<SelectData<T>>();
      }
    } else {
      // Ensure single value is SelectData<T>
      if (config.defaultValue is SelectData<T>) {
        return config.defaultValue as SelectData<T>;
      }
    }
    return null;
  }
}
