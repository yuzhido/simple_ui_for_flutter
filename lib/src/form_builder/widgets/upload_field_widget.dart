import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';
import 'package:simple_ui/src/file_upload/index.dart';
import 'package:simple_ui/models/file_upload.dart';

/// 上传字段组件
class UploadFieldWidget extends StatelessWidget {
  final FormBuilderConfig config;
  final dynamic value;
  final Function(dynamic) onChanged;

  const UploadFieldWidget({super.key, required this.config, this.value, required this.onChanged});

  /// 将动态类型的文件列表转换为 FileUploadModel 列表
  List<FileUploadModel>? _convertToFileUploadModels(dynamic value) {
    if (value == null) return null;
    if (value is! List) return null;

    return value.map((item) {
      if (item is FileUploadModel) {
        return item;
      } else if (item is Map<String, dynamic>) {
        return FileUploadModel.fromMap(item);
      } else {
        // 创建一个基本的 FileUploadModel
        final fileInfo = FileInfo(id: DateTime.now().millisecondsSinceEpoch, fileName: item.toString(), requestPath: '');
        return FileUploadModel(fileInfo: fileInfo, name: item.toString(), status: UploadStatus.success);
      }
    }).toList();
  }

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

    return FormField<List<dynamic>>(
      initialValue: props.defaultValue ?? config.defaultValue ?? [],
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
            FileUpload(
              // 基础属性
              limit: props.limit ?? -1,
              fileSource: props.fileSource,
              fileListType: props.fileListType,
              showFileList: props.showFileList,
              autoUpload: props.autoUpload,
              isRemoveFailFile: props.isRemoveFailFile,
              uploadConfig: props.uploadConfig,
              defaultValue: _convertToFileUploadModels(state.value),
              // 自定义组件
              customFileList: props.customFileList,
              uploadIcon: props.uploadIcon,
              uploadText: props.uploadText,
              // 回调函数
              onFileChange: (FileUploadModel file, List<FileUploadModel> fileList, String type) {
                onChanged(fileList);
                state.didChange(fileList);
                // 调用原有的回调
                if (props.onFileChange != null) {
                  props.onFileChange!(file, fileList, type);
                }
              },
              onUploadSuccess: (FileUploadModel file) {
                if (props.onUploadSuccess != null) {
                  props.onUploadSuccess!(file);
                }
              },
              onUploadFailed: (FileUploadModel file, String error) {
                if (props.onUploadFailed != null) {
                  props.onUploadFailed!(file, error);
                }
              },
              onUploadProgress: (FileUploadModel file, double progress) {
                if (props.onUploadProgress != null) {
                  props.onUploadProgress!(file, progress);
                }
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
