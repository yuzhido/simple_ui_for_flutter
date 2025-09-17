import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_ui/models/form_builder_config.dart';
import 'package:simple_ui/src/form_builder/index.dart';

void main() {
  group('Simple Dropdown Tests', () {
    testWidgets('FormBuilder with dropdown should not throw assertion error', (WidgetTester tester) async {
      final configs = [
        FormBuilderConfig.dropdown(
          name: 'skills',
          label: '技能',
          multiple: true,
          placeholder: '请选择技能',
          options: const [
            SelectOption(label: 'Flutter', value: 'flutter'),
            SelectOption(label: 'Dart', value: 'dart'),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FormBuilder(configs: configs)),
        ),
      );

      // 如果代码执行到这里没有抛出异常，说明修复成功
      expect(find.text('技能'), findsOneWidget);
    });
  });
}
