import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';
import 'package:simple_ui/models/select_data.dart';
import 'package:simple_ui/src/tree_select/index.dart';

/// 树形选择字段组件
class TreeSelectFieldWidget extends StatelessWidget {
  final FormBuilderConfig config;
  final dynamic value;
  final Function(dynamic) onChanged;

  const TreeSelectFieldWidget({super.key, required this.config, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // 获取TreeSelectProps配置
    final dynamic propsRaw = config.props;
    if (propsRaw == null || propsRaw is! TreeSelectProps) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Text('配置错误')),
      );
    }

    final TreeSelectProps<dynamic> props = propsRaw;

    // 处理默认值
    dynamic defaultValue;
    if (config.defaultValue != null) {
      if (props.multiple) {
        // 多选模式：defaultValue应该是List<SelectData>
        if (config.defaultValue is List) {
          defaultValue = (config.defaultValue as List).map((item) {
            if (item is SelectData) {
              return item;
            } else if (item is SelectOption) {
              return SelectData(label: item.label, value: item.value, data: null);
            } else {
              // 如果是原始值，需要在options中查找对应的SelectData
              return _findSelectDataByValue(props.options, item);
            }
          }).where((item) => item != null).cast<SelectData<dynamic>>().toList();
        }
      } else {
        // 单选模式：defaultValue应该是SelectData
        if (config.defaultValue is SelectData) {
          defaultValue = [config.defaultValue];
        } else if (config.defaultValue is SelectOption) {
          defaultValue = [SelectData(label: config.defaultValue.label, value: config.defaultValue.value, data: null)];
        } else {
          // 如果是原始值，需要在options中查找对应的SelectData
          final foundData = _findSelectDataByValue(props.options, config.defaultValue);
          if (foundData != null) {
            defaultValue = [foundData];
          }
        }
      }
    }

    return FormField<dynamic>(
      validator: config.validator ??
          (val) {
            if (!config.required) return null;
            if (props.multiple) {
              final list = (value as List?) ?? <dynamic>[];
              return list.isEmpty ? '至少选择一项' : null;
            }
            return value == null ? '请选择${config.label}' : null;
          },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TreeSelect<dynamic>(
              options: props.options,
              defaultValue: defaultValue,
              title: props.title,
              hintText: props.hintText,
              multiple: props.multiple,
              remote: props.remote,
              remoteFetch: props.remoteFetch,
              filterable: props.filterable,
              lazyLoad: props.lazyLoad,
              lazyLoadFetch: props.lazyLoadFetch,
              isCacheData: props.isCacheData,
              onSingleSelected: (value, selectedItem) {
                onChanged(value);
                state.didChange(value);
                props.onSingleSelected?.call(value, selectedItem);
              },
              onMultipleSelected: (values, selectedItems) {
                onChanged(values);
                state.didChange(values);
                props.onMultipleSelected?.call(values, selectedItems);
              },
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(state.errorText ?? '', style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        );
      },
    );
  }

  /// 在树形数据中查找指定值对应的SelectData
  SelectData<dynamic>? _findSelectDataByValue(List<SelectData<dynamic>> data, dynamic targetValue) {
    for (final item in data) {
      if (item.value == targetValue) {
        return item;
      }
      // 递归查找子节点
      if (item.children != null && item.children!.isNotEmpty) {
        final found = _findSelectDataByValue(item.children!, targetValue);
        if (found != null) {
          return found;
        }
      }
    }
    return null;
  }
}