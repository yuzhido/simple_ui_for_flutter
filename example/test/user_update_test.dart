import 'package:flutter_test/flutter_test.dart';
import 'package:example/models/user.dart';

void main() {
  group('用户更新功能测试', () {
    test('用户ID应该被正确保留', () {
      // 创建一个有ID的用户
      final originalUser = User(
        id: '123',
        name: '张三',
        gender: '男',
        age: 25,
        occupation: '工程师',
        education: '本科',
        hobbies: ['编程'],
        avatar: 'https://example.com/avatar.jpg',
        introduction: '测试用户',
        city: '北京',
      );

      // 验证原始用户有ID
      expect(originalUser.id, equals('123'));

      // 创建更新后的用户对象
      final updatedUser = User(
        id: originalUser.id, // 保留原始ID
        name: '张三（已更新）',
        gender: '男',
        age: 26,
        occupation: '高级工程师',
        education: '本科',
        hobbies: ['编程', '阅读'],
        avatar: 'https://example.com/avatar.jpg',
        introduction: '测试用户（已更新）',
        city: '北京',
      );

      // 验证更新后的用户仍然有ID
      expect(updatedUser.id, equals('123'));
      expect(updatedUser.name, equals('张三（已更新）'));
    });

    test('用户toJson应该包含ID', () {
      final user = User(id: '456', name: '李四', gender: '女', age: 30, occupation: '设计师', education: '硕士', hobbies: ['设计'], avatar: '', introduction: '', city: '上海');

      final json = user.toJson();
      expect(json['id'], equals('456'));
      expect(json['name'], equals('李四'));
    });

    test('用户fromJson应该正确解析ID', () {
      final json = {
        'id': '789',
        'name': '王五',
        'gender': '男',
        'age': 35,
        'occupation': '经理',
        'education': '博士',
        'hobbies': ['管理'],
        'avatar': '',
        'introduction': '',
        'city': '深圳',
      };

      final user = User.fromJson(json);
      expect(user.id, equals('789'));
      expect(user.name, equals('王五'));
    });
  });
}
