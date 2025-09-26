import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_ui/src/config_form/utils/basic_style.dart';
import 'package:simple_ui/src/custom_form/widgets/error_info.dart';
import 'package:simple_ui/src/custom_form/widgets/label_info.dart';
import 'package:simple_ui/src/custom_form/models/custom_form_config.dart';

class InputForInteger extends StatefulWidget {
  final FormFiledConfig config;
  const InputForInteger({super.key, required this.config});
  @override
  State<InputForInteger> createState() => _InputForIntegerState();
}

class _InputForIntegerState extends State<InputForInteger> {
  late TextEditingController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.config.value?.toString() ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validateInput(String? value) {
    // 必填验证
    if (widget.config.required && (value == null || value.isEmpty)) {
      return '${widget.config.label}不能为空';
    }

    if (value != null && value.isNotEmpty) {
      // 整数格式验证
      final intValue = int.tryParse(value);
      if (intValue == null) {
        return '${widget.config.label}必须是整数';
      }

      // 如果有特定属性配置，进行相应验证
      if (widget.config.props is IntegerFieldProps) {
        final props = widget.config.props as IntegerFieldProps;

        // 最小值验证
        if (props.minValue != null && intValue < props.minValue!) {
          return '${widget.config.label}不能小于${props.minValue}';
        }

        // 最大值验证
        if (props.maxValue != null && intValue > props.maxValue!) {
          return '${widget.config.label}不能大于${props.maxValue}';
        }
      }
    }

    // 自定义验证器
    if (widget.config.validator != null) {
      return widget.config.validator!(value);
    }

    return null;
  }

  void _onChanged(String value) {
    setState(() {
      _errorMessage = _validateInput(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 获取特定属性配置
    final props = widget.config.props is IntegerFieldProps ? widget.config.props as IntegerFieldProps : null;

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelInfo(label: widget.config.label, required: widget.config.required),
              TextFormField(
                controller: _controller,
                keyboardType: TextInputType.number,
                readOnly: props?.readOnly ?? false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: BasicStyle.inputStyle(props?.placeholder ?? '请输入${widget.config.label}'),
                onChanged: _onChanged,
                validator: _validateInput,
              ),
            ],
          ),
        ),
        // 错误信息
        if (_errorMessage != null) Positioned(bottom: 0, left: 0, child: ErrorInfo(_errorMessage!)),
      ],
    );
  }
}
