import 'package:example/utils/compress_image.dart';
import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NewFileUploadPage extends StatefulWidget {
  const NewFileUploadPage({super.key});
  @override
  State<NewFileUploadPage> createState() => _NewFileUploadPageState();
}

class _NewFileUploadPageState extends State<NewFileUploadPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isCompressing = false;
  String _compressionStatus = '';

  /// 图片压缩上传函数
  Future<Map<String, dynamic>> _compressAndUploadFunction(String filePath, Function(double) onProgress) async {
    print('🖼️ 开始图片压缩上传: $filePath');
    try {
      setState(() {
        _isCompressing = true;
        _compressionStatus = '正在压缩图片...';
      });
      // 检查是否为图片文件
      final isImage = _isImageFile(filePath);
      String finalFilePath = filePath;

      if (isImage) {
        // 获取原始文件信息
        final originalFile = File(filePath);
        final originalSize = await originalFile.length();
        print('📊 原始文件大小: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB');

        // 根据文件大小选择压缩配置
        final compressConfig = ImageCompressUtil.smartConfig(originalSize);

        // 执行图片压缩
        final compressResult = await ImageCompressUtil.compressImage(filePath, config: compressConfig);

        if (compressResult.success) {
          finalFilePath = compressResult.filePath;
          print('✅ 压缩成功！');
          print('📊 压缩后大小: ${(compressResult.compressedSize / 1024 / 1024).toStringAsFixed(2)} MB');
          print('📊 压缩比例: ${(compressResult.compressionRatio * 100).toStringAsFixed(1)}%');

          setState(() {
            _compressionStatus = '压缩完成，节省 ${(compressResult.compressionRatio * 100).toStringAsFixed(1)}% 空间';
          });
        } else {
          print('❌ 压缩失败: ${compressResult.error}');
          setState(() {
            _compressionStatus = '压缩失败，使用原文件上传';
          });
        }
      } else {
        setState(() {
          _compressionStatus = '非图片文件，直接上传';
        });
      }

      setState(() {
        _compressionStatus = '开始上传...';
      });
      // 获取原始文件信息
      final currentFile = File(finalFilePath);
      final currentFileSize = await currentFile.length();
      print('📊 压缩后文件大小: ${(currentFileSize / 1024 / 1024).toStringAsFixed(2)} MB');
      print('📊 压缩后文件大小: ${(currentFileSize / 1024 / 1024).toStringAsFixed(2)} MB');
      print('📊 压缩后文件大小: ${(currentFileSize / 1024 / 1024).toStringAsFixed(2)} MB');
      print('📊 压缩后文件大小: ${(currentFileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      // 执行上传
      final dio = Dio();
      final formData = FormData();
      final fileName = finalFilePath.split('/').last.split('\\').last;

      formData.files.add(MapEntry('file', await MultipartFile.fromFile(finalFilePath, filename: fileName)));

      final response = await dio.request(
        'http://192.168.1.19:3001/upload/api/upload-file',
        data: formData,
        options: Options(method: 'POST'),
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = sent / total;
            onProgress(progress);
            print('📤 上传进度: ${(progress * 100).toInt()}%');
          }
        },
      );

      final isSuccess = response.statusCode == 200;

      setState(() {
        _isCompressing = false;
        _compressionStatus = isSuccess ? '上传成功！' : '上传失败';
      });

      if (isSuccess) {
        print('✅ 压缩上传成功！');
        return {
          'success': true,
          'message': '压缩上传成功',
          'fileUrl': 'https://example.com/uploaded/${fileName}',
          'fileId': 'compressed_${DateTime.now().millisecondsSinceEpoch}',
          'response': response.data,
        };
      } else {
        throw Exception('上传失败：HTTP状态码 ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isCompressing = false;
        _compressionStatus = '操作失败: $e';
      });
      print('❌ 压缩上传异常: $e');
      throw Exception('压缩上传失败: $e');
    }
  }

  /// 判断是否为图片文件
  bool _isImageFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  /// 从相册选择图片并压缩上传
  Future<void> _pickAndCompressImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // 选择原始质量，后续我们自己压缩
      );

      if (image != null) {
        print('📱 选择了图片: ${image.path}');
        // 这里可以触发文件上传组件的逻辑
        // 或者直接调用压缩上传函数进行测试
      }
    } catch (e) {
      print('❌ 选择图片失败: $e');
    }
  }

  /// 自定义上传函数示例
  Future<Map<String, dynamic>> _customUploadFunction(String filePath, Function(double) onProgress) async {
    print('🚀 开始自定义上传文件: $filePath');

    try {
      final dio = Dio();

      // 准备表单数据
      final formData = FormData();

      // 获取文件名
      final fileName = filePath.split('/').last.split('\\').last;

      // 添加文件 - 使用正确的字段名
      formData.files.add(MapEntry('file', await MultipartFile.fromFile(filePath, filename: fileName)));

      // 发送请求
      final response = await dio.request(
        'http://192.168.1.19:3001/upload/api/upload-file',
        data: formData,
        options: Options(method: 'POST'),
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = sent / total;
            // 调用传入的进度回调函数
            onProgress(progress);
            print('📊 自定义上传进度: ${(progress * 100).toInt()}%');
          }
        },
      );

      final isSuccess = response.statusCode == 200;
      print('📤 上传响应状态: ${response.statusCode}');
      print('📤 上传响应数据: ${response.data}');

      if (isSuccess) {
        print('✅ 自定义上传成功！');
        return {
          'success': true,
          'message': '自定义上传成功',
          'fileUrl': 'https://example.com/uploaded/${fileName}',
          'fileId': 'custom_${DateTime.now().millisecondsSinceEpoch}',
          'response': response.data,
        };
      } else {
        throw Exception('自定义上传失败：HTTP状态码 ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 自定义上传异常: $e');
      throw Exception('自定义上传失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导航栏标题')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 压缩状态显示
            if (_compressionStatus.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _isCompressing ? Colors.blue.shade50 : Colors.green.shade50,
                  border: Border.all(color: _isCompressing ? Colors.blue : Colors.green, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    if (_isCompressing)
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_compressionStatus, style: TextStyle(color: _isCompressing ? Colors.blue.shade700 : Colors.green.shade700, fontSize: 14)),
                    ),
                  ],
                ),
              ),

            // 图片压缩上传示例
            const Text('图片压缩上传示例：', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('自动检测图片文件并进行智能压缩，根据文件大小选择合适的压缩配置', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),

            FileUpload(
              fileListType: FileListType.textInfo,
              uploadConfig: UploadConfig(customUpload: _compressAndUploadFunction),
              onUploadSuccess: (file) {
                print('✅ 图片压缩上传 - 文件 ${file.name} 上传成功！');
                setState(() {
                  _compressionStatus = '✅ ${file.name} 压缩上传成功！';
                });
              },
              onUploadFailed: (file, error) {
                print('❌ 图片压缩上传 - 文件 ${file.name} 上传失败: $error');
                setState(() {
                  _compressionStatus = '❌ ${file.name} 压缩上传失败: $error';
                });
              },
              onUploadProgress: (file, progress) {
                print('📤 图片压缩上传 - 文件 ${file.name} 上传进度: ${(progress * 100).toInt()}%');
              },
              onFileChange: (currentFile, selectedFiles, action) {
                print('222222222222222222✅✅✅✅✅✅✅✅22222222222222222222222');
                print('222222222222222222✅✅✅✅✅✅✅✅22222222222222222222222');
                print('222222222222222222✅✅✅✅✅✅✅✅22222222222222222222222');
                print(currentFile.fileSizeInfo);
                print('222222222222222222✅✅✅✅✅✅✅✅22222222222222222222222');
                print('222222222222222222✅✅✅✅✅✅✅✅22222222222222222222222');
                print('222222222222222222✅✅✅✅✅✅✅✅22222222222222222222222');
                print('图片压缩上传模式 - 操作: $action, 文件: ${currentFile.name}');
                if (action == 'add') {
                  setState(() {
                    _compressionStatus = '准备压缩 ${currentFile.name}...';
                  });
                }
              },
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // 手动选择图片按钮
            Center(
              child: ElevatedButton.icon(
                onPressed: _pickAndCompressImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('从相册选择图片'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // 默认文件列表示例
            const Text('默认文件列表示例：', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('展示已上传成功的默认文件列表，可以继续添加新文件', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),

            FileUpload(
              fileListType: FileListType.textInfo,
              defaultValue: [
                FileUploadModel(
                  fileInfo: FileInfo(id: 'default_1', fileName: 'default_image_1.jpg', requestPath: '/uploads/file-1758210644301-129721823.jpg'),
                  name: 'default_image_1.jpg',
                  path: 'http://192.168.1.19:3001/uploads/file-1758210644301-129721823.jpg',
                ),
                FileUploadModel(
                  fileInfo: FileInfo(id: 'default_2', fileName: 'document.pdf', requestPath: 'http://192.168.8.188:3000/uploads/document-123456789.pdf'),
                  name: 'document.pdf',
                  path: 'http://192.168.8.188:3000/uploads/document-123456789.pdf',
                  status: UploadStatus.success,
                  progress: 1.0,
                  fileSize: 2048000,
                  fileSizeInfo: '2.0 MB',
                ),
                FileUploadModel(
                  fileInfo: FileInfo(id: 'default_3', fileName: 'presentation.pptx', requestPath: 'http://192.168.8.188:3000/uploads/presentation-987654321.pptx'),
                  name: 'presentation.pptx',
                  path: 'http://192.168.8.188:3000/uploads/presentation-987654321.pptx',
                  status: UploadStatus.success,
                  progress: 1.0,
                  fileSize: 5120000,
                  fileSizeInfo: '5.0 MB',
                ),
              ],
              uploadConfig: UploadConfig(uploadUrl: 'http://192.168.1.19:3001/upload/api/upload-file', headers: {'Authorization': 'Bearer token123'}),
              onUploadSuccess: (file) {
                print('✅ 默认文件列表示例 - 文件 ${file.name} 上传成功！');
              },
              onUploadFailed: (file, error) {
                print('❌ 默认文件列表示例 - 文件 ${file.name} 上传失败: $error');
              },
              onUploadProgress: (file, progress) {
                print('📤 默认文件列表示例 - 文件 ${file.name} 上传进度: ${(progress * 100).toInt()}%');
              },
              onFileChange: (currentFile, selectedFiles, action) {
                print('默认文件列表示例 - 操作: $action, 文件: ${currentFile.name}, 总文件数: ${selectedFiles.length}');
              },
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // 卡片模式的默认文件列表示例
            const Text('卡片模式默认文件列表示例：', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('卡片模式展示默认文件，支持图片预览', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),

            FileUpload(
              fileListType: FileListType.card,
              limit: 5,
              defaultValue: [
                FileUploadModel(
                  fileInfo: FileInfo(id: 'card_default_1', fileName: 'avatar.jpg', requestPath: 'http://192.168.8.188:3000/uploads/file-1758090930654-314645519.jpeg'),
                  name: 'avatar.jpg',
                  path: 'http://192.168.8.188:3000/uploads/file-1758090930654-314645519.jpeg',
                  status: UploadStatus.success,
                  progress: 1.0,
                  fileSize: 512000,
                  fileSizeInfo: '512 KB',
                ),
                FileUploadModel(
                  fileInfo: FileInfo(id: 'card_default_2', fileName: 'banner.png', requestPath: 'http://192.168.8.188:3000/uploads/file-1758090930654-314645519.jpeg'),
                  name: 'banner.png',
                  path: 'http://192.168.8.188:3000/uploads/file-1758090930654-314645519.jpeg',
                  status: UploadStatus.success,
                  progress: 1.0,
                  fileSize: 1536000,
                  fileSizeInfo: '1.5 MB',
                ),
              ],
              uploadConfig: UploadConfig(uploadUrl: 'http://192.168.1.19:3001/upload/api/upload-file', headers: {'Authorization': 'Bearer token123'}),
              fileSource: FileSource.imageOrCamera,
              onUploadSuccess: (file) {
                print('✅ 卡片模式默认文件列表 - 文件 ${file.name} 上传成功！');
              },
              onUploadFailed: (file, error) {
                print('❌ 卡片模式默认文件列表 - 文件 ${file.name} 上传失败: $error');
              },
              onUploadProgress: (file, progress) {
                print('📤 卡片模式默认文件列表 - 文件 ${file.name} 上传进度: ${(progress * 100).toInt()}%');
              },
              onFileChange: (currentFile, selectedFiles, action) {
                print('卡片模式默认文件列表 - 操作: $action, 文件: ${currentFile.name}, 总文件数: ${selectedFiles.length}');
              },
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // 原有的上传组件
            const Text('普通文件上传示例：', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            FileUpload(
              fileListType: FileListType.textInfo,

              uploadConfig: UploadConfig(uploadUrl: 'http://192.168.1.19:3001/upload/api/upload-file', headers: {'Authorization': 'Bearer token123'}),
              onUploadSuccess: (file) {
                print('✅ 文件 ${file.name} 上传成功！');
              },
              onUploadFailed: (file, error) {
                print('❌ 文件 ${file.name} 上传失败: $error');
              },
              onUploadProgress: (file, progress) {
                print('📤 文件 ${file.name} 上传进度: ${(progress * 100).toInt()}%');
              },
              onFileChange: (currentFile, selectedFiles, action) {
                print('自动上传模式 - 操作: $action, 文件: ${currentFile.name}');
              },
            ),
            const Text('页面内容正在开发中...'),
            FileUpload(
              uploadConfig: UploadConfig(uploadUrl: 'http://192.168.1.19:3001/upload/api/upload-file', headers: {'Authorization': 'Bearer token123'}),
              onUploadSuccess: (file) {
                print('✅ 文件 ${file.name} 上传成功！');
              },
              onUploadFailed: (file, error) {
                print('❌ 文件 ${file.name} 上传失败: $error');
              },
              onUploadProgress: (file, progress) {
                print('📤 文件 ${file.name} 上传进度: ${(progress * 100).toInt()}%');
              },
              onFileChange: (currentFile, selectedFiles, action) {
                print('自动上传模式 - 操作: $action, 文件: ${currentFile.name}');
              },
            ),
            const SizedBox(height: 20),
            const Text('自定义上传函数示例：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            FileUpload(
              fileListType: FileListType.textInfo,
              uploadConfig: UploadConfig(customUpload: _customUploadFunction),
              onUploadSuccess: (file) {
                print('✅ 自定义上传 - 文件 ${file.name} 上传成功！');
              },
              onUploadFailed: (file, error) {
                print('❌ 自定义上传 - 文件 ${file.name} 上传失败: $error');
              },
              onUploadProgress: (file, progress) {
                print('📤 自定义上传 - 文件 ${file.name} 上传进度: ${(progress * 100).toInt()}%');
              },
              onFileChange: (currentFile, selectedFiles, action) {
                print('自定义上传模式 - 操作: $action, 文件: ${currentFile.name}');
              },
            ),
            FileUpload(
              isRemoveFailFile: true,
              uploadConfig: UploadConfig(customUpload: _customUploadFunction),
              onUploadSuccess: (file) {
                print('✅ 自定义上传 - 文件 ${file.name} 上传成功！');
              },
              onUploadFailed: (file, error) {
                print('❌ 自定义上传 - 文件 ${file.name} 上传失败: $error');
              },
              onUploadProgress: (file, progress) {
                print('📤 自定义上传 - 文件 ${file.name} 上传进度: ${(progress * 100).toInt()}%');
              },
              onFileChange: (currentFile, selectedFiles, action) {
                print(currentFile.fileSizeInfo);
                print('自定义上传模式 - 操作: $action, 文件: ${currentFile.name}');
                print('222222222222222222✅✅✅✅✅✅✅✅22222222222222222222222');
                print('222222222222222222✅✅✅✅✅✅✅✅22222222222222222222222');
                print(selectedFiles);
                print('222222222222222222✅✅✅✅✅✅✅✅22222222222222222222222');
                print('222222222222222222✅✅✅✅✅✅✅✅22222222222222222222222');
              },
            ),

            const SizedBox(height: 32),
            const Text('自定义图标和文本示例：', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('演示如何自定义上传区域的图标和文本', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),

            FileUpload(
              fileListType: FileListType.card,
              uploadIcon: const Icon(Icons.cloud_upload, size: 48, color: Colors.blue),
              uploadText: const Text('点击上传文档', style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.w500)),
              uploadConfig: UploadConfig(customUpload: _customUploadFunction),
              onUploadSuccess: (file) {
                print('✅ 自定义图标文本上传 - 文件 ${file.name} 上传成功！');
              },
              onUploadFailed: (file, error) {
                print('❌ 自定义图标文本上传 - 文件 ${file.name} 上传失败: $error');
              },
              onUploadProgress: (file, progress) {
                print('📤 自定义图标文本上传 - 文件 ${file.name} 上传进度: ${(progress * 100).toInt()}%');
              },
              onFileChange: (currentFile, selectedFiles, action) {
                print('自定义图标文本上传模式 - 操作: $action, 文件: ${currentFile.name}');
              },
            ),
          ],
        ),
      ),
    );
  }
}
