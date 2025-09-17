import 'package:flutter_test/flutter_test.dart';
import 'package:simple_ui/models/form_builder_config.dart';
import 'package:simple_ui/src/form_builder/index.dart';

void main() {
  group('Dropdown Fix Tests', () {
    test('DropdownChoose should not throw assertion error', () {
      // 测试多选模式
      final multiConfig = FormBuilderConfig.dropdown(
        name: 'skills',
        label: '技能',
        multiple: true,
        placeholder: '请选择技能',
        options: const [
          SelectOption(label: 'Flutter', value: 'flutter'),
          SelectOption(label: 'Dart', value: 'dart'),
        ],
      );

      expect(multiConfig.name, 'skills');
      expect(multiConfig.type, FormBuilderType.dropdown);

      final props = multiConfig.props as DropdownProps;
      expect(props.multiple, true);
      expect(props.options.length, 2);
    });

    test('DropdownChoose should not throw assertion error for single select', () {
      // 测试单选模式
      final singleConfig = FormBuilderConfig.dropdown(
        name: 'city',
        label: '城市',
        multiple: false,
        placeholder: '请选择城市',
        options: const [
          SelectOption(label: '北京', value: 'beijing'),
          SelectOption(label: '上海', value: 'shanghai'),
        ],
      );

      expect(singleConfig.name, 'city');
      expect(singleConfig.type, FormBuilderType.dropdown);

      final props = singleConfig.props as DropdownProps;
      expect(props.multiple, false);
      expect(props.options.length, 2);
    });
  });
}
