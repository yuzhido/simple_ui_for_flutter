import 'package:flutter/material.dart';
import 'package:simple_ui/models/config_form_model.dart';
import 'text_field_widget.dart';
import 'textarea_field_widget.dart';
import 'number_field_widget.dart';
import 'integer_field_widget.dart';
import 'date_field_widget.dart';
import 'time_field_widget.dart';
import 'datetime_field_widget.dart';
import 'radio_field_widget.dart';
import 'checkbox_field_widget.dart';
import 'select_field_widget.dart';
import 'tree_select_field_widget.dart';
import 'dropdown_field_widget.dart';
import 'upload_field_widget.dart';
import 'custom_field_widget.dart';

class FieldFactory {
  static Widget buildField({required FormConfig config, required TextEditingController controller, required Function(String) onChanged}) {
    // 如果 FormConfig 提供了自定义 builder（在创建 FormConfig 时已捕获了正确的泛型），优先使用
    if (config.builder != null) {
      return config.builder!(config, controller, onChanged);
    }
    switch (config.type) {
      case FormType.text:
        return TextFieldWidget(config: config, controller: controller, onChanged: onChanged);
      case FormType.textarea:
        return TextareaFieldWidget(config: config, controller: controller, onChanged: onChanged);
      case FormType.number:
        return NumberFieldWidget(config: config, controller: controller, onChanged: onChanged);
      case FormType.integer:
        return IntegerFieldWidget(config: config, controller: controller, onChanged: onChanged);
      case FormType.date:
        return DateFieldWidget(config: config, controller: controller, onChanged: onChanged);
      case FormType.time:
        return TimeFieldWidget(config: config, controller: controller, onChanged: onChanged);
      case FormType.datetime:
        return DateTimeFieldWidget(config: config, controller: controller, onChanged: onChanged);
      case FormType.radio:
        return RadioFieldWidget<dynamic>(config: config, controller: controller, onChanged: onChanged);
      case FormType.checkbox:
        return CheckboxFieldWidget<dynamic>(config: config, controller: controller, onChanged: onChanged);
      case FormType.select:
        return SelectFieldWidget<dynamic>(config: config, controller: controller, onChanged: onChanged);
      case FormType.dropdown:
        return DropdownFieldWidget<dynamic>(config: config, controller: controller, onChanged: onChanged);
      case FormType.upload:
        return UploadFieldWidget(config: config, controller: controller, onChanged: onChanged);
      case FormType.treeSelect:
        // 兜底（理应不会走到这，因为 treeSelect 在创建时已提供了 builder）
        return TreeSelectFieldWidget<dynamic>(config: config, controller: controller, onChanged: onChanged);
      case FormType.custom:
        return CustomFieldWidget(config: config, controller: controller, onChanged: onChanged);
    }
  }
}
