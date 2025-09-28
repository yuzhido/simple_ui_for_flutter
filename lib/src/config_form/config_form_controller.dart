import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_config.dart';
import 'utils/validation_utils.dart';

class ConfigFormController extends ChangeNotifier {
  GlobalKey<FormState>? _formKey;
  Map<String, dynamic> _formData = {};
  final Map<String, String> _errors = {};
  Function(Map<String, dynamic>)? _onChanged;

  /// 获取表单数据
  Map<String, dynamic> get formData => Map.unmodifiable(_formData);

  /// 获取错误信息
  Map<String, String> get errors => Map.unmodifiable(_errors);

  /// 内部方法，由ConfigForm组件调用
  void setFormKey(GlobalKey<FormState> formKey) {
    _formKey = formKey;
  }

  void setOnChanged(Function(Map<String, dynamic>)? onChanged) {
    _onChanged = onChanged;
  }

  /// 初始化表单数据
  void initializeData(Map<String, dynamic> initialData) {
    _formData = Map<String, dynamic>.from(initialData);
    notifyListeners();
  }

  /// 验证表单
  bool validate(List<FormConfig> configs) {
    _errors.clear();
    bool isValid = true;

    for (var config in configs) {
      final validator = ValidationUtils.getValidator(config);
      if (validator != null) {
        final value = _formData[config.name]?.toString() ?? '';
        final error = validator(value);
        if (error != null) {
          _errors[config.name] = error;
          isValid = false;
        }
      }
    }

    notifyListeners();
    return isValid;
  }

  /// 获取表单数据
  Map<String, dynamic> getFormData() {
    return Map<String, dynamic>.from(_formData);
  }

  /// 重置表单
  void reset() {
    _formData.clear();
    _errors.clear();
    _formKey?.currentState?.reset();
    notifyListeners();
  }

  /// 保存表单（验证并获取数据）
  Map<String, dynamic>? save(List<FormConfig> configs) {
    if (validate(configs)) {
      return getFormData();
    }
    return null;
  }

  /// 更新字段值
  void updateField(String fieldName, dynamic value) {
    _formData[fieldName] = value;
    _errors.remove(fieldName); // 清除该字段的错误
    notifyListeners();
    _onChanged?.call(_formData);
  }

  /// 获取字段值
  T? getValue<T>(String fieldName) {
    return _formData[fieldName] as T?;
  }

  /// 设置字段值
  void setFieldValue(String fieldName, dynamic value) {
    updateField(fieldName, value);
  }

  /// 批量设置字段值
  void setFieldValues(Map<String, dynamic> values) {
    _formData.addAll(values);
    notifyListeners();
    _onChanged?.call(_formData);
  }

  /// 清空字段值
  void clearFieldValue(String fieldName) {
    _formData.remove(fieldName);
    _errors.remove(fieldName);
    notifyListeners();
    _onChanged?.call(_formData);
  }

  /// 清空所有字段值
  void clearAllFields() {
    _formData.clear();
    _errors.clear();
    notifyListeners();
    _onChanged?.call(_formData);
  }

  /// 设置字段错误
  void setFieldError(String fieldName, String error) {
    _errors[fieldName] = error;
    notifyListeners();
  }

  /// 清除字段错误
  void clearFieldError(String fieldName) {
    _errors.remove(fieldName);
    notifyListeners();
  }
}
