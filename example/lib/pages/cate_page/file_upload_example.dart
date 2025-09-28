import 'package:example/pages/compress_demo/index.dart';
import 'package:example/pages/new_file_upload/index.dart';
import 'package:flutter/material.dart';

class FileUploadExamplePage extends StatefulWidget {
  const FileUploadExamplePage({super.key});
  @override
  State<FileUploadExamplePage> createState() => _FileUploadExamplePageState();
}

class _FileUploadExamplePageState extends State<FileUploadExamplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文件上传示例')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NewFileUploadPage()));
            },
            child: Text('跳转查看最新文件上传组件（NewFileUpload）示例'),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CompressDemoPage()));
            },
            child: Text('跳转查看图片压缩演示（CompressDemo）示例'),
          ),
        ],
      ),
    );
  }
}
