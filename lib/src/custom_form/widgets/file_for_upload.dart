import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';
import 'package:simple_ui/src/custom_form/index.dart';

class FileForUpload extends StatefulWidget {
  const FileForUpload({super.key});
  @override
  State<FileForUpload> createState() => _FileForUploadState();
}

class _FileForUploadState extends State<FileForUpload> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelInfo(label: '文件上传', required: true),
              FileUpload(autoUpload: false, uploadConfig: UploadConfig(uploadUrl: '')),
            ],
          ),
        ),
        // 错误信息
        Positioned(bottom: 0, left: 0, child: ErrorInfo('校验失败')),
      ],
    );
  }
}
