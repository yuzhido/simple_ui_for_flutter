/// API 配置类
class ApiConfig {
  /// 基础 URL
  static const String baseUrl = 'http://localhost:3000';

  /// 请求超时时间（毫秒）
  static const int timeout = 10000;

  /// 请求头
  static const Map<String, String> headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};
}
