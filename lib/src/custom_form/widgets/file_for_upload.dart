import 'package:flutter/material.dart';
import 'package:simple_ui/models/index.dart';
import 'package:simple_ui/src/custom_form/models/custom_form_config.dart';
import 'package:simple_ui/src/custom_form/widgets/error_info.dart';
import 'package:simple_ui/src/custom_form/widgets/label_info.dart';
import 'package:simple_ui/src/file_upload/index.dart';

class FileForUpload extends StatefulWidget {
  final FormFiledConfig config;
  const FileForUpload({super.key, required this.config});
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
