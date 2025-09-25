import 'package:flutter/material.dart';
import 'package:simple_ui/models/field_configs.dart';
import 'package:simple_ui/models/config_form_model.dart';
import 'package:simple_ui/src/config_form/utils/validation_utils.dart';
import 'package:simple_ui/src/config_form/utils/data_conversion_utils.dart';
import 'package:simple_ui/src/widgets/dropdown_container.dart';
import 'base_field_widget.dart';

class SelectFieldWidget<T> extends BaseFieldWidget {
  const SelectFieldWidget({super.key, required super.config, required super.controller, required super.onChanged});

  @override
  Widget buildField(BuildContext context) {
    final selectConfig = config.config as SelectFieldConfig<T>;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        // 使用统一的数据处理工具，智能处理controller文本
        String currentValue = DataConversionUtils.smartProcessControllerText(value.text, FormType.select);

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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(onTap: () => _handleTap(context, selectConfig, state), child: _buildDropdownContainer(selectConfig, currentValue)),
                if (state.errorText != null) ...[const SizedBox(height: 4), Text(state.errorText!, style: const TextStyle(color: Colors.red, fontSize: 12))],
              ],
            );
          },
        );
      },
    );
  }

  // 构建 DropdownContainer
  Widget _buildDropdownContainer(SelectFieldConfig<T> config, String currentValue) {
    if (config.multiple) {
      // 多选模式
      final selectedValues = currentValue.isEmpty ? <String>[] : currentValue.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final selectedItems = config.options.where((option) => selectedValues.contains(option.value.toString())).toList();

      return DropdownContainer<dynamic>(multiple: true, tips: '请选择${this.config.label}', items: selectedItems, isChoosing: false);
    } else {
      // 单选模式
      final selectedItem = config.options.where((option) => option.value.toString() == currentValue).firstOrNull;

      return DropdownContainer<dynamic>(multiple: false, tips: '请选择${this.config.label}', item: selectedItem, isChoosing: false);
    }
  }

  // 处理点击事件
  void _handleTap(BuildContext context, SelectFieldConfig<T> config, FormFieldState<String> state) async {
    if (config.multiple) {
      await _handleMultipleSelect(context, config, state);
    } else {
      await _handleSingleSelect(context, config, state);
    }
  }

  // 处理单选
  Future<void> _handleSingleSelect(BuildContext context, SelectFieldConfig<T> config, FormFieldState<String> state) async {
    final current = controller.text.isEmpty ? null : controller.text;
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('请选择${config.label}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: config.options.map((o) {
                return RadioListTile<String>(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  value: o.value.toString(),
                  groupValue: current,
                  title: Text(o.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  dense: true,
                  onChanged: (val) {
                    controller.text = val ?? '';
                    onChanged(val ?? '');
                    state.didChange(val ?? '');
                    Navigator.of(ctx).pop(val);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
    if (selected != null) {
      controller.text = selected;
      onChanged(selected);
      state.didChange(selected);

      // 调用单选回调
      if (config.onSingleChanged != null) {
        final selectedOption = config.options.firstWhere((option) => option.value.toString() == selected);
        config.onSingleChanged!(selectedOption.value, selectedOption.data, selectedOption);
      }
    }
  }

  // 处理多选
  Future<void> _handleMultipleSelect(BuildContext context, SelectFieldConfig<T> config, FormFieldState<String> state) async {
    final initial = controller.text.isEmpty ? <String>{} : controller.text.split(',').map((e) => e.trim()).toSet();
    final selected = await showDialog<Set<String>>(
      context: context,
      builder: (ctx) {
        final temp = {...initial};
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Text('请选择${config.label}'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: config.options.map((o) {
                    final checked = temp.contains(o.value.toString());
                    return CheckboxListTile(
                      value: checked,
                      title: Text(o.label),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            temp.add(o.value.toString());
                          } else {
                            temp.remove(o.value.toString());
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(initial), child: const Text('取消')),
                ElevatedButton(onPressed: () => Navigator.of(ctx).pop(temp), child: const Text('确定')),
              ],
            );
          },
        );
      },
    );
    if (selected != null) {
      final v = selected.join(',');
      controller.text = v;
      onChanged(v);
      state.didChange(v);

      // 调用多选回调
      if (config.onMultipleChanged != null) {
        final selectedOptions = config.options.where((option) => selected.contains(option.value.toString())).toList();
        config.onMultipleChanged!(selectedOptions.map((e) => e.value).toList(), selectedOptions.map((e) => e.data).toList(), selectedOptions);
      }
    }
  }
}
