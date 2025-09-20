import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_ui/models/file_upload.dart';
import 'package:simple_ui/src/file_upload/image_show/file_image_show.dart';
import 'package:simple_ui/src/file_upload/image_show/network_image_show.dart';
import 'package:simple_ui/src/file_upload/upload_status/pending_status.dart';
import 'package:simple_ui/src/file_upload/upload_status/upload_failed.dart';
import 'package:simple_ui/src/file_upload/upload_status/upload_success.dart';
import 'package:simple_ui/src/file_upload/upload_status/uploading_status.dart';

/// 文件大小获取
String formatFileSize(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  } else if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(2)} KB';
  } else if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  } else {
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

///判断是否是图片
bool isImageFile(String? fileName) {
  if (fileName == null) return false;
  final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg'];
  final lowerFileName = fileName.toLowerCase();
  return imageExtensions.any((ext) => lowerFileName.endsWith(ext));
}

/// 构建状态指示器
Widget buildStatusIndicator(UploadStatus? status, double progress) {
  switch (status) {
    case UploadStatus.pending:
      return const PendingStatus();
    case UploadStatus.uploading:
      return UploadingStatus(progress);
    case UploadStatus.success:
      return const UploadSuccess();
    case UploadStatus.failed:
      return UploadFailed();
    default:
      return const SizedBox.shrink();
  }
}

/// 根据文件扩展名获取MIME类型
String getMimeType(String extension) {
  switch (extension.toLowerCase()) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'gif':
      return 'image/gif';
    case 'pdf':
      return 'application/pdf';
    case 'doc':
      return 'application/msword';
    case 'docx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    case 'txt':
      return 'text/plain';
    case 'mp4':
      return 'video/mp4';
    case 'mp3':
      return 'audio/mpeg';
    default:
      return 'application/octet-stream';
  }
}

/// 构建图片预览组件
Widget buildImagePreview(FileUploadModel fileModel) {
  String imagePath = '';
  if (fileModel.path.isNotEmpty) {
    imagePath = fileModel.path;
  } else if (fileModel.url?.isNotEmpty == true) {
    imagePath = fileModel.url!;
  }

  if (imagePath.isEmpty) {
    debugPrint('❌ 图片路径为空');
    return Icon(Icons.image, color: Colors.grey.shade400, size: 40);
  }
  // 判断是否为网络URL
  final isNetworkUrl = imagePath.startsWith('http://') || imagePath.startsWith('https://');

  debugPrint('🖼️ 构建图片预览调试信息开始================================================>:');
  debugPrint('📄 图片本地路径: ${fileModel.path}');
  debugPrint('📄 图片Url路径: ${fileModel.url}');
  debugPrint('📄 图片Id: ${fileModel.id}');
  debugPrint('🌐 是否为网络URL: $isNetworkUrl');
  debugPrint('🖼️ 构建图片预览调试信息结束<================================================:');

  if (isNetworkUrl) {
    // 网络图片
    return NetworkImageShow(imagePath, fileModel.id);
  } else {
    // 本地文件
    return FileImageShow(imagePath, fileModel.id);
  }
}

/// 生成随机ID（返回String类型）
String generateRandomId() {
  final random = Random();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final randomNum = random.nextInt(999999);
  return '${timestamp}_$randomNum';
}

/// 生成随机ID（返回int类型）
int generateRandomIntId() {
  final random = Random();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final randomNum = random.nextInt(999999);
  return int.parse('$timestamp$randomNum'.substring(0, 15));
}

/// 创建FileUploadModel实例
FileUploadModel createFileUploadModel({required String fileName, required String filePath, FileSource source = FileSource.network, int? fileSize, String? fileSizeInfo}) {
  // 参数验证
  assert(fileName.isNotEmpty, 'fileName不能为空');
  assert(filePath.isNotEmpty, 'filePath不能为空');

  // 生成唯一ID（String类型用于FileUploadModel）
  String modelId = generateRandomId();

  // 创建FileUploadModel，传递String类型的id
  return FileUploadModel(
    id: modelId, // 传递生成的String类型id
    name: fileName,
    path: filePath,
    source: source,
    fileSize: fileSize,
    fileSizeInfo: fileSizeInfo,
    status: UploadStatus.pending,
    progress: 0.0,
  );
}
