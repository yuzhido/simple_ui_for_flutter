import 'package:flutter/material.dart';
import 'package:simple_ui/models/field_configs.dart';
import 'package:simple_ui/models/select_data.dart';
import 'package:simple_ui/models/form_config.dart';
import 'package:simple_ui/src/config_form/utils/validation_utils.dart';
import 'package:simple_ui/src/config_form/utils/data_conversion_utils.dart';
import 'package:simple_ui/src/dropdown_choose/index.dart';
import 'package:simple_ui/models/form_type.dart';
import '../base_field_widget.dart';

class SelectForDropdown<T> extends BaseFieldWidget {
  const SelectForDropdown({super.key, required super.config, required super.controller, required super.onChanged});

  @override
  Widget buildField(BuildContext context) {
    return _DropdownFieldContent<T>(config: config, controller: controller, onChanged: onChanged);
  }
}

class _DropdownFieldContent<T> extends StatefulWidget {
  final FormConfig config;
  final TextEditingController controller;
  final Function(String) onChanged;

  const _DropdownFieldContent({required this.config, required this.controller, required this.onChanged});

  @override
  State<_DropdownFieldContent<T>> createState() => _DropdownFieldContentState<T>();
}

class _DropdownFieldContentState<T> extends State<_DropdownFieldContent<T>> {
  // 维护自己的options列表状态，包含初始options和缓存的远程数据
  List<SelectData<T>> _optionsList = [];

  @override
  void initState() {
    super.initState();
    _initializeOptions();
  }

  @override
  void didUpdateWidget(_DropdownFieldContent<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当父组件传入的options发生变化时，更新本地optionsList
    final dropdownConfig = widget.config.config as DropdownFieldConfig<T>;
    final oldDropdownConfig = oldWidget.config.config as DropdownFieldConfig<T>;
    if (dropdownConfig.options != oldDropdownConfig.options) {
      _initializeOptions();
    }
  }

  // 初始化options列表
  void _initializeOptions() {
    final dropdownConfig = widget.config.config as DropdownFieldConfig<T>;
    setState(() {
      _optionsList = List.from(dropdownConfig.options);
    });
  }

  // 缓存数据更新回调
  void _onCacheUpdate(List<SelectData<T>> cachedData) {
    setState(() {
      // 合并现有options和缓存数据，避免重复
      final existingValues = _optionsList.map((e) => e.value).toSet();
      final newOptions = cachedData.where((item) => !existingValues.contains(item.value)).toList();
      _optionsList = [..._optionsList, ...newOptions];
    });
  }

  @override
  Widget build(BuildContext context) {
    final dropdownConfig = widget.config.config as DropdownFieldConfig<T>;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, value, child) {
        // 使用统一的数据处理工具，智能处理controller文本
        String currentValue = DataConversionUtils.smartProcessControllerText(value.text, FormType.dropdown);

        // 计算当前的结构化默认值
        final structuredDefault = _getDefaultValue(dropdownConfig, currentValue);

        return FormField<String>(
          initialValue: currentValue,
          validator: ValidationUtils.getValidator(widget.config),
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
                  key: ValueKey('dropdown_${widget.config.name}_$currentValue'), // 使用key强制重新创建组件
                  options: _optionsList,
                  multiple: dropdownConfig.multiple,
                  filterable: dropdownConfig.filterable,
                  remote: dropdownConfig.remote,
                  remoteSearch: dropdownConfig.remoteSearch,
                  showAdd: dropdownConfig.showAdd,
                  onAdd: dropdownConfig.onAdd,
                  alwaysRefresh: dropdownConfig.alwaysRefresh,
                  tips: dropdownConfig.tips == '' ? '请选择${widget.config.label}' : dropdownConfig.tips,
                  defaultValue: structuredDefault,
                  onCacheUpdate: _onCacheUpdate,
                  onSingleChanged: (dynamic value, T data, selected) {
                    final valueStr = value?.toString() ?? '';
                    widget.controller.text = valueStr;
                    widget.onChanged(valueStr);
                    state.didChange(valueStr);
                    dropdownConfig.onSingleChanged?.call(value, data, selected);
                  },
                  onMultipleChanged: (values, datas, selectedList) {
                    final valueStr = values.map((v) => v?.toString() ?? '').where((s) => s.isNotEmpty).join(',');
                    widget.controller.text = valueStr;
                    widget.onChanged(valueStr);
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
    if (currentValue.isEmpty) return null;

    if (dropdownConfig.multiple) {
      // 多选模式
      final values = currentValue.split(',').where((v) => v.isNotEmpty).toList();
      if (values.isEmpty) return null;

      final matchedOptions = values
          .map((value) {
            try {
              return _optionsList.where((option) => option.value.toString() == value).toList();
            } catch (e) {
              return <SelectData<T>>[];
            }
          })
          .expand((list) => list)
          .toList();

      if (matchedOptions.isNotEmpty) {
        return matchedOptions;
      }

      // 远程搜索场景：当_optionsList为空但currentValue有值时，创建临时SelectData
      if (dropdownConfig.remote && _optionsList.isEmpty) {
        return values
            .map(
              (value) => SelectData<T>(
                label: value, // 暂时使用value作为label，DropdownChoose会在搜索后更新
                value: value as T,
                data: value as T,
              ),
            )
            .toList();
      }

      return null;
    } else {
      // 单选模式
      try {
        final matchedOptions = _optionsList.where((option) => option.value.toString() == currentValue).toList();
        if (matchedOptions.isNotEmpty) {
          return matchedOptions.first;
        }

        // 远程搜索场景：当_optionsList为空但currentValue有值时，创建临时SelectData
        if (dropdownConfig.remote && _optionsList.isEmpty) {
          return SelectData<T>(
            label: currentValue, // 暂时使用value作为label，DropdownChoose会在搜索后更新
            value: currentValue as T,
            data: currentValue as T,
          );
        }

        return null;
      } catch (e) {
        return null;
      }
    }
  }
}
