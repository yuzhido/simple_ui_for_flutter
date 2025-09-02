import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';

class UploadFilePage extends StatefulWidget {
  const UploadFilePage({super.key});
  @override
  State<UploadFilePage> createState() => _NewUploadFilePageState();
}

class _NewUploadFilePageState extends State<UploadFilePage> {
  List<Map<String, dynamic>> files1 = [];
  List<Map<String, dynamic>> files2 = [];
  List<Map<String, dynamic>> files3 = [];
  List<Map<String, dynamic>> files4 = [];

  @override
  void initState() {
    super.initState();
    // 初始化一些示例文件，展示不同的上传状态
    _initSampleFiles();
  }

  void _initSampleFiles() {
    // 示例1：成功状态的文件
    files1 = [
      {'fileName': 'M.11_全球热爱季.jpg', 'status': UploadStatus.success, 'timestamp': DateTime.now().millisecondsSinceEpoch, 'fileSize': 2048576, 'isImage': true},
      {'fileName': '产品宣传图.png', 'status': UploadStatus.failed, 'timestamp': DateTime.now().millisecondsSinceEpoch, 'fileSize': 1536000, 'isImage': true},
    ];

    // 示例2：混合状态的文件
    files2 = [
      {'fileName': 'M.11_全球热爱季.jpg', 'status': UploadStatus.success, 'timestamp': DateTime.now().millisecondsSinceEpoch, 'fileSize': 2048576, 'isImage': true},
      {'fileName': '上传失败文件.txt', 'status': UploadStatus.failed, 'timestamp': DateTime.now().millisecondsSinceEpoch, 'fileSize': 51200, 'isImage': false},
      {'fileName': '正在上传.pdf', 'status': UploadStatus.uploading, 'timestamp': DateTime.now().millisecondsSinceEpoch, 'fileSize': 1048576, 'isImage': false},
    ];

    // 示例3：自定义样式的文件
    files3 = [
      {'fileName': '绿色主题文件.jpg', 'status': UploadStatus.success, 'timestamp': DateTime.now().millisecondsSinceEpoch, 'fileSize': 3072000, 'isImage': true},
    ];

    // 示例4：完全自定义的文件
    files4 = [
      {'fileName': '自定义样式文件.txt', 'status': UploadStatus.success, 'timestamp': DateTime.now().millisecondsSinceEpoch, 'fileSize': 25600, 'isImage': false},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文件上传组件示例'), backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              '文件上传组件 - 完整功能展示',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 8),
            Text('支持小巧的卡片样式、水平排列的文件列表、不同的上传状态显示、文件数量限制、多种文件来源控制', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 32),

            // 1. 默认按钮样式
            _buildSectionTitle('1. 默认按钮样式 (UploadListType.button)'),
            UploadFile(
              listType: UploadListType.button,
              onFilesChanged: (files) {
                setState(() {
                  files1 = files;
                });
              },
              initialFiles: files1,
            ),
            const SizedBox(height: 32),

            // 2. 卡片样式 - 默认尺寸
            _buildSectionTitle('2. 卡片样式 (UploadListType.card) - 默认120x120'),
            UploadFile(
              listType: UploadListType.card,
              // uploadAreaSize: 120, // 默认120x120的卡片
              borderColor: Colors.grey.shade300,
              backgroundColor: Colors.grey.shade50,
              uploadIcon: Icons.camera_alt_outlined,
              iconSize: 32,
              iconColor: Colors.grey.shade500,
              onFilesChanged: (files) {
                setState(() {
                  files2 = files;
                });
              },
              initialFiles: files2,
            ),
            const SizedBox(height: 32),

            // 3. 自定义卡片样式
            _buildSectionTitle('3. 自定义卡片样式 (UploadListType.custom)'),
            UploadFile(
              listType: UploadListType.custom,
              uploadAreaSize: 100, // 100x100的卡片
              backgroundColor: Colors.green.shade50,
              borderColor: Colors.green.shade400,
              borderRadius: BorderRadius.circular(16),
              uploadIcon: Icons.add_photo_alternate,
              iconSize: 36,
              iconColor: Colors.green.shade600,
              uploadText: '选择图片',
              textStyle: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w600),
              onFilesChanged: (files) {
                setState(() {
                  files3 = files;
                });
              },
              initialFiles: files3,
            ),
            const SizedBox(height: 32),

            // 4. 完全自定义样式
            _buildSectionTitle('4. 完全自定义样式 (customUploadArea)'),
            UploadFile(
              customUploadArea: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.purple.shade100, Colors.pink.shade100], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.purple.shade300, width: 2),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      files4.add({
                        'fileName': '自定义样式文件_${DateTime.now().millisecondsSinceEpoch}.txt',
                        'status': UploadStatus.success,
                        'timestamp': DateTime.now().millisecondsSinceEpoch,
                        'fileSize': 25600,
                        'isImage': false,
                      });
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
                        child: Icon(Icons.upload_rounded, color: Colors.purple.shade700, size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '上传',
                        style: TextStyle(color: Colors.purple.shade800, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              onFilesChanged: (files) {
                setState(() {
                  files4 = files;
                });
              },
              initialFiles: files4,
            ),
            const SizedBox(height: 32),

            // 5. 隐藏文件列表的示例
            _buildSectionTitle('5. 隐藏文件列表 (showFileList: false)'),
            UploadFile(listType: UploadListType.card, showFileList: false, uploadAreaSize: 120, uploadIcon: Icons.upload_file, uploadText: '静默'),
            const SizedBox(height: 32),

            // 6. 自定义文件项样式
            _buildSectionTitle('6. 自定义文件项样式 (customFileItemBuilder)'),
            UploadFile(
              listType: UploadListType.card,
              // uploadAreaSize: 120, // 默认120x120的卡片
              customFileItemBuilder: (fileInfo) {
                final fileName = fileInfo['fileName'] as String;
                final status = fileInfo['status'] as UploadStatus;
                final fileSize = fileInfo['fileSize'] as int? ?? 0;

                return Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.indigo.shade50]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                    boxShadow: [BoxShadow(color: Colors.blue.shade100, blurRadius: 6, offset: const Offset(0, 3))],
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
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(8)),
                              child: Icon(Icons.description, color: Colors.blue.shade700, size: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              fileName.length > 6 ? '${fileName.substring(0, 6)}...' : fileName,
                              style: TextStyle(color: Colors.blue.shade800, fontSize: 9, fontWeight: FontWeight.w500),
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
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(color: status == UploadStatus.failed ? Colors.red : Colors.white, shape: BoxShape.circle),
                                child: Icon(
                                  status == UploadStatus.failed ? Icons.close : Icons.hourglass_empty,
                                  color: status == UploadStatus.failed ? Colors.white : Colors.blue.shade600,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                status == UploadStatus.failed ? '失败' : '上传中',
                                style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatFileSize(fileSize),
                                style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // 删除按钮
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () {
                            // 这里可以添加删除逻辑
                          },
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(color: Colors.red.shade300, shape: BoxShape.circle),
                            child: Icon(Icons.close, color: Colors.white, size: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // 7. 文件数量限制示例
            _buildSectionTitle('7. 文件数量限制 (limit参数)'),
            UploadFile(
              listType: UploadListType.card,
              limit: 3, // 限制最多上传3个文件
              uploadText: '最多3个',
              onFilesChanged: (files) {
                // 可以在这里处理文件变化
              },
            ),
            const SizedBox(height: 32),

            // 8. 按钮样式的数量限制
            _buildSectionTitle('8. 按钮样式的数量限制'),
            UploadFile(
              listType: UploadListType.button,
              limit: 5, // 限制最多上传5个文件
              uploadText: '最多5个文件',
              backgroundColor: Colors.orange,
            ),
            const SizedBox(height: 32),

            // 9. 文件来源控制示例
            _buildSectionTitle('9. 文件来源控制 (fileSource参数)'),

            // 9.1 只允许选择文件
            _buildSubSectionTitle('9.1 只允许选择文件 (FileSource.file)'),
            UploadFile(
              listType: UploadListType.card,
              fileSource: FileSource.file,
              uploadText: '选择文件',
              uploadIcon: Icons.folder_open,
              onFileSelected: (file) {
                print('选择了文件: ${file.name}, 大小: ${file.size} bytes');
              },
            ),
            const SizedBox(height: 16),

            // 9.2 只允许选择图片
            _buildSubSectionTitle('9.2 只允许选择图片 (FileSource.image)'),
            UploadFile(
              listType: UploadListType.card,
              fileSource: FileSource.image,
              uploadText: '选择图片',
              uploadIcon: Icons.photo_library,
              onImageSelected: (image) {
                print('选择了图片: ${image.name}, 路径: ${image.path}');
              },
            ),
            const SizedBox(height: 16),

            // 9.3 只允许拍照
            _buildSubSectionTitle('9.3 只允许拍照 (FileSource.camera)'),
            UploadFile(
              listType: UploadListType.card,
              fileSource: FileSource.camera,
              uploadText: '拍照',
              uploadIcon: Icons.camera_alt,
              onImageSelected: (photo) {
                print('拍照: ${photo.name}, 路径: ${photo.path}');
              },
            ),
            const SizedBox(height: 16),

            // 9.4 允许选择图片或拍照
            _buildSubSectionTitle('9.4 允许选择图片或拍照 (FileSource.imageOrCamera)'),
            UploadFile(
              listType: UploadListType.card,
              fileSource: FileSource.imageOrCamera,
              uploadText: '图片/拍照',
              uploadIcon: Icons.photo_camera,
              onImageSelected: (image) {
                print('选择了图片或拍照: ${image.name}, 路径: ${image.path}');
              },
            ),
            const SizedBox(height: 16),

            // 9.5 允许所有类型（默认）
            _buildSubSectionTitle('9.5 允许所有类型 (FileSource.all)'),
            UploadFile(
              listType: UploadListType.card,
              fileSource: FileSource.all,
              uploadText: '所有类型',
              uploadIcon: Icons.add_a_photo,
              onFileSelected: (file) {
                print('选择了文件: ${file.name}, 大小: ${file.size} bytes');
              },
              onImageSelected: (image) {
                print('选择了图片: ${image.name}, 路径: ${image.path}');
              },
            ),
            const SizedBox(height: 32),

            // 10. 真实上传功能示例
            _buildSectionTitle('10. 真实上传功能示例 (Dio)'),

            // 10.1 基本上传示例
            _buildSubSectionTitle('10.1 基本上传示例'),
            UploadFile(
              listType: UploadListType.card,
              uploadConfig: UploadConfig(
                uploadUrl: 'http://dev.asset.jingfang.site/api/admin/basic-upload/image-upload', // 测试接口
                headers: {
                  'Authorization':
                      'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMTYxMjIzNDExOTg2NTAxIiwidXNlcl9uYW1lIjoiYWRtaW4iLCJuYW1lIjoi566h55CG5ZGYIiwidXNlcl90eXBlIjoiUGxhdGZvcm1BZG1pbiIsIm9yZ19pZCI6IjE4OTA5NzY5MTAwOTA5MyIsInJvbGVzIjoiWzE2MTIyMzQxMjA4MDcwOSw2MzM1MzgwODU0MjkzMTddIiwicmVmcmVzaF9leHBpcmVzIjoiMTc1NzM5MzQ1MCIsIm5iZiI6MTc1Njc4MTQ1MCwiZXhwIjoxNzU2Nzg4NjUwLCJpc3MiOiJodHRwOi8vZGV2LmFzc2V0LmppbmdmYW5nLnNpdGUiLCJhdWQiOiJodHRwOi8vZGV2LmFzc2V0LmppbmdmYW5nLnNpdGUifQ.E5jC7mYj9h90bpX2hNdCVm7e8S0qjKvu9i5ohQ3-jQU',
                  'Accept': 'application/json',
                  // 'Content-Type': 'multipart/form-data',
                },
                fileFieldName: 'file',
                additionalFields: {'userId': '123', 'category': 'test'},
                onUploadSuccess: (responseData) {
                  print('上传成功: $responseData');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('上传成功！'), backgroundColor: Colors.green));
                },
                onUploadError: (error) {
                  print('上传失败: $error');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('上传失败: $error'), backgroundColor: Colors.red));
                },
                onUploadProgress: (progress) {
                  print('上传进度: ${(progress * 100).toStringAsFixed(1)}%');
                },
                timeout: Duration(seconds: 30),
              ),
              uploadText: '真实上传',
              uploadIcon: Icons.cloud_upload,
              autoUpload: true,
            ),
            const SizedBox(height: 16),

            // 10.2 带进度显示的上传示例
            _buildSubSectionTitle('10.2 带进度显示的上传示例'),
            UploadFile(
              listType: UploadListType.card,
              uploadConfig: UploadConfig(
                uploadUrl: 'https://httpbin.org/post',
                headers: {'Content-Type': 'multipart/form-data'},
                fileFieldName: 'file',
                additionalFields: {'description': '带进度的上传测试', 'timestamp': DateTime.now().millisecondsSinceEpoch.toString()},
                onUploadSuccess: (responseData) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('上传完成！'), backgroundColor: Colors.green, duration: Duration(seconds: 2)));
                },
                onUploadError: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('上传失败: $error'), backgroundColor: Colors.red, duration: Duration(seconds: 3)));
                },
                onUploadProgress: (progress) {
                  // 进度会在UI中自动显示
                  print('当前进度: ${(progress * 100).toStringAsFixed(1)}%');
                },
                timeout: Duration(minutes: 2),
              ),
              uploadText: '进度上传',
              uploadIcon: Icons.upload_file,
              autoUpload: true,
            ),
            const SizedBox(height: 16),

            // 10.3 手动上传示例
            _buildSubSectionTitle('10.3 手动上传示例 (autoUpload: false)'),
            UploadFile(
              listType: UploadListType.button,
              uploadConfig: UploadConfig(
                uploadUrl: 'https://httpbin.org/post',
                headers: {'Authorization': 'Bearer manual-upload-token'},
                fileFieldName: 'attachment',
                additionalFields: {'uploadType': 'manual', 'source': 'flutter_app'},
                onUploadSuccess: (responseData) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('手动上传成功！'), backgroundColor: Colors.blue));
                },
                onUploadError: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('手动上传失败: $error'), backgroundColor: Colors.orange));
                },
                onUploadProgress: (progress) {
                  print('手动上传进度: ${(progress * 100).toStringAsFixed(1)}%');
                },
              ),
              uploadText: '手动上传',
              backgroundColor: Colors.blue,
              autoUpload: false, // 手动上传
              onFilesChanged: (files) {
                // 可以在这里手动触发上传
                print('文件已选择，可以手动触发上传: ${files.length} 个文件');
              },
            ),
            const SizedBox(height: 16),

            // 10.4 错误处理示例
            _buildSubSectionTitle('10.4 错误处理示例 (错误URL)'),
            UploadFile(
              listType: UploadListType.card,
              uploadConfig: UploadConfig(
                uploadUrl: 'https://invalid-url-for-testing.com/upload', // 故意使用错误URL
                headers: {'Content-Type': 'multipart/form-data'},
                fileFieldName: 'file',
                onUploadSuccess: (responseData) {
                  print('意外成功: $responseData');
                },
                onUploadError: (error) {
                  print('预期的错误: $error');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('网络错误示例: $error'), backgroundColor: Colors.red, duration: Duration(seconds: 4)));
                },
                onUploadProgress: (progress) {
                  print('错误测试进度: ${(progress * 100).toStringAsFixed(1)}%');
                },
                timeout: Duration(seconds: 10),
              ),
              uploadText: '错误测试',
              uploadIcon: Icons.error_outline,
              autoUpload: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildSubSectionTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
      ),
    );
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
}
