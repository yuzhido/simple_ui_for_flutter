import 'package:flutter/material.dart';
import 'package:simple_ui/models/field_configs.dart';
import 'package:simple_ui/simple_ui.dart';

/// Time和DateTime字段示例页面
/// 展示时间选择器和日期时间选择器的使用
class TimeDateTimeExamplePage extends StatefulWidget {
  const TimeDateTimeExamplePage({super.key});

  @override
  State<TimeDateTimeExamplePage> createState() => _TimeDateTimeExamplePageState();
}

class _TimeDateTimeExamplePageState extends State<TimeDateTimeExamplePage> {
  Map<String, dynamic> _formData = {};

  // 表单配置 - 包含时间相关字段
  List<FormConfig> get _formConfigs => [
    // 基础字段
    FormConfig.text(TextFieldConfig(name: 'title', label: '事件标题', required: true, defaultValue: '重要会议')),

    // 日期字段
    FormConfig.date(DateFieldConfig(name: 'eventDate', label: '事件日期', required: true, defaultValue: '2024-01-15')),

    // 时间字段
    FormConfig.time(TimeFieldConfig(name: 'startTime', label: '开始时间', required: true, defaultValue: '09:00')),

    FormConfig.time(TimeFieldConfig(name: 'endTime', label: '结束时间', required: false, defaultValue: '17:00')),

    // 日期时间字段
    FormConfig.datetime(DateTimeFieldConfig(name: 'deadline', label: '截止时间', required: true, defaultValue: '2024-01-20 18:00')),

    FormConfig.datetime(DateTimeFieldConfig(name: 'reminder', label: '提醒时间', required: false)),

    // 其他字段
    FormConfig.textarea(TextareaFieldConfig(name: 'description', label: '事件描述', required: false, defaultValue: '这是一个重要的事件，请准时参加。', rows: 3)),
  ];

  void _onFormChanged(Map<String, dynamic> data) {
    setState(() {
      _formData = data;
    });
  }

  void _onFormSubmit(Map<String, dynamic> data) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('表单提交成功！\n数据：${data.toString()}'), backgroundColor: Colors.green, duration: const Duration(seconds: 3)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time & DateTime 字段示例'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 功能说明
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Time & DateTime 字段功能：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• Time字段：点击选择时间，格式 HH:mm'),
                  Text('• DateTime字段：先选日期再选时间，格式 YYYY-MM-DD HH:mm'),
                  Text('• 支持默认值设置'),
                  Text('• 支持必填验证'),
                  Text('• 支持isShow属性控制显示隐藏'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 表单
            ConfigForm(
              configs: _formConfigs,
              onChanged: _onFormChanged,
              submitBuilder: (formData) => Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _onFormSubmit(formData),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: const Text('提交表单'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 实时表单数据
            const Text('实时表单数据：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(_formData.toString(), style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ),
            const SizedBox(height: 20),

            // 代码示例
            const Text('代码示例：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
              child: Text('''// 时间字段
FormConfig.time(TimeFieldConfig(
  name: 'startTime',
  label: '开始时间',
  required: true,
  defaultValue: '09:00',
)),

// 日期时间字段
FormConfig.datetime(DateTimeFieldConfig(
  name: 'deadline',
  label: '截止时间',
  required: true,
  defaultValue: '2024-01-20 18:00',
)),

// 带验证的日期时间字段
FormConfig.datetime(DateTimeFieldConfig(
  name: 'meetingTime',
  label: '会议时间',
  required: true,
  minDate: DateTime.now(),
  maxDate: DateTime.now().add(Duration(days: 30)),
)),''', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.green[300])),
            ),
            const SizedBox(height: 20),

            // 使用场景
            const Text('使用场景：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              '• 会议安排：选择会议日期和时间\n'
              '• 任务管理：设置任务截止时间\n'
              '• 预约系统：选择预约时间\n'
              '• 活动管理：设置活动开始和结束时间\n'
              '• 提醒功能：设置提醒时间\n'
              '• 工作时间：设置上下班时间',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
