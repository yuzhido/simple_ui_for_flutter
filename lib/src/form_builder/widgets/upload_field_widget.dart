import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';
import 'package:simple_ui/models/file_info.dart';
import 'package:simple_ui/src/upload_file/index.dart';

/// 上传字段组件
class UploadFieldWidget extends StatelessWidget {
  final FormBuilderConfig config;
  final dynamic value;
  final Function(dynamic) onChanged;

  const UploadFieldWidget({super.key, required this.config, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final UploadProps? props = config.props is UploadProps ? config.props as UploadProps : null;

    if (props == null) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Text('配置错误')),
      );
    }

    // 处理初始文件列表
    List<UploadedFile> initialFiles = [];
    if (props.initialFiles != null) {
      initialFiles = props.initialFiles!.map((file) {
        if (file is UploadedFile) {
          return file;
        } else if (file is Map<String, dynamic>) {
          return UploadedFile(
            fileName: file['fileName'] ?? 'unknown',
            status: UploadStatus.success,
            timestamp: file['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
            fileSize: file['fileSize'] ?? 0,
            filePath: file['filePath'],
            isImage: file['isImage'] ?? false,
            fileUrl: file['fileUrl'],
            data: file['data'],
          );
        }
        return UploadedFile(fileName: file.toString(), status: UploadStatus.success, timestamp: DateTime.now().millisecondsSinceEpoch);
      }).toList();
    }

    // 处理默认值 - 将FileInfo转换为UploadedFile
    List<FileInfo>? defaultFileInfos;
    if (config.defaultValue != null && config.defaultValue is List) {
      defaultFileInfos = (config.defaultValue as List).whereType<FileInfo>().toList();
    }

    return FormField<List<UploadedFile>>(
      initialValue: initialFiles,
      validator:
          config.validator ??
          (files) {
            if (config.required && (files == null || files.isEmpty)) {
              return '请上传${config.label}';
            }
            return null;
          },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UploadFile(
              listType: props.listType ?? UploadListType.button,
              uploadText: props.uploadText,
              autoUpload: props.autoUpload,
              showFileList: props.showFileList,
              backgroundColor: props.backgroundColor,
              customUploadArea: props.customUploadArea,
              uploadAreaSize: props.uploadAreaSize,
              borderColor: props.borderColor,
              borderRadius: props.borderRadius,
              uploadIcon: props.uploadIcon,
              iconSize: props.iconSize,
              iconColor: props.iconColor,
              textStyle: props.textStyle,
              initialFiles: initialFiles,
              defaultValue: defaultFileInfos,
              customFileItemBuilder: props.customFileItemBuilder,
              fileItemSize: props.fileItemSize,
              limit: props.limit ?? -1,
              fileSource: props.fileSource ?? FileSource.all,
              onFileSelected: props.onFileSelected,
              onImageSelected: props.onImageSelected,
              uploadConfig: props.uploadConfig,
              onFilesChanged: (files) {
                onChanged(files);
                state.didChange(files);
              },
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(state.errorText ?? '', style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        );
      },
    );
  }
}
