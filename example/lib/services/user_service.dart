import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import '../models/city.dart';
import '../models/subject.dart';

class UserService {
  // 基路径
  static const String apiUrl = 'http://192.168.8.188:3000';

  // 获取用户数据
  static Future<List<User>> getUsers() async {
    try {
      final response = await http
          .get(Uri.parse('$apiUrl/api/users'), headers: {'Content-Type': 'application/json', 'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          final List<dynamic> jsonData = responseData['data'] ?? [];

          if (jsonData.isEmpty) {
            print('API返回的数据为空，使用示例数据');
            return _getMockUsers();
          }

          return jsonData.map((json) => User.fromJson(json)).toList();
        } catch (parseError) {
          print('JSON解析失败: $parseError');
          print('响应内容: ${response.body}');
          return _getMockUsers();
        }
      } else {
        throw Exception('获取数据失败: ${response.statusCode}');
      }
    } catch (e) {
      // 如果API调用失败，返回示例数据
      print('API调用失败，使用示例数据: $e');
      return _getMockUsers();
    }
  }

  // 获取用户详情
  static Future<User> getUserDetail(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$apiUrl/api/users/$userId'), headers: {'Content-Type': 'application/json', 'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          final Map<String, dynamic> userData = responseData['data'] ?? responseData;
          return User.fromJson(userData);
        } catch (parseError) {
          print('JSON解析失败: $parseError');
          print('响应内容: ${response.body}');
          throw Exception('数据格式错误');
        }
      } else {
        throw Exception('获取用户详情失败: ${response.statusCode}');
      }
    } catch (e) {
      print('获取用户详情失败: $e');
      rethrow;
    }
  }

  // 更新用户
  static Future<User> updateUser(User user) async {
    if (user.id == null) {
      throw Exception('无法更新：用户没有ID');
    }

    try {
      final response = await http
          .put(Uri.parse('$apiUrl/api/users/${user.id}'), headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}, body: json.encode(user.toJson()))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 如果响应体为空（204状态码）或解析失败，返回传入的用户对象
        if (response.statusCode == 204 || response.body.isEmpty) {
          print('更新成功，返回传入的用户对象');
          return user;
        }

        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          final Map<String, dynamic> userData = responseData['data'] ?? responseData;
          final updatedUser = User.fromJson(userData);

          // 确保返回的用户对象有ID
          if (updatedUser.id == null && user.id != null) {
            print('API返回的用户没有ID，使用传入的ID');
            return User(
              id: user.id,
              name: updatedUser.name,
              gender: updatedUser.gender,
              age: updatedUser.age,
              occupation: updatedUser.occupation,
              education: updatedUser.education,
              hobbies: updatedUser.hobbies,
              avatar: updatedUser.avatar,
              introduction: updatedUser.introduction,
              city: updatedUser.city,
            );
          }

          return updatedUser;
        } catch (parseError) {
          print('JSON解析失败: $parseError');
          print('响应内容: ${response.body}');
          // 如果解析失败，返回传入的用户对象（保持ID）
          return user;
        }
      } else {
        throw Exception('更新用户失败: ${response.statusCode}');
      }
    } catch (e) {
      print('更新用户失败: $e');
      rethrow;
    }
  }

  // 删除用户
  static Future<bool> deleteUser(String userId) async {
    try {
      final response = await http
          .delete(Uri.parse('$apiUrl/api/users/$userId'), headers: {'Content-Type': 'application/json', 'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('删除用户失败: ${response.statusCode}');
      }
    } catch (e) {
      print('删除用户失败: $e');
      rethrow;
    }
  }

  // 创建用户
  static Future<User> createUser(User user) async {
    try {
      final response = await http
          .post(Uri.parse('$apiUrl/api/users'), headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}, body: json.encode(user.toJson()))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Map<String, dynamic> userData = responseData['data'] ?? responseData;
        return User.fromJson(userData);
      } else {
        throw Exception('创建用户失败: ${response.statusCode}');
      }
    } catch (e) {
      print('创建用户失败，返回模拟数据: $e');
      // 如果API调用失败，返回传入的用户对象
      return user;
    }
  }

  // 获取城市列表（仅城市名称）
  static Future<List<City>> getCities(String? keyword) async {
    final url = keyword != null ? '$apiUrl/api/cities?keyword=$keyword' : '$apiUrl/api/cities';
    try {
      final response = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          final List<dynamic> citiesData = responseData['data']['items'] ?? [];
          // 处理城市数据，提取城市名称
          return citiesData.map((city) {
            if (city is Map<String, dynamic>) {
              return City.fromJson(city);
            } else {
              // 如果是字符串格式，创建简单的城市对象
              return City(name: city.toString(), province: '', population: 0, area: 0);
            }
          }).toList();
        } catch (parseError) {
          print('城市数据解析失败: $parseError');
          print('响应内容: ${response.body}');
          return [];
        }
      } else {
        print('获取城市列表失败: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('获取城市列表失败，使用模拟数据: $e');
      return [];
    }
  }

  // 获取科目列表（支持关键字查询）
  static Future<List<Subject>> getSubjects(String? keyword) async {
    final url = keyword != null && keyword.isNotEmpty ? '$apiUrl/api/subjects?keyword=$keyword' : '$apiUrl/api/subjects';
    try {
      final response = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          // 兼容 { data: { items: [...] } } 或 { data: [...] } 或 直接数组
          final dynamic data = responseData['data'];
          final List<dynamic> items = data is Map<String, dynamic> ? (data['items'] ?? []) : (data is List ? data : []);

          return items.map((s) {
            if (s is Map<String, dynamic>) {
              return Subject.fromJson(s);
            } else {
              // 字符串或其他类型，尽量构造一个 Subject，只填充 name
              return Subject(name: s.toString(), category: '');
            }
          }).toList();
        } catch (parseError) {
          print('科目数据解析失败: $parseError');
          print('响应内容: ${response.body}');
          return [];
        }
      } else {
        print('获取科目列表失败: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('获取科目列表失败: $e');
      return [];
    }
  }

  // 示例数据
  static List<User> _getMockUsers() {
    return [
      User(
        name: '张三12',
        gender: '男',
        age: 28,
        occupation: '软件工程师',
        education: '本科',
        hobbies: ['编程', '阅读', '旅行'],
        avatar: 'https://via.placeholder.com/150',
        introduction: '热爱编程的软件工程师，专注于移动应用开发。',
        city: '北京',
      ),
      User(
        name: '李四32',
        gender: '女',
        age: 25,
        occupation: '产品经理',
        education: '硕士',
        hobbies: ['设计', '摄影', '瑜伽'],
        avatar: 'https://via.placeholder.com/150',
        introduction: '有创意的产品经理，善于发现用户需求并转化为优秀的产品。',
        city: '上海',
      ),
      User(
        name: '王五43',
        gender: '男',
        age: 32,
        occupation: '数据分析师',
        education: '博士',
        hobbies: ['数据分析', '机器学习', '健身'],
        avatar: 'https://via.placeholder.com/150',
        introduction: '专业的数据分析师，擅长从数据中发现有价值的洞察。',
        city: '深圳',
      ),
    ];
  }
}
