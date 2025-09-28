import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_config.dart';
import 'package:simple_ui/src/config_form/config_form_controller.dart';
import 'package:simple_ui/src/config_form/widgets/index.dart';
import 'package:simple_ui/src/dropdown_choose/index.dart';

class SelectForDropdown<T> extends StatefulWidget {
  final FormConfig config;
  final ConfigFormController controller;
  final Function(Map<String, dynamic>)? onChanged;

  const SelectForDropdown({super.key, required this.config, required this.controller, required this.onChanged});

  @override
  State<SelectForDropdown<T>> createState() => _DropdownFieldContentState<T>();
}

class _DropdownFieldContentState<T> extends State<SelectForDropdown<T>> {
  dynamic defaultValue;
  @override
  void initState() {
    super.initState();
    defaultValue = widget.config.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    final dropdownConfig = widget.config;

    return FormField<dynamic>(
      initialValue: widget.controller.getValue(widget.config.name),
      builder: (state) {
        final dynamic currentValue = widget.controller.getValue(widget.config.name) ?? '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            LabelInfo(widget.config.label, widget.config.required),
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 18),
                  child: DropdownChoose<T>(
                    key: ValueKey('dropdown_${widget.config.name}_$currentValue'), // 使用key强制重新创建组件
                    options: dropdownConfig.props.options,
                    multiple: dropdownConfig.props.multiple,
                    filterable: dropdownConfig.props.filterable,
                    remote: dropdownConfig.props.remote,
                    remoteSearch: dropdownConfig.props.remoteSearch,
                    showAdd: dropdownConfig.props.showAdd,
                    onAdd: dropdownConfig.props.onAdd,
                    alwaysRefresh: dropdownConfig.props.alwaysRefresh,
                    tips: (dropdownConfig.props.tips == '') ? '请选择${widget.config.label}' : dropdownConfig.props.tips,
                    defaultValue: defaultValue,
                    onSingleChanged: (dynamic value, T data, selected) {
                      defaultValue = selected;
                      final valueStr = value?.toString() ?? '';
                      widget.controller.setFieldValue(widget.config.name, valueStr);
                      state.didChange(valueStr);
                      dropdownConfig.props.onSingleChanged?.call(value, data, selected);
                    },
                    onMultipleChanged: (values, datas, selectedList) {
                      defaultValue = selectedList;
                      final valueStr = values.map((v) => v?.toString() ?? '').where((s) => s.isNotEmpty).join(',');
                      widget.controller.setFieldValue(widget.config.name, valueStr);
                      state.didChange(valueStr);
                      dropdownConfig.props.onMultipleChanged?.call(values, datas, selectedList);
                    },
                  ),
                ),
                if (state.errorText != null) Positioned(bottom: 0, left: 0, child: ErrorInfo(state.errorText)),
              ],
            ),
          ],
        );
      },
    );
  }
}
