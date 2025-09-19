import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';

/// 自定义字段组件
class CustomFieldWidget extends StatelessWidget {
  final FormBuilderConfig config;
  final dynamic value;
  final Function(dynamic) onChanged;

  const CustomFieldWidget({super.key, required this.config, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // 安全检查：确保配置类型正确
    if (config.type != FormBuilderType.custom) {
      throw FlutterError(
        'CustomFieldWidget: 配置类型错误！\n'
        '期望类型: FormBuilderType.custom\n'
        '实际类型: ${config.type}\n'
        '请检查FormBuilder配置。',
      );
    }

    // 如果提供了contentBuilder，使用自定义构建器
    if (config.contentBuilder != null) {
      try {
        return config.contentBuilder!(context, config, value, onChanged);
      } catch (e) {
        // 捕获contentBuilder中的错误，提供友好的错误信息
        return Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.red.shade50,
          ),
          child: Center(
            child: Text(
              '自定义组件渲染错误: $e',
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }

    // 如果没有提供contentBuilder，显示错误提示
    // 注意：这种情况理论上不应该发生，因为构造函数已经有验证
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.orange.shade50,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
            const SizedBox(height: 4),
            Text(
              '缺少contentBuilder',
              style: TextStyle(color: Colors.orange.shade700, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text('请使用FormBuilderConfig.custom()', style: TextStyle(color: Colors.orange.shade600, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
