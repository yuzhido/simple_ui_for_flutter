import 'dart:async';
import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';

class UploadFileDemoPage extends StatefulWidget {
  const UploadFileDemoPage({super.key});
  @override
  State<UploadFileDemoPage> createState() => _UploadFileDemoPageState();
}

class _UploadFileDemoPageState extends State<UploadFileDemoPage> {
  final ConfigFormController _formController = ConfigFormController();

  Future<FileUploadModel?> _mockCustomUpload(String filePath, Function(double) onProgress) async {
    // 模拟上传进度
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      onProgress(i / 10.0);
    }
    // 返回成功的文件信息
    return FileUploadModel(
      fileInfo: FileInfo(id: DateTime.now().millisecondsSinceEpoch, fileName: filePath.split('/').last, requestPath: '/files/mock/${DateTime.now().millisecondsSinceEpoch}'),
      name: filePath.split('/').last,
      path: filePath,
      source: FileSource.file,
      status: UploadStatus.success,
      progress: 1.0,
      url: 'https://example.com/files/${DateTime.now().millisecondsSinceEpoch}',
      createTime: DateTime.now(),
      updateTime: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('上传文件字段示例')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConfigForm(
              controller: _formController,
              configs: [
                FormConfig.upload(
                  UploadFieldConfig(
                    name: 'attachments',
                    label: '附件上传',
                    required: true,
                    maxFiles: 3,
                    // 不提供 uploadUrl，演示自定义上传
                    fileListType: FileListType.card,
                    fileSource: FileSource.all,
                    autoUpload: true,
                    isRemoveFailFile: false,
                    customUpload: _mockCustomUpload,
                  ),
                ),
              ],
              // 提交按钮
              submitBuilder: (formData) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formController.validate()) {
                        final data = _formController.getFormData();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('提交成功：\n${data.toString()}')));
                      }
                    },
                    child: const Text('提交'),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            const Text('说明：此示例使用自定义上传回调模拟上传流程。'),
          ],
        ),
      ),
    );
  }
}
