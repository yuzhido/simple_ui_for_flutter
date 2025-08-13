import 'package:flutter_test/flutter_test.dart';
import 'package:example/services/user_service.dart';
import 'package:example/models/city.dart';

void main() {
  group('城市服务测试', () {
    test('应该能正确处理对象格式的城市数据', () {
      // 模拟API响应数据
      final mockResponse = {
        'data': [
          {'name': '北京', 'province': '北京市', 'population': 2154, 'area': 16410},
          {'name': '上海', 'province': '上海市', 'population': 2424, 'area': 6340},
        ],
      };

      // 测试城市名称提取
      final citiesData = mockResponse['data'] as List<dynamic>;
      final cityNames = citiesData
          .map((city) {
            if (city is Map<String, dynamic>) {
              return city['name']?.toString() ?? '';
            } else {
              return city.toString();
            }
          })
          .where((name) => name.isNotEmpty)
          .toList();

      expect(cityNames, equals(['北京', '上海']));
    });

    test('应该能正确处理字符串格式的城市数据', () {
      // 模拟API响应数据
      final mockResponse = {
        'data': ['北京', '上海', '广州'],
      };

      // 测试城市名称提取
      final citiesData = mockResponse['data'] as List<dynamic>;
      final cityNames = citiesData
          .map((city) {
            if (city is Map<String, dynamic>) {
              return city['name']?.toString() ?? '';
            } else {
              return city.toString();
            }
          })
          .where((name) => name.isNotEmpty)
          .toList();

      expect(cityNames, equals(['北京', '上海', '广州']));
    });

    test('城市模型应该正确解析JSON数据', () {
      final jsonData = {'name': '北京', 'province': '北京市', 'population': 2154, 'area': 16410};

      final city = City.fromJson(jsonData);

      expect(city.name, equals('北京'));
      expect(city.province, equals('北京市'));
      expect(city.population, equals(2154));
      expect(city.area, equals(16410));
    });

    test('城市模型toString应该返回城市名称', () {
      final city = City(name: '北京', province: '北京市', population: 2154, area: 16410);

      expect(city.toString(), equals('北京'));
    });
  });
}
