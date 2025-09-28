import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_config.dart';
import 'package:simple_ui/models/form_type.dart';
import 'package:simple_ui/src/config_form/widgets/index.dart';
import 'config_form_controller.dart';
export 'config_form_controller.dart';

class ConfigForm extends StatefulWidget {
  // 表单配置
  final List<FormConfig> configs;
  // 表单初始值
  final Map<String, dynamic>? initialValues;
  // 表单数据改变回调
  final Function(Map<String, dynamic>)? onChanged;
  // 表单提交按钮构建回调
  final Widget Function(Map<String, dynamic> formData)? submitBuilder;
  // 表单控制器
  final ConfigFormController? controller;

  const ConfigForm({super.key, required this.configs, this.initialValues, this.onChanged, this.submitBuilder, this.controller});

  @override
  State<ConfigForm> createState() => _ConfigFormState();
}

class _ConfigFormState extends State<ConfigForm> {
  late ConfigFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ConfigFormController();
    _initializeFormData();
    _initializeController();
  }

  void _initializeController() {
    _controller.setOnChanged(widget.onChanged);
  }

  void _initializeFormData() {
    final initialData = Map<String, dynamic>.from(widget.initialValues ?? {});

    // 设置默认值
    for (var config in widget.configs) {
      if (!initialData.containsKey(config.name) && config.defaultValue != null) {
        initialData[config.name] = config.defaultValue;
      }
    }

    _controller.initializeData(initialData);
  }

  @override
  void dispose() {
    // 只有当 controller 是内部创建的时候才 dispose
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...widget.configs.where((config) => config.isShow).map((config) {
          if (config.type == FormType.text) {
            return InputForText(config: config, controller: _controller, onChanged: widget.onChanged);
          } else if (config.type == FormType.number) {
            return InputForNumber(config: config, controller: _controller, onChanged: widget.onChanged);
          } else if (config.type == FormType.integer) {
            return InputForInteger(config: config, controller: _controller, onChanged: widget.onChanged);
          } else if (config.type == FormType.textarea) {
            return InputForTextarea(config: config, controller: _controller, onChanged: widget.onChanged);
          } else if (config.type == FormType.radio) {
            return SelectForRadio(config: config, controller: _controller, onChanged: widget.onChanged);
          } else if (config.type == FormType.checkbox) {
            return SelectForCheckbox(config: config, controller: _controller, onChanged: widget.onChanged);
          } else if (config.type == FormType.select) {
            return SelectForSelect(config: config, controller: _controller, onChanged: widget.onChanged);
          } else if (config.type == FormType.dropdown) {
            return SelectForDropdown(config: config, controller: _controller, onChanged: widget.onChanged);
          } else if (config.type == FormType.treeSelect) {
            return SelectForTree(config: config, controller: _controller, onChanged: widget.onChanged);
          } else if (config.type == FormType.date) {
            return DateTimeForDate(config: config, controller: _controller, onChanged: widget.onChanged);
          } else if (config.type == FormType.time) {
            return DateTimeForTime(config: config, controller: _controller, onChanged: widget.onChanged);
          } else if (config.type == FormType.datetime) {
            return DateTimeForDateTime(config: config, controller: _controller, onChanged: widget.onChanged);
          } else if (config.type == FormType.upload) {
            return UploadForFile(config: config, controller: _controller, onChanged: widget.onChanged);
          } else if (config.type == FormType.custom) {
            return CustomForAny(config: config, controller: _controller, onChanged: widget.onChanged);
          } else {
            return InputForText(config: config, controller: _controller, onChanged: widget.onChanged);
          }
          // return Padding(
          //   padding: const EdgeInsets.only(bottom: 16),
          //   child: FieldFactory.buildField(config: config, controller: controller, onChanged: widget.onChanged),
          // );
        }),
      ],
    );
  }
}
