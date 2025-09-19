/// 文件列表类型
enum FileListType {
  textInfo, // 默认样式
  card, // 卡片样式 - 小巧紧凑的卡片
  custom, // 自定义样式
}

/// 上传状态
enum UploadStatus {
  pending, // 等待上传
  uploading, // 上传中
  success, // 上传成功
  failed, // 上传失败
}

/// 文件来源
enum FileSource {
  all, // 允许所有类型：文件、图片、拍照
  file, // 只允许选择文件
  image, // 只允许选择图片
  camera, // 只允许拍照
  imageOrCamera, // 只允许选择图片或拍照
}

// 文件上传实体类
class FileInfo {
  final dynamic id;
  final String fileName;
  final String requestPath;
  FileInfo({required this.id, required this.fileName, required this.requestPath});

  /// 从Map创建FileInfo实例
  factory FileInfo.fromMap(Map<String, dynamic> map) {
    return FileInfo(id: map['id'], fileName: map['fileName'] ?? '', requestPath: map['requestPath'] ?? '');
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {'id': id, 'fileName': fileName, 'requestPath': requestPath};
  }

  /// 创建FileInfo的副本，可选择性地更新某些字段
  FileInfo copyWith({dynamic id, String? fileName, String? requestPath}) {
    return FileInfo(id: id ?? this.id, fileName: fileName ?? this.fileName, requestPath: requestPath ?? this.requestPath);
  }
}

// 上传配置类
class UploadConfig {
  /// 请求头信息
  final Map<String, String>? headers;

  /// 上传接口路径
  final String? uploadUrl;

  /// 请求方法，默认为POST
  final String method;

  /// 请求超时时间（秒），默认30秒
  final int timeout;

  /// 文件字段名，默认为'file'
  final String fileFieldName;

  /// 额外的表单数据
  final Map<String, dynamic>? extraData;

  UploadConfig({this.headers, this.uploadUrl, this.method = 'POST', this.timeout = 30, this.fileFieldName = 'file', this.extraData});

  /// 验证配置是否有效
  /// 有效条件：提供了uploadUrl
  bool get isValid => uploadUrl != null && uploadUrl!.isNotEmpty;

  /// 从Map创建UploadConfig实例
  /// 注意：customUpload函数无法从Map反序列化，需要单独设置
  factory UploadConfig.fromMap(Map<String, dynamic> map) {
    return UploadConfig(
      headers: map['headers'] != null ? Map<String, String>.from(map['headers']) : null,
      uploadUrl: map['uploadUrl'],
      method: map['method'] ?? 'POST',
      timeout: map['timeout'] ?? 30,
      fileFieldName: map['fileFieldName'] ?? 'file',
      extraData: map['extraData'],
      // customUpload函数无法序列化，需要单独设置
    );
  }

  /// 转换为Map
  /// 注意：customUpload函数无法序列化，不包含在Map中
  Map<String, dynamic> toMap() {
    return {
      'headers': headers,
      'uploadUrl': uploadUrl,
      'method': method,
      'timeout': timeout,
      'fileFieldName': fileFieldName,
      'extraData': extraData,
      // customUpload函数无法序列化
    };
  }

  /// 复制并修改配置
  UploadConfig copyWith({Map<String, String>? headers, String? uploadUrl, String? method, int? timeout, String? fileFieldName, Map<String, dynamic>? extraData}) {
    return UploadConfig(
      headers: headers ?? this.headers,
      uploadUrl: uploadUrl ?? this.uploadUrl,
      method: method ?? this.method,
      timeout: timeout ?? this.timeout,
      fileFieldName: fileFieldName ?? this.fileFieldName,
      extraData: extraData ?? this.extraData,
    );
  }
}

// 文件上传模型类
class FileUploadModel {
  final FileInfo fileInfo;
  final String name;
  final String path;
  final FileSource? source;
  final UploadStatus? status;
  final double progress;
  final int? fileSize; // 文件大小（字节）
  final String? fileSizeInfo; // 格式化后的文件大小信息

  FileUploadModel({required this.fileInfo, required this.name, required this.path, this.source, this.fileSize, this.fileSizeInfo, this.status, this.progress = 0});

  /// 复制并修改模型
  FileUploadModel copyWith({FileInfo? fileInfo, String? name, String? path, FileSource? source, UploadStatus? status, double? progress, int? fileSize, String? fileSizeInfo}) {
    return FileUploadModel(
      fileInfo: fileInfo ?? this.fileInfo,
      name: name ?? this.name,
      path: path ?? this.path,
      source: source ?? this.source,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      fileSize: fileSize ?? this.fileSize,
      fileSizeInfo: fileSizeInfo ?? this.fileSizeInfo,
    );
  }

  /// 从Map创建FileUploadModel实例
  factory FileUploadModel.fromMap(Map<String, dynamic> map) {
    return FileUploadModel(
      fileInfo: FileInfo.fromMap(map['fileInfo']),
      name: map['name'],
      path: map['path'],
      source: map['source'] != null ? FileSource.values[map['source']] : null,
      status: map['status'] != null ? UploadStatus.values[map['status']] : null,
      progress: map['progress']?.toDouble() ?? 0,
      fileSize: map['fileSize'],
      fileSizeInfo: map['fileSizeInfo'],
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'fileInfo': fileInfo.toMap(),
      'name': name,
      'path': path,
      'source': source?.index,
      'status': status?.index,
      'progress': progress,
      'fileSize': fileSize,
      'fileSizeInfo': fileSizeInfo,
    };
  }
}
