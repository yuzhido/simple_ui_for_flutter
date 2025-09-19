import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:simple_ui/models/file_upload.dart';

/// 文件选择工具类
class FilePickerUtils {
  /// 获取图片路径 - 直接使用path字段，path如果是http开头就是网络图片，否则是本地图片
  static String _getImagePath(FileUploadModel fileModel) {
    // 调试信息
    print('🔍 _getImagePath 调试信息:');
    print('   文件名: ${fileModel.name}');
    print('   状态: ${fileModel.status}');
    print('   path字段: ${fileModel.path}');
    print('   requestPath字段: ${fileModel.fileInfo?.requestPath}');
    print('   path是否以http开头: ${fileModel.path.startsWith('http')}');

    // 直接使用path字段，无论是网络URL还是本地路径
    final resultPath = fileModel.path;
    print('   ✅ 最终返回路径: $resultPath');
    print('   ✅ 最终返回路径: $resultPath');
    print('   ✅ 最终返回路径: $resultPath');
    print('   ✅ 最终返回路径: $resultPath');
    print('   🌐 路径类型: ${resultPath.startsWith('http') ? '网络URL' : '本地路径'}');
    return resultPath;
  }

  /// 选择文件
  static Future<void> pickFile({Function(FileUploadModel)? onFileSelected}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        if (file.path != null && file.name.isNotEmpty && onFileSelected != null) {
          // 封装成FileUploadModel并调用回调
          FileUploadModel fileUploadModel = _createFileUploadModel(
            fileName: file.name,
            filePath: file.path!,
            source: FileSource.file,
            fileSize: file.size,
            fileSizeInfo: _formatFileSize(file.size),
          );
          onFileSelected(fileUploadModel);
        }

        print('=== 选择的文件信息 ===');
        print('文件名: ${file.name}');
        print('文件大小: ${_formatFileSize(file.size)}');
        print('文件路径: ${file.path}');
        print('文件扩展名: ${file.extension}');
        print('MIME类型: ${file.extension != null ? _getMimeType(file.extension!) : '未知'}');
        print('==================');
      } else {
        print('用户取消了文件选择');
      }
    } catch (e) {
      print('选择文件时发生错误: $e');
    }
  }

  /// 从相册选择图片
  static Future<void> pickImageFromGallery({Function(FileUploadModel)? onFileSelected}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);

      if (image != null) {
        File imageFile = File(image.path);
        int fileSize = await imageFile.length();

        if (onFileSelected != null && image.path.isNotEmpty) {
          // 生成合适的文件名
          String fileName = image.name.isNotEmpty ? image.name : 'gallery_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

          // 封装成FileUploadModel并调用回调
          FileUploadModel fileUploadModel = _createFileUploadModel(
            fileName: fileName,
            filePath: image.path,
            source: FileSource.image,
            fileSize: fileSize,
            fileSizeInfo: _formatFileSize(fileSize),
          );
          onFileSelected(fileUploadModel);
        }

        print('=== 从相册选择的图片信息 ===');
        print('文件名: ${image.name}');
        print('文件大小: ${_formatFileSize(fileSize)}');
        print('文件路径: ${image.path}');
        print('MIME类型: ${image.mimeType ?? '未知'}');
        print('========================');
      } else {
        print('用户取消了图片选择');
      }
    } catch (e) {
      print('从相册选择图片时发生错误: $e');
    }
  }

  /// 拍照上传
  static Future<void> pickImageFromCamera({Function(FileUploadModel)? onFileSelected}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 100);

      if (image != null) {
        File imageFile = File(image.path);
        int fileSize = await imageFile.length();

        if (onFileSelected != null && image.path.isNotEmpty) {
          // 生成合适的文件名
          String fileName = image.name.isNotEmpty ? image.name : 'camera_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

          // 封装成FileUploadModel并调用回调
          FileUploadModel fileUploadModel = _createFileUploadModel(
            fileName: fileName,
            filePath: image.path,
            source: FileSource.camera,
            fileSize: fileSize,
            fileSizeInfo: _formatFileSize(fileSize),
          );
          onFileSelected(fileUploadModel);
        }

        print('=== 拍照的图片信息 ===');
        print('文件名: ${image.name}');
        print('文件大小: ${_formatFileSize(fileSize)}');
        print('文件路径: ${image.path}');
        print('MIME类型: ${image.mimeType ?? '未知'}');
        print('==================');
      } else {
        print('用户取消了拍照');
      }
    } catch (e) {
      print('拍照时发生错误: $e');
    }
  }

  /// 格式化文件大小
  static String _formatFileSize(int bytes) {
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

  /// 公开的文件大小格式化方法
  static String formatFileSize(int bytes) {
    return _formatFileSize(bytes);
  }

  /// 判断文件是否为图片
  static bool isImageFile(String? fileName) {
    if (fileName == null) return false;
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg'];
    final lowerFileName = fileName.toLowerCase();
    return imageExtensions.any((ext) => lowerFileName.endsWith(ext));
  }

  /// 构建图片预览组件
  static Widget buildImagePreview(String? imagePath, {String? fileId}) {
    print('🖼️ buildImagePreview 调试信息:');
    print('   图片路径: $imagePath');
    print('   文件ID: $fileId');

    if (imagePath == null) {
      print('   ❌ 图片路径为空');
      return Icon(Icons.image, color: Colors.grey.shade400, size: 40);
    }

    // 判断是否为网络URL
    final isNetworkUrl = imagePath.startsWith('http://') || imagePath.startsWith('https://');
    print('   🌐 是否为网络URL: $isNetworkUrl');

    // 创建唯一的Key，用于Widget识别
    final imageKey = Key('image_${fileId ?? imagePath.hashCode}');

    if (isNetworkUrl) {
      // 网络图片
      print('   📡 开始加载网络图片: $imagePath');
      return Image.network(
        imagePath,
        key: imageKey,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        cacheWidth: 300, // 限制解码宽度，提升性能
        cacheHeight: 300, // 限制解码高度，提升性能
        // 添加缓存控制，避免重复加载
        headers: const {
          'Cache-Control': 'max-age=3600', // 缓存1小时
        },
        errorBuilder: (context, error, stackTrace) {
          print('   ❌ 网络图片加载失败: $error');
          print('   📍 错误堆栈: $stackTrace');
          return Icon(Icons.broken_image, color: Colors.grey.shade400, size: 40);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            print('   ✅ 网络图片加载完成: $imagePath');
            return child;
          }
          final progress = loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null;
          print('   ⏳ 网络图片加载中: ${(progress ?? 0) * 100}%');
          return Center(child: CircularProgressIndicator(value: progress));
        },
      );
    } else {
      // 本地文件
      print('   📁 开始加载本地文件: $imagePath');
      return Image.file(
        File(imagePath),
        key: imageKey,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        cacheWidth: 300, // 限制解码宽度，大幅提升大图片预览性能
        cacheHeight: 300, // 限制解码高度，减少内存占用
        errorBuilder: (context, error, stackTrace) {
          print('   ❌ 本地图片加载失败: $error');
          print('   📍 错误堆栈: $stackTrace');
          return Icon(Icons.broken_image, color: Colors.grey.shade400, size: 40);
        },
      );
    }
  }

  /// 构建状态指示器
  static Widget buildStatusIndicator(UploadStatus? status, double progress) {
    switch (status) {
      case UploadStatus.pending:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule, color: Colors.orange.shade600, size: 12),
              const SizedBox(width: 2),
              Text('待上传', style: TextStyle(color: Colors.orange.shade600, fontSize: 10)),
            ],
          ),
        );
      case UploadStatus.uploading:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2, value: progress, color: Colors.blue.shade600),
              ),
              const SizedBox(width: 4),
              Text('${(progress * 100).toInt()}%', style: TextStyle(color: Colors.blue.shade600, fontSize: 10)),
            ],
          ),
        );
      case UploadStatus.success:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 12),
              const SizedBox(width: 2),
              Text('已上传', style: TextStyle(color: Colors.green.shade600, fontSize: 10)),
            ],
          ),
        );
      case UploadStatus.failed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, color: Colors.red.shade600, size: 12),
              const SizedBox(width: 2),
              Text('失败', style: TextStyle(color: Colors.red.shade600, fontSize: 10)),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// 构建卡片模式的文件项
  static Widget buildCardFileItem(FileUploadModel fileModel, int index, double width, Function(int) onRemove) {
    final isImage = isImageFile(fileModel.name);

    return Container(
      width: width,
      height: width,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          // 文件内容
          Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 文件预览或图标
                if (isImage && _getImagePath(fileModel).isNotEmpty)
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: buildImagePreview(_getImagePath(fileModel), fileId: fileModel.id),
                        ),
                        // 上传中的遮罩层
                        if (fileModel.status == UploadStatus.uploading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
                              child: Center(
                                child: CircularProgressIndicator(value: fileModel.progress, color: Colors.white, strokeWidth: 3),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  Stack(
                    children: [
                      Icon(Icons.insert_drive_file, color: Colors.blue.shade600, size: 40),
                      // 上传中的进度指示器
                      if (fileModel.status == UploadStatus.uploading)
                        Positioned.fill(
                          child: Center(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(value: fileModel.progress, color: Colors.blue.shade600, strokeWidth: 3),
                            ),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 4),
                // 文件名
                Text(
                  fileModel.name.length > 10 ? '${fileModel.name.substring(0, 10)}...' : fileModel.name,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 10, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // 文件大小
                if (fileModel.fileSizeInfo != null)
                  Text(
                    fileModel.fileSizeInfo!,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          // 状态指示器
          Positioned(top: 4, left: 4, child: buildStatusIndicator(fileModel.status, fileModel.progress)),
          // 删除按钮
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => onRemove(index),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: Colors.red.shade400, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建文本信息模式的文件项
  static Widget buildTextInfoFileItem(FileUploadModel fileModel, int index, Function(int) onRemove) {
    final isImage = isImageFile(fileModel.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // 文件图标或小预览图
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
            child: Stack(
              children: [
                if (isImage && _getImagePath(fileModel).isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: buildImagePreview(_getImagePath(fileModel), fileId: fileModel.id),
                  )
                else
                  Icon(Icons.insert_drive_file, color: Colors.blue.shade600, size: 24),
                // 上传中的进度指示器
                if (fileModel.status == UploadStatus.uploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(4)),
                      child: Center(
                        child: CircularProgressIndicator(value: fileModel.progress, color: Colors.white, strokeWidth: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 文件信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileModel.name,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // 状态指示器
                    buildStatusIndicator(fileModel.status, fileModel.progress),
                    const SizedBox(width: 8),
                    if (fileModel.fileSizeInfo != null) Text(fileModel.fileSizeInfo!, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
                // 上传进度条（线性）
                if (fileModel.status == UploadStatus.uploading)
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: fileModel.progress,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                        minHeight: 3,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('上传中...', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                          Text('${((fileModel.progress) * 100).toInt()}%', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // 删除按钮
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
            onPressed: () => onRemove(index),
          ),
        ],
      ),
    );
  }

  /// 根据文件扩展名获取MIME类型
  static String _getMimeType(String extension) {
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

  /// 创建FileUploadModel实例
  static FileUploadModel _createFileUploadModel({required String fileName, required String filePath, FileSource? source, int? fileSize, String? fileSizeInfo}) {
    // 参数验证
    assert(fileName.isNotEmpty, 'fileName不能为空');
    assert(filePath.isNotEmpty, 'filePath不能为空');

    // 生成唯一ID（String类型用于FileUploadModel）
    String modelId = _generateRandomId();

    // 生成int类型的ID用于FileInfo
    int fileInfoId = _generateRandomIntId();

    // 创建FileInfo
    FileInfo fileInfo = FileInfo(id: fileInfoId, fileName: fileName, requestPath: filePath);

    // 创建FileUploadModel，传递String类型的id
    return FileUploadModel(
      id: modelId, // 传递生成的String类型id
      fileInfo: fileInfo,
      name: fileName,
      path: filePath,
      source: source,
      fileSize: fileSize,
      fileSizeInfo: fileSizeInfo,
      status: UploadStatus.pending,
      progress: 0.0,
    );
  }

  /// 生成随机ID（返回String类型）
  static String _generateRandomId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(999999);
    return '${timestamp}_$randomNum';
  }

  /// 生成随机ID（返回int类型）
  static int _generateRandomIntId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(999999);
    return int.parse('$timestamp$randomNum'.substring(0, 15));
  }
}
