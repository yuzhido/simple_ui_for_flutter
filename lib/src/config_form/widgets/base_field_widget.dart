import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_config.dart';
// 移除实时校验依赖，统一提交时校验

abstract class BaseFieldWidget extends StatefulWidget {
  final FormConfig config;
  final TextEditingController controller;
  final Function(String) onChanged;

  const BaseFieldWidget({super.key, required this.config, required this.controller, required this.onChanged});

  @override
  State<BaseFieldWidget> createState() => _BaseFieldWidgetState();

  Widget buildField(BuildContext context);
}

class _BaseFieldWidgetState extends State<BaseFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.config.label != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                text: widget.config.label,
                style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
                children: widget.config.required
                    ? [
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ]
                    : [],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        widget.buildField(context),
      ],
    );
  }
}
