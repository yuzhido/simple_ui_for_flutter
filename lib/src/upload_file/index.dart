import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';

enum UploadListType {
  button, // 默认按钮样式
  card, // 卡片样式 - 小巧紧凑的卡片
  custom, // 自定义样式
}

enum UploadStatus {
  uploading, // 上传中
  success, // 上传成功
  failed, // 上传失败
}

enum FileSource {
  all, // 允许所有类型：文件、图片、拍照
  file, // 只允许选择文件
  image, // 只允许选择图片
  camera, // 只允许拍照
  imageOrCamera, // 只允许选择图片或拍照
}

// 上传配置类
class UploadConfig {
  final String uploadUrl; // 上传接口地址
  final Map<String, String> headers; // 请求头
  final String? fileFieldName; // 文件字段名，默认为 'file'
  final Map<String, String>? additionalFields; // 额外的表单字段
  final Function(Map<String, dynamic>)? onUploadSuccess; // 上传成功回调
  final Function(String)? onUploadError; // 上传失败回调
  final Function(double)? onUploadProgress; // 上传进度回调
  final Duration timeout; // 请求超时时间

  const UploadConfig({
    required this.uploadUrl,
    this.headers = const {},
    this.fileFieldName = 'file',
    this.additionalFields,
    this.onUploadSuccess,
    this.onUploadError,
    this.onUploadProgress,
    this.timeout = const Duration(seconds: 60),
  });
}

// 上传响应结果类
class UploadResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;
  final String? fileUrl;
  final String? fileName;

  const UploadResponse({required this.success, this.message, this.data, this.fileUrl, this.fileName});
}

class UploadFile extends StatefulWidget {
  final UploadListType listType;
  final Widget? customUploadArea;
  final double? uploadAreaSize; // 卡片尺寸（正方形）
  final Color? borderColor;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final IconData? uploadIcon;
  final double? iconSize;
  final Color? iconColor;
  final String? uploadText;
  final TextStyle? textStyle;
  final List<Map<String, dynamic>> initialFiles; // 包含文件名和状态的文件列表
  final Function(List<Map<String, dynamic>>)? onFilesChanged;
  final bool showFileList;
  final Widget? Function(Map<String, dynamic>)? customFileItemBuilder;
  final double? fileItemSize; // 文件项尺寸（正方形）
  final int limit; // 文件数量限制，-1表示无限制
  final FileSource fileSource; // 文件来源控制
  final Function(PlatformFile)? onFileSelected; // 文件选择回调
  final Function(XFile)? onImageSelected; // 图片选择回调
  final UploadConfig? uploadConfig; // 上传配置
  final bool autoUpload; // 是否自动上传，默认为true

  const UploadFile({
    super.key,
    this.listType = UploadListType.button,
    this.customUploadArea,
    this.uploadAreaSize = 120, // 默认120x120的卡片
    this.borderColor,
    this.backgroundColor,
    this.borderRadius,
    this.uploadIcon,
    this.iconSize,
    this.iconColor,
    this.uploadText,
    this.textStyle,
    this.initialFiles = const [],
    this.onFilesChanged,
    this.showFileList = true,
    this.customFileItemBuilder,
    this.fileItemSize = 120, // 默认120x120的文件项
    this.limit = -1, // 默认无限制
    this.fileSource = FileSource.all, // 默认允许所有类型
    this.onFileSelected,
    this.onImageSelected,
    this.uploadConfig,
    this.autoUpload = true, // 默认自动上传
  });

  @override
  State<UploadFile> createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  late List<Map<String, dynamic>> uploadedFiles;

  @override
  void initState() {
    super.initState();
    uploadedFiles = List.from(widget.initialFiles);
  }

  void _addFile(String fileName, {int? fileSize, String? filePath, bool isImage = false, File? file}) {
    // 检查文件数量限制
    if (widget.limit > 0 && uploadedFiles.length >= widget.limit) {
      // 可以在这里添加提示信息，比如显示一个SnackBar
      return;
    }

    final fileIndex = uploadedFiles.length;
    setState(() {
      uploadedFiles.add({
        'fileName': fileName,
        'status': widget.autoUpload && widget.uploadConfig != null ? UploadStatus.uploading : UploadStatus.success,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'fileSize': fileSize ?? 0, // 文件大小（字节）
        'filePath': filePath, // 文件路径（用于图片预览）
        'isImage': isImage, // 是否为图片文件
        'file': file, // 文件对象
        'uploadProgress': 0.0, // 上传进度
      });
    });
    widget.onFilesChanged?.call(uploadedFiles);

    // 如果配置了自动上传，则开始上传
    if (widget.autoUpload && widget.uploadConfig != null && file != null) {
      _uploadFile(file, fileIndex);
    }
  }

  void _removeFile(int index) {
    setState(() {
      uploadedFiles.removeAt(index);
    });
    widget.onFilesChanged?.call(uploadedFiles);
  }

  // 上传文件的核心方法
  Future<void> _uploadFile(File file, int fileIndex) async {
    if (widget.uploadConfig == null) return;

    try {
      final config = widget.uploadConfig!;

      // 创建Dio实例
      final dio = Dio();

      // 设置请求头
      dio.options.headers.addAll(config.headers);

      // 设置超时时间
      dio.options.connectTimeout = config.timeout;
      dio.options.receiveTimeout = config.timeout;
      dio.options.sendTimeout = config.timeout;

      // 准备表单数据
      final formData = FormData.fromMap({
        config.fileFieldName ?? 'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        // 添加额外字段
        if (config.additionalFields != null) ...config.additionalFields!,
      });

      // 发送请求并监听进度
      final response = await dio.post(
        config.uploadUrl,
        data: formData,
        onSendProgress: (sent, total) {
          // 更新上传进度
          final progress = sent / total;
          _updateUploadProgress(fileIndex, progress);

          // 调用进度回调
          config.onUploadProgress?.call(progress);
        },
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        // 上传成功
        final responseData = response.data;
        _updateFileStatus(fileIndex, UploadStatus.success, responseData: responseData);

        // 调用成功回调
        config.onUploadSuccess?.call(responseData);
      } else {
        // 上传失败
        final errorMessage = '上传失败: ${response.statusCode} ${response.statusMessage}';
        _updateFileStatus(fileIndex, UploadStatus.failed, errorMessage: errorMessage);

        // 调用失败回调
        config.onUploadError?.call(errorMessage);
      }
    } on DioException catch (e) {
      // Dio异常处理
      String errorMessage;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = '连接超时';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = '发送超时';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = '接收超时';
          break;
        case DioExceptionType.badResponse:
          errorMessage = '服务器错误: ${e.response?.statusCode}';
          break;
        case DioExceptionType.cancel:
          errorMessage = '请求已取消';
          break;
        case DioExceptionType.connectionError:
          errorMessage = '网络连接错误';
          break;
        default:
          errorMessage = '上传异常: ${e.message}';
      }
      _updateFileStatus(fileIndex, UploadStatus.failed, errorMessage: errorMessage);
      widget.uploadConfig?.onUploadError?.call(errorMessage);
    } catch (e) {
      // 其他异常
      final errorMessage = '上传异常: $e';
      _updateFileStatus(fileIndex, UploadStatus.failed, errorMessage: errorMessage);
      widget.uploadConfig?.onUploadError?.call(errorMessage);
    }
  }

  // 更新上传进度
  void _updateUploadProgress(int index, double progress) {
    if (index >= 0 && index < uploadedFiles.length) {
      setState(() {
        uploadedFiles[index]['uploadProgress'] = progress;
      });
      widget.onFilesChanged?.call(uploadedFiles);
    }
  }

  // 更新文件状态
  void _updateFileStatus(int index, UploadStatus status, {String? errorMessage, Map<String, dynamic>? responseData}) {
    if (index >= 0 && index < uploadedFiles.length) {
      setState(() {
        uploadedFiles[index]['status'] = status;
        if (errorMessage != null) {
          uploadedFiles[index]['errorMessage'] = errorMessage;
        }
        if (responseData != null) {
          uploadedFiles[index]['responseData'] = responseData;
          // 尝试从响应中提取文件URL
          if (responseData['url'] != null) {
            uploadedFiles[index]['fileUrl'] = responseData['url'];
          } else if (responseData['data'] != null && responseData['data']['url'] != null) {
            uploadedFiles[index]['fileUrl'] = responseData['data']['url'];
          }
        }
      });
      widget.onFilesChanged?.call(uploadedFiles);
    }
  }

  void _showFileSourceDialog() {
    if (widget.fileSource == FileSource.file) {
      _pickFile();
    } else if (widget.fileSource == FileSource.image) {
      _pickImage();
    } else if (widget.fileSource == FileSource.camera) {
      _takePhoto();
    } else if (widget.fileSource == FileSource.imageOrCamera) {
      _showImageSourceDialog();
    } else {
      // FileSource.all - 显示所有选项
      _showAllOptionsDialog();
    }
  }

  void _showAllOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择文件来源'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: const Text('选择文件'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickFile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('选择图片'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择图片来源'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('选择图片'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);

      if (result != null && result.files.isNotEmpty) {
        PlatformFile platformFile = result.files.first;
        widget.onFileSelected?.call(platformFile);

        // 判断是否为图片文件
        bool isImage = _isImageFile(platformFile.name);

        // 创建File对象
        File? file;
        if (platformFile.path != null) {
          file = File(platformFile.path!);
        }

        // 添加到文件列表，包含文件大小和图片标识
        _addFile(platformFile.name, fileSize: platformFile.size, isImage: isImage, file: file);
      }
    } catch (e) {
      _showErrorSnackBar('选择文件失败: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1920, maxHeight: 1080, imageQuality: 85);

      if (image != null) {
        widget.onImageSelected?.call(image);

        // 获取图片文件大小
        final File imageFile = File(image.path);
        final int fileSize = await imageFile.length();

        // 添加到文件列表，包含文件大小、路径和图片标识
        _addFile(image.name, fileSize: fileSize, filePath: image.path, isImage: true, file: imageFile);
      }
    } catch (e) {
      _showErrorSnackBar('选择图片失败: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera, maxWidth: 1920, maxHeight: 1080, imageQuality: 85);

      if (photo != null) {
        widget.onImageSelected?.call(photo);

        // 获取拍照文件大小
        final File photoFile = File(photo.path);
        final int fileSize = await photoFile.length();

        // 添加到文件列表，包含文件大小、路径和图片标识
        _addFile(photo.name, fileSize: fileSize, filePath: photo.path, isImage: true, file: photoFile);
      }
    } catch (e) {
      _showErrorSnackBar('拍照失败: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 3)));
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }

  bool _isImageFile(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg', 'ico'].contains(extension);
  }

  Widget _buildUploadArea() {
    // 如果提供了自定义上传区域，直接使用
    if (widget.customUploadArea != null) {
      return widget.customUploadArea!;
    }

    // 根据listType构建不同的上传区域
    switch (widget.listType) {
      case UploadListType.button:
        return _buildButtonStyle();
      case UploadListType.card:
        return _buildCardStyle();
      case UploadListType.custom:
        return _buildCustomStyle();
    }
  }

  Widget _buildButtonStyle() {
    final bool canUpload = widget.limit == -1 || uploadedFiles.length < widget.limit;

    return ElevatedButton.icon(
      onPressed: canUpload
          ? () {
              _showFileSourceDialog();
            }
          : null,
      icon: Icon(widget.uploadIcon ?? Icons.upload_file, size: widget.iconSize ?? 20, color: widget.iconColor ?? Colors.white),
      label: Text(widget.uploadText ?? '上传文件', style: widget.textStyle ?? const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.backgroundColor ?? Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: widget.borderRadius ?? BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildCardStyle() {
    // 使用传入的尺寸，如果没有则使用默认值
    final size = widget.uploadAreaSize ?? 120;
    final bool canUpload = widget.limit == -1 || uploadedFiles.length < widget.limit;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: canUpload ? (widget.backgroundColor ?? Colors.grey.shade50) : Colors.grey.shade200,
        border: Border.all(color: canUpload ? (widget.borderColor ?? Colors.grey.shade300) : Colors.grey.shade400),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: canUpload
            ? () {
                _showFileSourceDialog();
              }
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.uploadIcon ?? Icons.camera_alt_outlined, size: widget.iconSize ?? 32, color: canUpload ? (widget.iconColor ?? Colors.grey.shade500) : Colors.grey.shade400),
            if (widget.uploadText != null) ...[
              const SizedBox(height: 4),
              Text(
                canUpload ? widget.uploadText! : '已达到上限',
                style: widget.textStyle ?? TextStyle(color: canUpload ? Colors.grey.shade600 : Colors.grey.shade500, fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomStyle() {
    // 使用传入的尺寸，如果没有则使用默认值
    final size = widget.uploadAreaSize ?? 120;
    final bool canUpload = widget.limit == -1 || uploadedFiles.length < widget.limit;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: canUpload ? (widget.backgroundColor ?? Colors.grey.shade100) : Colors.grey.shade200,
        border: Border.all(color: canUpload ? (widget.borderColor ?? Colors.grey.shade400) : Colors.grey.shade500, width: 2),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: canUpload
            ? () {
                _showFileSourceDialog();
              }
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.uploadIcon ?? Icons.add_circle_outline, size: widget.iconSize ?? 28, color: canUpload ? (widget.iconColor ?? Colors.grey.shade600) : Colors.grey.shade400),
            if (widget.listType == UploadListType.custom) ...[
              const SizedBox(height: 4),
              Text(
                canUpload ? widget.uploadText! : '已达到上限',
                style: widget.textStyle ?? TextStyle(color: canUpload ? Colors.grey.shade700 : Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(Map<String, dynamic> fileInfo, int index) {
    // 如果提供了自定义文件项构建器，使用它
    if (widget.customFileItemBuilder != null) {
      return widget.customFileItemBuilder!(fileInfo) ?? _buildCardFileItem(fileInfo, index);
    }

    // 根据listType决定文件展示样式
    if (widget.listType == UploadListType.card) {
      return _buildCardFileItem(fileInfo, index);
    } else {
      return _buildListFileItem(fileInfo, index);
    }
  }

  Widget _buildCardFileItem(Map<String, dynamic> fileInfo, int index) {
    final fileName = fileInfo['fileName'] as String;
    final status = fileInfo['status'] as UploadStatus;
    final fileSize = fileInfo['fileSize'] as int? ?? 0;
    final filePath = fileInfo['filePath'] as String?;
    final isImage = fileInfo['isImage'] as bool? ?? false;
    final uploadProgress = fileInfo['uploadProgress'] as double? ?? 0.0;
    final errorMessage = fileInfo['errorMessage'] as String?;

    // 使用传入的尺寸，如果没有则使用默认值
    final size = widget.fileItemSize ?? 120;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Stack(
        children: [
          // 文件内容区域
          Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 文件图标或图片预览
                if (isImage && filePath != null)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.file(
                        File(filePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image, color: Colors.blue.shade600, size: 24);
                        },
                      ),
                    ),
                  )
                else
                  Icon(Icons.insert_drive_file, color: Colors.blue.shade600, size: 24),
                const SizedBox(height: 4),
                // 文件名
                Text(
                  fileName.length > 8 ? '${fileName.substring(0, 8)}...' : fileName,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 10, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 状态指示器
          if (status != UploadStatus.success) ...[
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 状态图标
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: status == UploadStatus.failed ? Colors.red : Colors.white, shape: BoxShape.circle),
                    child: Icon(
                      status == UploadStatus.failed ? Icons.close : Icons.hourglass_empty,
                      color: status == UploadStatus.failed ? Colors.white : Colors.blue.shade600,
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 状态文字
                  Text(
                    status == UploadStatus.failed ? '上传失败' : '上传中',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                  // 上传进度条（仅在上传中时显示）
                  if (status == UploadStatus.uploading) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: size * 0.6,
                      height: 2,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(1)),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: uploadProgress,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(1)),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  // 文件大小或错误信息
                  Text(
                    status == UploadStatus.failed && errorMessage != null
                        ? (errorMessage.length > 10 ? '${errorMessage.substring(0, 10)}...' : errorMessage)
                        : _formatFileSize(fileSize),
                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],

          // 删除按钮
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeFile(index),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle),
                child: Icon(Icons.close, color: Colors.grey.shade700, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListFileItem(Map<String, dynamic> fileInfo, int index) {
    final fileName = fileInfo['fileName'] as String;
    final status = fileInfo['status'] as UploadStatus;
    final fileSize = fileInfo['fileSize'] as int? ?? 0;
    final uploadProgress = fileInfo['uploadProgress'] as double? ?? 0.0;
    final errorMessage = fileInfo['errorMessage'] as String?;

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
          // 状态图标
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: status == UploadStatus.success
                  ? Colors.green.shade100
                  : status == UploadStatus.failed
                  ? Colors.red.shade100
                  : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              status == UploadStatus.success
                  ? Icons.check_circle
                  : status == UploadStatus.failed
                  ? Icons.error
                  : Icons.hourglass_empty,
              color: status == UploadStatus.success
                  ? Colors.green.shade600
                  : status == UploadStatus.failed
                  ? Colors.red.shade600
                  : Colors.blue.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          status == UploadStatus.success
                              ? '上传成功'
                              : status == UploadStatus.failed
                              ? '上传失败'
                              : '上传中...',
                          style: TextStyle(
                            color: status == UploadStatus.success
                                ? Colors.green.shade600
                                : status == UploadStatus.failed
                                ? Colors.red.shade600
                                : Colors.blue.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_formatFileSize(fileSize), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      ],
                    ),
                    // 上传进度条（仅在上传中时显示）
                    if (status == UploadStatus.uploading) ...[
                      const SizedBox(height: 4),
                      Container(
                        width: 200,
                        height: 2,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(1)),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: uploadProgress,
                          child: Container(
                            decoration: BoxDecoration(color: Colors.blue.shade600, borderRadius: BorderRadius.circular(1)),
                          ),
                        ),
                      ),
                    ],
                    // 错误信息（仅在上传失败时显示）
                    if (status == UploadStatus.failed && errorMessage != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red.shade600, fontSize: 10),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
            onPressed: () => _removeFile(index),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 非卡片模式时，上传区域在上方（只有在未达到限制时才显示）
          if (widget.listType != UploadListType.card && (widget.limit == -1 || uploadedFiles.length < widget.limit)) ...[_buildUploadArea(), const SizedBox(height: 16)],
          // 文件列表 - 根据模式决定布局
          if (widget.showFileList)
            widget.listType == UploadListType.card
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      // 计算最优的列数和文件项宽度
                      final screenWidth = constraints.maxWidth;
                      final availableWidth = screenWidth;
                      final minSpacing = 8.0; // 最小间距
                      final maxItemWidth = 220.0; // 最大宽度限制

                      // 强制每行至少3列，计算每列宽度
                      final minColumns = 3;
                      final totalSpacing = (minColumns - 1) * minSpacing;
                      final itemWidth = (availableWidth - totalSpacing) / minColumns;

                      // 如果计算出的宽度超过最大值，则增加列数
                      double finalItemWidth = itemWidth;
                      int finalColumns = minColumns;

                      if (itemWidth > maxItemWidth) {
                        // 计算最多能放多少列（基于最大宽度）
                        final maxColumns = ((availableWidth + minSpacing) / (maxItemWidth + minSpacing)).floor();
                        finalColumns = maxColumns;
                        finalItemWidth = maxItemWidth;
                      }

                      // 计算最终间距
                      final finalSpacing = finalColumns > 1 ? (availableWidth - finalItemWidth * finalColumns) / (finalColumns - 1) : 0;

                      return Wrap(
                        spacing: finalSpacing > 0 ? finalSpacing.toDouble() : minSpacing,
                        runSpacing: 12.0, // 垂直间距
                        children: [
                          // 先显示已上传的文件
                          ...uploadedFiles.asMap().entries.map((entry) {
                            final index = entry.key;
                            final fileInfo = entry.value;
                            return SizedBox(width: finalItemWidth, height: finalItemWidth, child: _buildFileItem(fileInfo, index));
                          }),
                          // 最后显示上传按钮区域（只有在未达到限制时才显示）
                          if (widget.limit == -1 || uploadedFiles.length < widget.limit) SizedBox(width: finalItemWidth, height: finalItemWidth, child: _buildUploadArea()),
                        ],
                      );
                    },
                  )
                : Column(
                    children: uploadedFiles.asMap().entries.map((entry) {
                      final index = entry.key;
                      final fileInfo = entry.value;
                      return _buildFileItem(fileInfo, index);
                    }).toList(),
                  ),
        ],
      ),
    );
  }
}
