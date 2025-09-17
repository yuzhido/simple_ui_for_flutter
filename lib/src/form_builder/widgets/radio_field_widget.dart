import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';

/// 单选框字段组件
class RadioFieldWidget extends StatefulWidget {
  final FormBuilderConfig config;
  final dynamic value;
  final Function(dynamic) onChanged;

  const RadioFieldWidget({super.key, required this.config, this.value, required this.onChanged});

  @override
  State<RadioFieldWidget> createState() => _RadioFieldWidgetState();
}

class _RadioFieldWidgetState extends State<RadioFieldWidget> {
  @override
  Widget build(BuildContext context) {
    final List<SelectOption> options = widget.config.props is List<SelectOption> ? widget.config.props as List<SelectOption> : [];

    return FormField<dynamic>(
      validator:
          widget.config.validator ??
          (val) {
            if (!widget.config.required) return null;
            return widget.value == null ? '请选择${widget.config.label}' : null;
          },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupContainer(
              Column(
                children: options
                    .map(
                      (option) => InkWell(
                        onTap: () {
                          widget.onChanged(option.value);
                          state.didChange(option.value);
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          children: [
                            Expanded(child: Text(option.label, style: const TextStyle(fontSize: 14))),
                            Radio<dynamic>(
                              value: option.value,
                              groupValue: widget.value,
                              onChanged: (v) {
                                widget.onChanged(v);
                                state.didChange(v);
                              },
                            ),
                          ],
                        ),
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
