import 'package:flutter_test/flutter_test.dart';
import 'package:simple_ui/models/form_builder_config.dart';
import 'package:simple_ui/src/form_builder/index.dart';

void main() {
  group('FormBuilder Tests', () {
    test('FormBuilderController should manage values correctly', () {
      final controller = FormBuilderController();

      // 测试设置值
      controller.setValue('name', 'John');
      expect(controller.getValue('name'), 'John');

      // 测试批量设置
      controller.setValues({'age': 25, 'city': 'Beijing'});
      expect(controller.values, {'name': 'John', 'age': 25, 'city': 'Beijing'});

      // 测试清空
      controller.clear();
      expect(controller.values, {});
    });

    test('FormBuilderConfig should create radio and checkbox configs correctly', () {
      // 测试单选配置
      final radioConfig = FormBuilderConfig.radio(
        name: 'gender',
        label: '性别',
        required: true,
        options: const [
          SelectOption(label: '男', value: 'male'),
          SelectOption(label: '女', value: 'female'),
        ],
      );

      expect(radioConfig.name, 'gender');
      expect(radioConfig.type, FormBuilderType.radio);
      expect(radioConfig.required, true);
      expect(radioConfig.props, isA<List<SelectOption>>());

      // 测试多选配置
      final checkboxConfig = FormBuilderConfig.checkbox(
        name: 'hobbies',
        label: '爱好',
        required: false,
        defaultValue: [],
        options: const [
          SelectOption(label: '阅读', value: 'reading'),
          SelectOption(label: '运动', value: 'sports'),
        ],
      );

      expect(checkboxConfig.name, 'hobbies');
      expect(checkboxConfig.type, FormBuilderType.checkbox);
      expect(checkboxConfig.required, false);
      expect(checkboxConfig.defaultValue, []);
      expect(checkboxConfig.props, isA<List<SelectOption>>());
    });

    test('SelectOption should work correctly', () {
      const option = SelectOption(label: '测试选项', value: 'test_value');
      expect(option.label, '测试选项');
      expect(option.value, 'test_value');
    });

    test('FormBuilderConfig should create select config correctly', () {
      // 测试下拉选择配置
      final selectConfig = FormBuilderConfig.select(
        name: 'city',
        label: '城市',
        required: true,
        defaultValue: null,
        placeholder: '请选择城市',
        options: const [
          SelectOption(label: '北京', value: 'beijing'),
          SelectOption(label: '上海', value: 'shanghai'),
        ],
      );

      expect(selectConfig.name, 'city');
      expect(selectConfig.type, FormBuilderType.select);
      expect(selectConfig.required, true);
      expect(selectConfig.placeholder, '请选择城市');
      expect(selectConfig.props, isA<List<SelectOption>>());
    });

    test('FormBuilderConfig should create dropdown config correctly', () {
      // 测试自定义下拉配置
      final dropdownConfig = FormBuilderConfig.dropdown(
        name: 'skills',
        label: '技能',
        required: false,
        multiple: true,
        filterable: true,
        options: const [
          SelectOption(label: 'Flutter', value: 'flutter'),
          SelectOption(label: 'Dart', value: 'dart'),
        ],
      );

      expect(dropdownConfig.name, 'skills');
      expect(dropdownConfig.type, FormBuilderType.dropdown);
      expect(dropdownConfig.required, false);
      expect(dropdownConfig.props, isA<DropdownProps>());

      final props = dropdownConfig.props as DropdownProps;
      expect(props.multiple, true);
      expect(props.filterable, true);
      expect(props.options.length, 2);
    });

    test('FormBuilderConfig should create upload config correctly', () {
      // 测试文件上传配置
      final uploadConfig = FormBuilderConfig.upload(name: 'avatar', label: '头像', required: false, uploadText: '上传头像', limit: 3);

      expect(uploadConfig.name, 'avatar');
      expect(uploadConfig.type, FormBuilderType.upload);
      expect(uploadConfig.required, false);
      expect(uploadConfig.props, isA<UploadProps>());

      final props = uploadConfig.props as UploadProps;
      expect(props.uploadText, '上传头像');
      expect(props.limit, 3);
    });
  });
}
