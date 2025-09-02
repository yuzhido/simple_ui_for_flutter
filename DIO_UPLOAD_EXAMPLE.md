# Dio 上传功能使用示例

## 基本使用

```dart
import 'package:simple_ui/simple_ui.dart';

class MyUploadPage extends StatefulWidget {
  @override
  _MyUploadPageState createState() => _MyUploadPageState();
}

class _MyUploadPageState extends State<MyUploadPage> {
  List<Map<String, dynamic>> uploadedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('文件上传示例')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: UploadFile(
          // 上传配置
          uploadConfig: UploadConfig(
            uploadUrl: 'https://your-api.com/upload',
            headers: {
              'Authorization': 'Bearer your-token',
              'Accept': 'application/json',
            },
            fileFieldName: 'file', // 文件字段名
            additionalFields: {
              'userId': '123',
              'category': 'images',
            },
            // 上传成功回调
            onUploadSuccess: (responseData) {
              print('上传成功: $responseData');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('上传成功！')),
              );
            },
            // 上传失败回调
            onUploadError: (error) {
              print('上传失败: $error');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('上传失败: $error'), backgroundColor: Colors.red),
              );
            },
            // 上传进度回调
            onUploadProgress: (progress) {
              print('上传进度: ${(progress * 100).toStringAsFixed(1)}%');
            },
            timeout: Duration(seconds: 30),
          ),
          // 文件列表变化回调
          onFilesChanged: (files) {
            setState(() {
              uploadedFiles = files;
            });
          },
          // 其他配置
          listType: UploadListType.card,
          fileSource: FileSource.all,
          limit: 5, // 最多上传5个文件
          autoUpload: true, // 自动上传
        ),
      ),
    );
  }
}
```

## 高级配置

```dart
UploadFile(
  uploadConfig: UploadConfig(
    uploadUrl: 'https://api.example.com/upload',
    headers: {
      'Authorization': 'Bearer ${userToken}',
      'Content-Type': 'multipart/form-data',
      'X-Client-Version': '1.0.0',
    },
    fileFieldName: 'attachment',
    additionalFields: {
      'userId': currentUser.id,
      'folderId': selectedFolder.id,
      'description': fileDescription,
      'tags': 'important,work',
    },
    onUploadSuccess: (response) {
      // 处理成功响应
      if (response['success'] == true) {
        final fileUrl = response['data']['url'];
        final fileId = response['data']['id'];
        // 保存文件信息到本地数据库
        saveFileInfo(fileId, fileUrl);
      }
    },
    onUploadError: (error) {
      // 处理错误
      showErrorDialog(error);
    },
    onUploadProgress: (progress) {
      // 更新进度显示
      updateProgressIndicator(progress);
    },
    timeout: Duration(minutes: 5), // 5分钟超时
  ),
  listType: UploadListType.custom,
  uploadAreaSize: 150,
  fileItemSize: 150,
  limit: 10,
  autoUpload: true,
)
```

## 服务器响应格式

Dio 上传功能支持多种服务器响应格式：

### 标准响应格式

```json
{
  "success": true,
  "message": "上传成功",
  "data": {
    "id": "file_123",
    "url": "https://cdn.example.com/files/file_123.jpg",
    "filename": "image.jpg",
    "size": 1024000
  }
}
```

### 简单响应格式

```json
{
  "url": "https://cdn.example.com/files/file_123.jpg",
  "filename": "image.jpg"
}
```

## 错误处理

Dio 提供了详细的错误类型处理：

- **连接超时**: 网络连接超时
- **发送超时**: 文件上传超时
- **接收超时**: 服务器响应超时
- **服务器错误**: HTTP 状态码错误
- **网络错误**: 网络连接问题
- **请求取消**: 用户取消上传

## 特性优势

### 相比 HTTP 库的优势：

1. **更好的进度监听**: 实时上传进度回调
2. **更详细的错误处理**: 分类处理不同类型的错误
3. **更简洁的 API**: 更少的代码实现相同功能
4. **更好的性能**: 优化的网络请求处理
5. **更丰富的功能**: 支持请求拦截器、响应拦截器等

### 新增功能：

- ✅ 实时上传进度显示
- ✅ 详细的错误分类处理
- ✅ 更好的超时控制
- ✅ 支持大文件上传
- ✅ 自动重试机制（可配置）
