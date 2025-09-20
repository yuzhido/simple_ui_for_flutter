import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';
import 'package:simple_ui/simple_ui.dart';
import 'package:dio/dio.dart';
import 'package:example/utils/config.dart';

class TestFormUploadFilePage extends StatefulWidget {
  const TestFormUploadFilePage({super.key});
  @override
  State<TestFormUploadFilePage> createState() => _TestFormUploadFilePageState();
}

class _TestFormUploadFilePageState extends State<TestFormUploadFilePage> {
  final FormBuilderController _controller = FormBuilderController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late List<FormBuilderConfig> _configs;

  @override
  void initState() {
    super.initState();
    _initConfigs();
  }

  int number = 0;

  void _initConfigs() {
    _configs = [
      // 基础图片上传 - 卡片样式
      FormBuilderConfig.upload(
        name: 'images',
        label: '图片上传（卡片样式）',
        required: false,
        defaultValue: [
          FileUploadModel(
            fileInfo: FileInfo(id: 'demo_1', fileName: 'demo_image.jpg', requestPath: '/uploads/demo.jpg'),
            name: 'demo_image.jpg',
            path: '${Config.baseUrl}/uploads/file-1758361962259-284873273.jpeg',
            status: UploadStatus.success,
            progress: 1.0,
          ),
        ],
        uploadConfig: UploadConfig(uploadUrl: '${Config.baseUrl}/upload/api/upload-file', headers: {'Authorization': 'Bearer token123'}),
        fileListType: FileListType.card,
        limit: 5,
        fileSource: FileSource.imageOrCamera,
        onChange: (fieldName, value) {
          print('图片上传字段 $fieldName 值变更为: $value');
        },
      ),

      // 文档上传 - 文本信息样式
      FormBuilderConfig.upload(
        name: 'documents',
        label: '文档上传（文本样式）',
        required: false,
        uploadConfig: UploadConfig(uploadUrl: '${Config.baseUrl}/upload/api/upload-file', headers: {'Authorization': 'Bearer token123'}),
        fileListType: FileListType.textInfo,
        limit: 3,
        fileSource: FileSource.file,
        onChange: (fieldName, value) {
          print('文档上传字段 $fieldName 值变更为: $value');
          List<dynamic> files = value ?? [];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已上传 ${files.length} 个文档'), duration: Duration(seconds: 1)));
        },
      ),

      // 自定义上传区域样式
      FormBuilderConfig.upload(
        name: 'customStyleUpload',
        label: '自定义样式上传',
        required: false,
        uploadIcon: Icon(Icons.cloud_upload, size: 48, color: Colors.green),
        uploadText: Text(
          '点击或拖拽文件到这里上传\n支持图片、文档等多种格式',
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        uploadConfig: UploadConfig(uploadUrl: '${Config.baseUrl}/upload/api/upload-file', headers: {'Authorization': 'Bearer token123'}),
        limit: 10,
        fileSource: FileSource.all,
        onFileChange: (file, fileList, type) {
          print(number);
          print('$number自定义样式上传操作: $type, 当前文件: ${file.name}, 文件列表长度: ${fileList.length}');
          number++;
        },
      ),

      // 使用自定义上传函数
      FormBuilderConfig.upload(
        name: 'customFunctionUpload',
        label: '自定义上传函数示例',
        required: false,
        customUpload: (String filePath, Function(double) onProgress) async {
          print('🚀 开始自定义上传文件: $filePath');

          try {
            final dio = Dio();
            final formData = FormData();
            final fileName = filePath.split('/').last.split('\\').last;

            formData.files.add(MapEntry('file', await MultipartFile.fromFile(filePath, filename: fileName)));

            final response = await dio.post(
              '${Config.baseUrl}/upload/api/upload-file',
              data: formData,
              onSendProgress: (sent, total) {
                final progress = sent / total;
                onProgress(progress);
                print('📤 上传进度: ${(progress * 100).toInt()}%');
              },
            );

            if (response.statusCode == 200) {
              final responseData = response.data;
              print('✅ 上传成功: $responseData');
              print('✅ 上传成功: ${responseData['data']}');
              print('✅ 上传成功: ${responseData['data']['requestPath']}');

              // 构建完整的图片URL
              final fullServerUrl = '${Config.baseUrl}${responseData['data']['requestPath']}';

              return FileUploadModel(
                fileInfo: FileInfo(
                  id: "${responseData['data']['id']}",
                  fileName: fileName,
                  requestPath: "${responseData['data']['requestPath']}", // requestPath存储服务器返回的相对路径
                ),
                name: fileName,
                path: filePath, // 保留原始本地文件路径，用于上传前的预览
                url: fullServerUrl, // url字段存储完整的服务器URL，用于上传后的访问
                status: UploadStatus.success,
                progress: 1.0,
              );
            } else {
              print('❌ 上传失败: ${response.statusCode}');
              return null;
            }
          } catch (e) {
            print('❌ 上传异常: $e');
            return null;
          }
        },
        fileListType: FileListType.card,
        limit: 5,
        fileSource: FileSource.all,
        onFileChange: (file, fileList, type) {
          if (file.status == UploadStatus.success) {
            print('66666666666666666666666666666666');
            print(file.toMap());
            print(fileList);
            print(type);
            print('自定义上传函数文件状态: ${file.status}');
            print('66666666666666666666666666666666');
          }
          if (file.status == UploadStatus.pending) {
            print('5555555555555555555555555555555');
            print(file.toMap());
            print(fileList);
            print(type);
            print('自定义上传函数文件状态: ${file.status}');
            print('5555555555555555555555555555555');
          }
        },
      ),

      // 仅相机拍照上传
      FormBuilderConfig.upload(
        name: 'cameraOnly',
        label: '相机拍照上传',
        required: false,
        uploadConfig: UploadConfig(uploadUrl: '${Config.baseUrl}/upload/api/upload-file', headers: {'Authorization': 'Bearer token123'}),
        fileListType: FileListType.card,
        limit: 3,
        fileSource: FileSource.camera,
        onChange: (fieldName, value) {
          print('相机拍照字段 $fieldName 值变更为: $value');
          List<dynamic> files = value ?? [];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已拍照上传 ${files.length} 张照片'), duration: Duration(seconds: 1)));
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文件上传表单示例'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(
            child: FormBuilder(configs: _configs, controller: _controller, formKey: _formKey, autovalidate: true),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetForm,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white),
                    child: const Text('重置表单'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    child: const Text('提交表单'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showFormData,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text('查看数据'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _controller.reset(_configs);
    _formKey.currentState?.reset();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('表单已重置'), duration: Duration(seconds: 1)));
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final values = _controller.values;

      // 统计上传的文件数量
      int totalFiles = 0;
      values.forEach((key, value) {
        if (value is List) {
          totalFiles += value.length;
        }
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('表单提交成功'),
          content: Text('共上传了 $totalFiles 个文件'),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('确定'))],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请检查表单内容'), duration: Duration(seconds: 2)));
    }
  }

  void _showFormData() {
    final values = _controller.values;

    String formDataText = '';
    values.forEach((key, value) {
      if (value is List<FileUploadModel>) {
        formDataText += '$key: ${value.length} 个文件\n';
        for (int i = 0; i < value.length; i++) {
          final file = value[i];
          formDataText += '  - ${file.name} (${file.status})\n';
        }
      } else {
        formDataText += '$key: $value\n';
      }
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('当前表单数据'),
        content: SingleChildScrollView(
          child: Text(formDataText.isEmpty ? '暂无数据' : formDataText, style: const TextStyle(fontFamily: 'monospace')),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('关闭'))],
      ),
    );
  }
}
