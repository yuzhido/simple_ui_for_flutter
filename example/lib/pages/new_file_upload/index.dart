import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';

class NewFileUploadPage extends StatefulWidget {
  const NewFileUploadPage({super.key});
  @override
  State<NewFileUploadPage> createState() => _NewFileUploadPageState();
}

class _NewFileUploadPageState extends State<NewFileUploadPage> {
  String _uploadMessage = '';
  void _showMessage(String message) {
    setState(() {
      _uploadMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('最新文件上传组件')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // 显示上传消息
            if (_uploadMessage.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text('最新消息: $_uploadMessage', style: TextStyle(color: Colors.blue.shade700)),
              ),
              const SizedBox(height: 16),
            ],

            // 新增：自动上传功能测试
            Text(
              '🚀 新功能测试',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red),
            ),
            const SizedBox(height: 16),

            // 测试1：正确配置的自动上传
            Text('1. 自动上传 - 正确配置', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 8),
            FileUpload(
              fileListType: FileListType.textInfo,

              uploadConfig: UploadConfig(uploadUrl: 'https://api.example.com/upload', headers: {'Authorization': 'Bearer token123'}),
              onUploadSuccess: (file) => _showMessage('✅ 文件 ${file.name} 上传成功！'),
              onUploadFailed: (file, error) => _showMessage('❌ 文件 ${file.name} 上传失败: $error'),
              onUploadProgress: (file, progress) => _showMessage('📤 文件 ${file.name} 上传进度: ${(progress * 100).toInt()}%'),
              onFileChange: (currentFile, selectedFiles, action) {
                print('自动上传模式 - 操作: $action, 文件: ${currentFile.name}');
              },
            ),
            const SizedBox(height: 24),

            // 测试2：错误配置测试 - autoUpload为true但没有uploadUrl
            Text('2. 错误配置测试 - 缺少uploadUrl', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('点击下面按钮测试错误配置:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      try {
                        // 这应该会抛出异常
                        FileUpload(
                          fileListType: FileListType.textInfo,
                          autoUpload: false,
                          uploadConfig: UploadConfig(headers: {'test': 'value'}), // 没有uploadUrl
                        );
                      } catch (e) {
                        _showMessage('🚫 配置错误被正确捕获: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: Text('测试错误配置'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 测试3：手动上传模式
            Text('3. 手动上传模式 - autoUpload为false', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 8),
            FileUpload(
              fileListType: FileListType.card,
              uploadConfig: UploadConfig(uploadUrl: 'https://api.example.com/manual-upload', headers: {'Content-Type': 'multipart/form-data'}),
              onFileChange: (currentFile, selectedFiles, action) {
                _showMessage('📁 手动模式 - $action: ${currentFile.name}');
              },
            ),
            const SizedBox(height: 24),

            // 测试4：无uploadConfig的手动模式（应该正常工作）
            Text('4. 无uploadConfig的手动模式', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 8),
            FileUpload(
              fileListType: FileListType.textInfo,
              autoUpload: false,
              onFileChange: (currentFile, selectedFiles, action) {
                _showMessage('📂 无配置手动模式 - $action: ${currentFile.name}');
              },
            ),
            const SizedBox(height: 32),

            Divider(thickness: 2),
            const SizedBox(height: 16),

            // 原有的测试用例
            Text('📋 原有功能测试', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 16),

            // 上传文件组件
            Text('1. 默认按钮样式', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            FileUpload(fileListType: FileListType.textInfo, autoUpload: false),
            Text('2. 卡片样式', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            FileUpload(fileListType: FileListType.card, autoUpload: false),
            Text('3. 自定义样式', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            FileUpload(fileListType: FileListType.custom, autoUpload: false, customFileList: Text('自定义上传文件列表样式')),
            Text('4. 自定义文件来源', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            // 文本信息模式 - 带预览
            Text('1. 文本信息模式 - 文件预览', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 8),
            FileUpload(
              fileListType: FileListType.textInfo,
              autoUpload: false,
              showFileList: true,
              limit: 3,
              onFileChange: (FileUploadModel currentFile, List<FileUploadModel> selectedFiles, String action) {
                print('=== 文本模式文件操作信息 ===');
                print('操作类型: $action');
                print('当前操作文件: ${currentFile.name}');
                print('当前文件列表数量: ${selectedFiles.length}');
                print('所有文件名: ${selectedFiles.map((f) => f.name).join(', ')}');
                print('==============================');
              },
            ),
            const SizedBox(height: 24),

            // 卡片模式 - 带预览
            Text('2. 卡片模式 - 图片预览', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 8),
            FileUpload(
              fileListType: FileListType.card,
              showFileList: true,
              autoUpload: false,
              limit: 6,
              fileSource: FileSource.imageOrCamera,
              onFileChange: (FileUploadModel currentFile, List<FileUploadModel> selectedFiles, String action) {
                print('=== 卡片模式文件操作信息 ===');
                print('操作类型: $action');
                print('当前操作文件: ${currentFile.name} (${currentFile.source})');
                print('当前文件列表数量: ${selectedFiles.length}');
                print('所有文件: ${selectedFiles.map((f) => '${f.name}(${f.fileSizeInfo})').join(', ')}');
                print('==============================');
              },
            ),
            const SizedBox(height: 24),

            // 混合文件类型测试
            Text('3. 混合文件类型 - 卡片模式', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 8),
            FileUpload(
              fileListType: FileListType.card,
              showFileList: true,
              autoUpload: false,
              limit: 4,
              fileSource: FileSource.all,
              onFileChange: (FileUploadModel currentFile, List<FileUploadModel> selectedFiles, String action) {
                print('=== 混合文件类型操作信息 ===');
                print('操作类型: $action');
                print('当前操作文件: ${currentFile.name} (${currentFile.source})');
                print('当前文件列表数量: ${selectedFiles.length}');
                print('文件详情: ${selectedFiles.map((f) => '${f.name}[${f.fileSizeInfo}]').join(', ')}');
                print('=====================================');
              },
            ),
            const SizedBox(height: 24),

            // 单文件限制测试
            Text('4. 单文件限制 - 文本模式', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 8),
            FileUpload(
              fileListType: FileListType.textInfo,
              showFileList: true,
              autoUpload: false,
              limit: 1,
              onFileChange: (FileUploadModel currentFile, List<FileUploadModel> selectedFiles, String action) {
                print('=== 单文件操作信息 ===');
                print('操作类型: $action');
                print('当前操作文件: ${currentFile.name}');
                print('文件列表状态: ${selectedFiles.length > 0 ? selectedFiles.first.name : '无文件'}');
                print('============================');
              },
            ),
            const SizedBox(height: 24),

            // 无限制文件数量
            Text('5. 无限制文件数量 - 卡片模式', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 8),
            FileUpload(
              fileListType: FileListType.card,
              showFileList: true,
              autoUpload: false,
              limit: -1, // 无限制
              onFileChange: (FileUploadModel currentFile, List<FileUploadModel> selectedFiles, String action) {
                print('=== 无限制模式文件操作信息 ===');
                print('操作类型: $action');
                print('当前操作文件: ${currentFile.name}');
                print('当前文件总数: ${selectedFiles.length}');
                print('最近5个文件: ${selectedFiles.take(5).map((f) => f.name).join(', ')}');
                print('================================');
              },
            ),
            const SizedBox(height: 24),

            // 自定义样式
            Text('6. 自定义样式', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 8),
            FileUpload(
              autoUpload: false,
              fileListType: FileListType.custom,
              customFileList: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text('这里可以放置自定义的文件列表样式', style: TextStyle(color: Colors.blue.shade700)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
