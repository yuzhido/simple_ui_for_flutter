import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';
import 'package:simple_ui/models/select_data.dart';
import 'package:simple_ui/src/dropdown_choose/index.dart';

/// 自定义下拉字段组件
class DropdownFieldWidget extends StatelessWidget {
  final FormBuilderConfig config;
  final dynamic value;
  final Function(dynamic) onChanged;

  const DropdownFieldWidget({super.key, required this.config, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // 支持任何类型的 DropdownProps
    final dynamic propsRaw = config.props;
    if (propsRaw == null) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Text('配置错误')),
      );
    }

    // 使用DropdownProps中的options（已经是SelectData类型）
    final List<SelectData<dynamic>> selectDataList = propsRaw.options;

    // 处理默认值
    dynamic defaultValue;
    if (config.defaultValue != null) {
      if (propsRaw.multiple) {
        // 多选模式：defaultValue可以是List<SelectOption>或List<SelectData>
        if (config.defaultValue is List<SelectOption>) {
          defaultValue = config.defaultValue.map((option) => SelectData(label: option.label, value: option.value, data: null)).toList();
        } else if (config.defaultValue is List<SelectData>) {
          defaultValue = config.defaultValue;
        }
      } else {
        // 单选模式：defaultValue可以是SelectOption或SelectData
        if (config.defaultValue is SelectOption) {
          defaultValue = SelectData(label: config.defaultValue.label, value: config.defaultValue.value, data: null);
        } else if (config.defaultValue is SelectData) {
          defaultValue = config.defaultValue;
        }
      }
    }

    return FormField<dynamic>(
      validator:
          config.validator ??
          (val) {
            if (!config.required) return null;
            if (propsRaw.multiple) {
              final list = (value as List?) ?? <dynamic>[];
              return list.isEmpty ? '至少选择一项' : null;
            }
            return value == null ? '请选择${config.label}' : null;
          },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownChoose<dynamic>(
              list: propsRaw.remote ? null : selectDataList,
              remoteFetch: propsRaw.remote
                  ? (String? kw) async {
                      if (propsRaw.remoteFetch != null) {
                        return await propsRaw.remoteFetch!(kw ?? '');
                      }
                      return <SelectData<dynamic>>[];
                    }
                  : null,
              multiple: propsRaw.multiple,
              filterable: propsRaw.filterable,
              remote: propsRaw.remote,
              defaultValue: defaultValue,
              singleTitleText: propsRaw.multiple ? null : config.placeholder,
              multipleTitleText: propsRaw.multiple ? config.placeholder : null,
              placeholderText: config.placeholder ?? '请选择',
              showAdd: propsRaw.showAdd,
              onAdd: propsRaw.onAdd,
              alwaysFreshData: propsRaw.alwaysFreshData,
              onSingleSelected: (value) {
                onChanged(value.value);
                state.didChange(value.value);
                propsRaw.onSingleSelected?.call(value);
              },
              onMultipleSelected: (values) {
                final list = values.map((e) => e.value).toList();
                onChanged(list);
                state.didChange(list);
                propsRaw.onMultipleSelected?.call(values);
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
}
