/// 文件信息类，用于表示默认值中的文件信息
class FileInfo {
  /// 文件ID，可以是数字或字符串
  final dynamic id;
  
  /// 文件名称
  final String fileName;
  
  /// 文件请求路径/URL
  final String requestPath;

  const FileInfo({
    required this.id,
    required this.fileName,
    required this.requestPath,
  });

  /// 从Map创建FileInfo实例
  factory FileInfo.fromMap(Map<String, dynamic> map) {
    return FileInfo(
      id: map['id'],
      fileName: map['fileName'] ?? '',
      requestPath: map['requestPath'] ?? '',
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'requestPath': requestPath,
    };
  }

  /// 复制并修改属性
  FileInfo copyWith({
    dynamic id,
    String? fileName,
    String? requestPath,
  }) {
    return FileInfo(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      requestPath: requestPath ?? this.requestPath,
    );
  }

  @override
  String toString() {
    return 'FileInfo(id: $id, fileName: $fileName, requestPath: $requestPath)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileInfo &&
        other.id == id &&
        other.fileName == fileName &&
        other.requestPath == requestPath;
  }

  @override
  int get hashCode {
    return id.hashCode ^ fileName.hashCode ^ requestPath.hashCode;
  }
}