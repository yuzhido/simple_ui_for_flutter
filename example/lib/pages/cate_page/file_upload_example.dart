import 'package:example/pages/file_upload/index.dart';
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FileUploadPage()));
            },
            child: Text('跳转查看文件上传组件（FileUpload）示例'),
          ),
        ],
      ),
    );
  }
}
