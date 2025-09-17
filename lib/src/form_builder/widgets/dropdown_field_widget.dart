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
    final DropdownProps? props = config.props is DropdownProps ? config.props as DropdownProps : null;

    if (props == null) {
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
    final List<SelectData<dynamic>> selectDataList = props.options;

    // 处理默认值
    dynamic defaultValue;
    if (config.defaultValue != null) {
      if (props.multiple) {
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
            DropdownChoose<dynamic>(
              list: props.remote ? null : selectDataList,
              remoteFetch: props.remote
                  ? (String? kw) async {
                      if (props.remoteFetch != null) {
                        final options = await props.remoteFetch!(kw ?? '');
                        return options.map((option) => SelectData(label: option.label, value: option.value, data: null)).toList();
                      }
                      return <SelectData<dynamic>>[];
                    }
                  : null,
              multiple: props.multiple,
              filterable: props.filterable,
              remote: props.remote,
              defaultValue: defaultValue,
              singleTitleText: props.multiple ? null : config.placeholder,
              multipleTitleText: props.multiple ? config.placeholder : null,
              placeholderText: config.placeholder ?? '请选择',
              showAdd: props.showAdd,
              onAdd: props.onAdd,
              onSingleSelected: (value) {
                onChanged(value.value);
                state.didChange(value.value);
                props.onSingleSelected?.call(SelectData(label: value.label, value: value.value));
              },
              onMultipleSelected: (values) {
                final list = values.map((e) => e.value).toList();
                onChanged(list);
                state.didChange(list);
                props.onMultipleSelected?.call(values.map((e) => SelectData(label: e.label, value: e.value)).toList());
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
