import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_config.dart';
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
    countNotifier = ValueNotifier(widget.controller.errors);
  }

  late ValueNotifier<Map<String, String>> countNotifier;

  @override
  Widget build(BuildContext context) {
    final dropdownConfig = widget.config;
    final dropdownProps = dropdownConfig.props as DropdownProps<T>;
    final config = widget.config;
    final errorsInfo = widget.controller.errors;
    return ValueListenableBuilder(
      valueListenable: countNotifier,
      builder: (context, _, __) {
        final dynamic currentValue = widget.controller.getValue<dynamic>(widget.config.name) ?? '';
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
                    options: dropdownProps.options,
                    multiple: dropdownProps.multiple,
                    filterable: dropdownProps.filterable,
                    remote: dropdownProps.remote,
                    remoteSearch: dropdownProps.remoteSearch,
                    showAdd: dropdownProps.showAdd,
                    onAdd: dropdownProps.onAdd,
                    alwaysRefresh: dropdownProps.alwaysRefresh,
                    tips: (dropdownProps.tips == '') ? '请选择${widget.config.label}' : dropdownProps.tips,
                    defaultValue: defaultValue,
                    onSingleChanged: (dynamic value, T data, selected) {
                      defaultValue = selected;
                      widget.controller.setFieldValue(widget.config.name, value);
                      dropdownProps.onSingleChanged?.call(value, data, selected);
                    },
                    onMultipleChanged: (values, datas, selectedList) {
                      defaultValue = selectedList;
                      widget.controller.setFieldValue(widget.config.name, values);
                      dropdownProps.onMultipleChanged?.call(values, datas, selectedList);
                    },
                  ),
                ),
                if (errorsInfo[config.name] != null) Positioned(bottom: 0, left: 0, child: ErrorInfo(errorsInfo[config.name]!)),
              ],
            ),
          ],
        );
      },
    );
  }
}
