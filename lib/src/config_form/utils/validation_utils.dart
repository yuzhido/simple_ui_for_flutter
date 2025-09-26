import 'package:simple_ui/models/form_config.dart';
import 'package:simple_ui/models/field_configs.dart';
import 'package:simple_ui/models/form_type.dart';
import 'package:simple_ui/models/validator.dart';

class ValidationUtils {
  /// 获取字段的验证器
  static FormValidator? getValidator(FormConfig config) {
    // 如果有自定义验证器，优先使用
    if (config.validator != null) {
      return config.validator;
    }

    // 否则使用默认验证规则
    return _getDefaultValidator(config);
  }

  /// 获取默认验证器
  static FormValidator? _getDefaultValidator(FormConfig config) {
    return (String? value) {
      // 必填验证
      if (config.required && (value == null || value.isEmpty)) {
        return '${config.label}不能为空';
      }

      // 如果值为空且非必填，直接通过
      if (value == null || value.isEmpty) {
        return null;
      }

      // 根据字段类型进行验证
      switch (config.type) {
        case FormType.text:
          return _validateText(value, config.config as TextFieldConfig);
        case FormType.textarea:
          return _validateTextarea(value, config.config as TextareaFieldConfig);
        case FormType.number:
          return _validateNumber(value, config.config as NumberFieldConfig);
        case FormType.integer:
          return _validateInteger(value, config.config as IntegerFieldConfig);
        case FormType.date:
          return _validateDate(value, config.config as DateFieldConfig);
        default:
          return null;
      }
    };
  }

  /// 验证文本字段
  static String? _validateText(String value, TextFieldConfig config) {
    // 长度验证
    if (config.minLength != null && value.length < config.minLength!) {
      return '${config.label}至少需要${config.minLength}个字符';
    }
    if (config.maxLength != null && value.length > config.maxLength!) {
      return '${config.label}不能超过${config.maxLength}个字符';
    }

    // 特殊验证规则
    switch (config.name.toLowerCase()) {
      case 'email':
        if (!_isValidEmail(value)) {
          return '请输入有效的邮箱地址';
        }
        break;
      case 'phone':
        if (!_isValidPhone(value)) {
          return '请输入有效的手机号码';
        }
        break;
    }

    return null;
  }

  /// 验证多行文本字段
  static String? _validateTextarea(String value, TextareaFieldConfig config) {
    // 长度验证
    if (config.minLength != null && value.length < config.minLength!) {
      return '${config.label}至少需要${config.minLength}个字符';
    }
    if (config.maxLength != null && value.length > config.maxLength!) {
      return '${config.label}不能超过${config.maxLength}个字符';
    }

    return null;
  }

  /// 验证数字字段
  static String? _validateNumber(String value, NumberFieldConfig config) {
    final number = double.tryParse(value);
    if (number == null) {
      return '请输入有效的数字';
    }

    // 数值范围验证
    if (config.minValue != null && number < config.minValue!) {
      return '${config.label}不能小于${config.minValue}';
    }
    if (config.maxValue != null && number > config.maxValue!) {
      return '${config.label}不能大于${config.maxValue}';
    }

    // 小数位数验证
    if (config.decimalPlaces != null) {
      final parts = value.split('.');
      if (parts.length > 1 && parts[1].length > config.decimalPlaces!) {
        return '${config.label}最多只能有${config.decimalPlaces}位小数';
      }
    }

    return null;
  }

  /// 验证整数字段
  static String? _validateInteger(String value, IntegerFieldConfig config) {
    final integer = int.tryParse(value);
    if (integer == null) {
      return '请输入有效的整数';
    }

    // 数值范围验证
    if (config.minValue != null && integer < config.minValue!) {
      return '${config.label}不能小于${config.minValue}';
    }
    if (config.maxValue != null && integer > config.maxValue!) {
      return '${config.label}不能大于${config.maxValue}';
    }

    return null;
  }

  /// 验证日期字段
  static String? _validateDate(String value, DateFieldConfig config) {
    // 简单的日期格式验证
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(value)) {
      return '请输入有效的日期格式 (YYYY-MM-DD)';
    }

    // 验证日期是否有效
    try {
      final parts = value.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final date = DateTime(year, month, day);

      // 日期范围验证
      if (config.minDate != null && date.isBefore(config.minDate!)) {
        return '${config.label}不能早于${_formatDate(config.minDate!)}';
      }
      if (config.maxDate != null && date.isAfter(config.maxDate!)) {
        return '${config.label}不能晚于${_formatDate(config.maxDate!)}';
      }
    } catch (e) {
      return '请输入有效的日期';
    }

    return null;
  }

  /// 格式化日期
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 验证邮箱格式
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// 验证手机号格式
  static bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    return phoneRegex.hasMatch(phone);
  }
}
