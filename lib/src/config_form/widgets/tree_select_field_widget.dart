import 'package:flutter/material.dart';
import 'package:simple_ui/models/select_data.dart';
import 'package:simple_ui/models/field_configs.dart';
import 'package:simple_ui/models/form_type.dart';
import 'package:simple_ui/src/tree_select/index.dart';
import 'package:simple_ui/src/config_form/utils/validation_utils.dart';
import 'package:simple_ui/src/config_form/utils/data_conversion_utils.dart';
import 'base_field_widget.dart';

class TreeSelectFieldWidget<T> extends BaseFieldWidget {
  const TreeSelectFieldWidget({super.key, required super.config, required super.controller, required super.onChanged});

  @override
  Widget buildField(BuildContext context) {
    final treeConfig = config.config as TreeSelectFieldConfig<T>;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        // 使用统一的数据处理工具，智能处理controller文本
        String currentValue = DataConversionUtils.smartProcessControllerText(value.text, FormType.treeSelect);

        // 计算当前的结构化默认值
        final structuredDefault = _getDefaultValue(currentValue, treeConfig.multiple == true);

        return FormField<String>(
          validator: (v) {
            final fn = ValidationUtils.getValidator(config);
            return fn?.call(controller.text);
          },
          initialValue: currentValue,
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
                TreeSelect<T>(
                  key: ValueKey('treeSelect_${config.name}_$currentValue'), // 使用key强制重新创建组件
                  defaultValue: structuredDefault,
                  options: treeConfig.options,
                  multiple: treeConfig.multiple,
                  title: treeConfig.title,
                  hintText: treeConfig.hintText,
                  remoteFetch: treeConfig.remoteFetch,
                  remote: treeConfig.remote,
                  filterable: treeConfig.filterable,
                  lazyLoad: treeConfig.lazyLoad,
                  lazyLoadFetch: treeConfig.lazyLoadFetch,
                  isCacheData: treeConfig.isCacheData,
                  onSingleChanged: (dynamic value, T data, SelectData<T> selectedData) {
                    final valueStr = value?.toString() ?? '';
                    controller.text = valueStr;
                    onChanged(valueStr);
                    state.didChange(valueStr);
                    treeConfig.onSingleChanged?.call(value, data, selectedData);
                  },
                  onMultipleChanged: (List<dynamic> values, List<T> datas, List<SelectData<T>> selectedDataList) {
                    final valueStr = values.map((v) => v?.toString() ?? '').where((s) => s.isNotEmpty).join(',');
                    controller.text = valueStr;
                    onChanged(valueStr);
                    state.didChange(valueStr);
                    treeConfig.onMultipleChanged?.call(values, datas, selectedDataList);
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

  /// 获取默认值（给 TreeSelect 使用）
  List<SelectData<T>>? _getDefaultValue(String currentValue, bool multiple) {
    // 如果controller有值，根据当前值计算结构化默认值
    if (currentValue.isNotEmpty) {
      final treeConfig = config.config as TreeSelectFieldConfig<T>;
      final values = currentValue.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      // 递归查找匹配的SelectData
      List<SelectData<T>> findMatchingOptions(List<SelectData<T>> options) {
        List<SelectData<T>> result = [];
        for (final option in options) {
          if (values.contains(option.value.toString())) {
            result.add(option);
          }
          if (option.children != null && option.children!.isNotEmpty) {
            result.addAll(findMatchingOptions(option.children!));
          }
        }
        return result;
      }

      return findMatchingOptions(treeConfig.options);
    }

    // 如果controller为空，使用config.defaultValue
    if (config.defaultValue == null) return null;

    if (multiple) {
      // 多选模式：defaultValue应该是List<SelectData<T>>
      if (config.defaultValue is List) {
        return List<SelectData<T>>.from(config.defaultValue);
      }
    } else {
      // 单选模式：defaultValue应该是SelectData<T>
      if (config.defaultValue is SelectData<T>) {
        return [config.defaultValue as SelectData<T>];
      }
    }

    return null;
  }
}
