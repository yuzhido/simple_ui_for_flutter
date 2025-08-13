import 'package:flutter_test/flutter_test.dart';
import 'package:example/services/user_service.dart';
import 'package:example/models/user.dart';

void main() {
  group('UserService Tests', () {
    test('should return mock users when API is not available', () async {
      final users = await UserService.getUsers();

      expect(users, isA<List<User>>());
      expect(users.isNotEmpty, true);

      // 验证第一个用户的数据结构
      final firstUser = users.first;
      expect(firstUser.name, isNotEmpty);
      expect(firstUser.age, isA<int>());
      expect(firstUser.hobbies, isA<List<String>>());
    });

    test('should create user from json correctly', () {
      final jsonData = {
        'name': '测试用户',
        'gender': '男',
        'age': 25,
        'occupation': '测试工程师',
        'education': '本科',
        'hobbies': ['测试', '编程'],
        'avatar': 'https://example.com/avatar.jpg',
        'introduction': '这是一个测试用户',
        'city': '北京',
      };

      final user = User.fromJson(jsonData);

      expect(user.name, '测试用户');
      expect(user.age, 25);
      expect(user.hobbies, ['测试', '编程']);
    });
  });
}
