import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';

/// 复选框字段组件
class CheckboxFieldWidget extends StatefulWidget {
  final FormBuilderConfig config;
  final List<dynamic> value;
  final Function(List<dynamic>) onChanged;

  const CheckboxFieldWidget({super.key, required this.config, required this.value, required this.onChanged});

  @override
  State<CheckboxFieldWidget> createState() => _CheckboxFieldWidgetState();
}

class _CheckboxFieldWidgetState extends State<CheckboxFieldWidget> {
  @override
  Widget build(BuildContext context) {
    final List<SelectOption> options = widget.config.props is List<SelectOption> ? widget.config.props as List<SelectOption> : [];

    return FormField<List<dynamic>>(
      validator:
          widget.config.validator ??
          (val) {
            if (!widget.config.required) return null;
            return widget.value.isEmpty ? '至少选择一项' : null;
          },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupContainer(
              Column(
                children: options
                    .map(
                      (option) => CheckboxListTile(
                        title: Text(option.label, style: const TextStyle(fontSize: 14)),
                        value: widget.value.contains(option.value),
                        onChanged: (checked) {
                          final newList = List<dynamic>.from(widget.value);
                          if (checked == true) {
                            if (!newList.contains(option.value)) {
                              newList.add(option.value);
                            }
                          } else {
                            newList.remove(option.value);
                          }
                          widget.onChanged(newList);
                          state.didChange(newList);
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                    .toList(),
              ),
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

  Widget _buildGroupContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: child,
    );
  }
}
