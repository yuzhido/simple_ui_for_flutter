import 'package:flutter/material.dart';
import 'package:simple_ui/models/config_form_model.dart';
import 'utils/data_conversion_utils.dart';

class ConfigFormController {
  GlobalKey<FormState>? _formKey;
  Map<String, dynamic> Function()? _getFormData;
  Map<String, TextEditingController>? _controllers;
  Map<String, dynamic>? _formData;
  Function(String, dynamic)? _updateFormData;

  /// 内部方法，由ConfigForm组件调用
  void setFormKey(GlobalKey<FormState> formKey) {
    _formKey = formKey;
  }

  void setGetFormData(Map<String, dynamic> Function() getFormData) {
    _getFormData = getFormData;
  }

  void setControllers(Map<String, TextEditingController> controllers) {
    _controllers = controllers;
  }

  void setFormData(Map<String, dynamic> formData) {
    _formData = formData;
  }

  void setUpdateFormData(Function(String, dynamic) updateFormData) {
    _updateFormData = updateFormData;
  }

  /// 验证表单
  bool validate() {
    return _formKey?.currentState?.validate() ?? false;
  }

  /// 获取表单数据
  Map<String, dynamic>? getFormData() {
    return _getFormData?.call();
  }

  /// 重置表单
  void reset() {
    _formKey?.currentState?.reset();
  }

  /// 保存表单（验证并获取数据）
  Map<String, dynamic>? save() {
    if (validate()) {
      return getFormData();
    }
    return null;
  }

  /// 动态设置字段值
  void setFieldValue(String fieldName, dynamic value) {
    if (_controllers != null && _controllers!.containsKey(fieldName)) {
      // 使用统一的数据转换工具，避免List被错误转换
      _controllers![fieldName]!.text = DataConversionUtils.valueToControllerText(value, FormType.text);
    }
    if (_formData != null) {
      _formData![fieldName] = value;
    }
    if (_updateFormData != null) {
      _updateFormData!(fieldName, value);
    }
  }

  /// 批量设置字段值
  void setFieldValues(Map<String, dynamic> values) {
    values.forEach((fieldName, value) {
      setFieldValue(fieldName, value);
    });
  }

  /// 获取字段值
  dynamic getFieldValue(String fieldName) {
    // 优先返回已经解析过类型的表单数据
    if (_formData != null && _formData!.containsKey(fieldName)) {
      return _formData![fieldName];
    }
    // 回退到控件的字符串值
    if (_controllers != null && _controllers!.containsKey(fieldName)) {
      return _controllers![fieldName]!.text;
    }
    return null;
  }

  /// 清空字段值
  void clearFieldValue(String fieldName) {
    setFieldValue(fieldName, '');
  }

  /// 清空所有字段值
  void clearAllFields() {
    if (_controllers != null) {
      _controllers!.forEach((key, controller) {
        // 明确设置为空字符串，而不是调用clear()
        controller.text = '';
      });
    }
    if (_formData != null) {
      _formData!.clear();
    }
  }
}
