# FileUpload 文件上传组件

一个功能完整的文件上传组件，支持图片、文件、拍照等多种文件来源，提供多种展示样式和自定义上传功能。

## 特性

- 📁 **多种文件来源**：支持图片、文件、拍照、相册等
- 🎨 **多种展示样式**：卡片、列表、文本、自定义等样式
- 🚀 **自定义上传**：支持自定义上传逻辑和接口
- 📊 **上传进度**：实时显示上传进度
- 🔄 **自动上传**：支持选择后自动上传
- 🎯 **文件限制**：支持文件数量、大小、类型限制
- 📱 **移动端优化**：适配移动端交互体验

## 基本用法

### 卡片样式上传

```dart
FileUpload(
  fileListType: FileListType.card,
  fileSource: FileSource.all,
  limit: 3,
  autoUpload: true,
  onFileChange: (currentFile, selectedFiles, action) {
    print('文件${action}: ${currentFile.name}');
    print('当前文件数: ${selectedFiles.length}');
  },
  onUploadSuccess: (file) {
    print('上传成功: ${file.name}');
  },
  onUploadFailed: (file, error) {
    print('上传失败: ${file.name}, 错误: $error');
  },
  onUploadProgress: (file, progress) {
    print('${file.name} 上传进度: ${(progress * 100).toStringAsFixed(1)}%');
  },
)
```

### 列表样式上传

```dart
FileUpload(
  fileListType: FileListType.list,
  fileSource: FileSource.file,
  limit: 5,
  showFileList: true,
  onFileChange: (currentFile, selectedFiles, action) {
    print('文件变化: ${selectedFiles.length}个文件');
  },
)
```

### 文本样式上传

```dart
FileUpload(
  fileListType: FileListType.text,
  fileSource: FileSource.image,
  limit: 1,
  onFileChange: (currentFile, selectedFiles, action) {
    if (selectedFiles.isNotEmpty) {
      print('选中图片: ${selectedFiles.first.name}');
    }
  },
)
```

### 自定义上传区域

```dart
FileUpload(
  fileListType: FileListType.custom,
  fileSource: FileSource.all,
  limit: 3,
  customAreaContent: (onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 48,
            color: Colors.blue.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            '拖拽文件到此处或点击选择',
            style: TextStyle(
              color: Colors.blue.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '支持多种文件格式，最多3个文件',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  ),
  onFileChange: (currentFile, selectedFiles, action) {
    print('文件${action}: ${currentFile.name}');
  },
)
```

### 自定义上传逻辑

```dart
FileUpload(
  fileListType: FileListType.card,
  fileSource: FileSource.all,
  autoUpload: true,
  customUpload: (filePath, onProgress) async {
    try {
      // 自定义上传逻辑
      final dio = Dio();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await dio.post(
        'https://your-api.com/upload',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            onProgress(sent / total);
          }
        },
      );

      if (response.statusCode == 200) {
        return FileUploadModel(
          name: filePath.split('/').last,
          path: filePath,
          source: FileSource.file,
          status: UploadStatus.success,
          progress: 1.0,
          url: response.data['url'],
          fileSize: response.data['size'],
          fileSizeInfo: _formatFileSize(response.data['size']),
        );
      }
      return null;
    } catch (e) {
      print('上传失败: $e');
      return null;
    }
  },
  onUploadSuccess: (file) {
    print('上传成功: ${file.url}');
  },
)
```

### 带默认文件

```dart
FileUpload(
  fileListType: FileListType.card,
  defaultValue: [
    FileUploadModel(
      name: '默认文件.jpg',
      path: '/path/to/file.jpg',
      source: FileSource.image,
      status: UploadStatus.success,
      progress: 1.0,
      url: 'https://example.com/file.jpg',
    ),
  ],
  onFileChange: (currentFile, selectedFiles, action) {
    print('文件列表更新: ${selectedFiles.length}个文件');
  },
)
```

## API 参数

| 参数                | 类型                                                           | 默认值              | 说明                        |
| ------------------- | -------------------------------------------------------------- | ------------------- | --------------------------- |
| `fileListType`      | `FileListType`                                                 | `FileListType.card` | 文件列表展示类型            |
| `fileSource`        | `FileSource`                                                   | `FileSource.all`    | 文件来源类型                |
| `limit`             | `int`                                                          | `-1`                | 文件数量限制，-1 表示无限制 |
| `autoUpload`        | `bool`                                                         | `true`              | 是否自动上传                |
| `showFileList`      | `bool`                                                         | `true`              | 是否显示文件列表            |
| `isRemoveFailFile`  | `bool`                                                         | `false`             | 上传失败时是否移除文件      |
| `defaultValue`      | `List<FileUploadModel>?`                                       | `null`              | 默认文件列表                |
| `uploadConfig`      | `UploadConfig?`                                                | `null`              | 上传配置                    |
| `customUpload`      | `Future<FileUploadModel?> Function(String, Function(double))?` | `null`              | 自定义上传函数              |
| `customAreaContent` | `Widget Function(VoidCallback)?`                               | `null`              | 自定义上传区域内容          |
| `customFileList`    | `Widget?`                                                      | `null`              | 自定义文件列表样式          |
| `onFileChange`      | `Function(FileUploadModel, List<FileUploadModel>, String)?`    | `null`              | 文件变化回调                |
| `onUploadSuccess`   | `Function(FileUploadModel)?`                                   | `null`              | 上传成功回调                |
| `onUploadFailed`    | `Function(FileUploadModel, String)?`                           | `null`              | 上传失败回调                |
| `onUploadProgress`  | `Function(FileUploadModel, double)?`                           | `null`              | 上传进度回调                |

## 枚举类型

### FileListType 文件列表类型

```dart
enum FileListType {
  card,    // 卡片样式
  list,    // 列表样式
  text,    // 文本样式
  custom,  // 自定义样式
}
```

### FileSource 文件来源

```dart
enum FileSource {
  image,   // 仅图片
  file,    // 仅文件
  camera,  // 仅拍照
  all,     // 所有来源
}
```

### UploadStatus 上传状态

```dart
enum UploadStatus {
  waiting,    // 等待上传
  uploading,  // 上传中
  success,    // 上传成功
  failed,     // 上传失败
}
```

## FileUploadModel 数据结构

```dart
class FileUploadModel {
  final String name;           // 文件名
  final String path;           // 文件路径
  final FileSource source;     // 文件来源
  final UploadStatus status;   // 上传状态
  final double progress;       // 上传进度 (0.0-1.0)
  final String? url;          // 上传后的URL
  final int? fileSize;        // 文件大小（字节）
  final String? fileSizeInfo; // 文件大小信息
  final FileInfo? fileInfo;   // 文件详细信息
}
```

## UploadConfig 上传配置

```dart
class UploadConfig {
  final String? uploadUrl;           // 上传接口URL
  final Map<String, String>? headers; // 请求头
  final Map<String, dynamic>? params; // 额外参数
}
```

## 使用场景

1. **头像上传**：用户头像、商品图片等单图上传
2. **文档上传**：合同、证书等文档上传
3. **批量上传**：相册、文件批量上传
4. **拍照上传**：现场拍照并上传
5. **表单附件**：表单中的附件上传

## 注意事项

1. 使用自定义上传时，需要实现 `customUpload` 函数
2. `customAreaContent` 仅在 `fileListType` 为 `custom` 时生效
3. 文件大小限制需要在 `customUpload` 中自行处理
4. 上传进度回调中的 `progress` 值范围为 0.0-1.0
5. 建议在生产环境中添加文件类型和大小验证

## 示例

更多使用示例请参考 [example](../../../example/lib/pages/) 目录中的相关示例页面。
