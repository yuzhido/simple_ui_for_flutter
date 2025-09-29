import 'package:flutter/material.dart';
import 'package:simple_ui/models/index.dart';
import 'package:simple_ui/src/config_form/widgets/index.dart';
import 'package:simple_ui/src/file_upload/index.dart';

class UploadForFile extends StatefulWidget {
  final FormConfig config;
  final ConfigFormController controller;
  final void Function(Map<String, dynamic>)? onChanged;

  const UploadForFile({super.key, required this.config, required this.controller, this.onChanged});
  @override
  State<UploadForFile> createState() => _UploadForFileState();
}

class _UploadForFileState extends State<UploadForFile> {
  late ValueNotifier<Map<String, String>> countNotifier;
  @override
  void initState() {
    countNotifier = ValueNotifier(widget.controller.errors);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final props = widget.config.props as UploadProps;
    final errorsInfo = widget.controller.errors;

    return ValueListenableBuilder(
      valueListenable: countNotifier,
      builder: (context, _, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            LabelInfo(widget.config.label, widget.config.required),
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 18),
                  child: FileUpload(
                    // 数量限制
                    limit: props.maxFiles ?? -1,
                    fileListType: props.fileListType,
                    fileSource: props.fileSource,
                    // 自动上传：仅当提供了uploadUrl或customUpload时生效
                    autoUpload: props.autoUpload,
                    // 上传配置与行为
                    uploadConfig: UploadConfig(uploadUrl: props.uploadUrl, headers: null),
                    isRemoveFailFile: props.isRemoveFailFile,
                    customUpload: props.customUpload,
                    // 默认文件（显示已上传）
                    defaultValue: null,
                    // 回调：统一维护 controller 数据
                    onFileChange: (current, selected, action) {
                      // 调用外部回调
                      props.onFileChange?.call(current, selected, action);
                    },
                    // 上传成功回调
                    onUploadSuccess: (file) {
                      // 触发表单变化回调
                      widget.onChanged?.call(widget.controller.getFormData());
                      // 更新控制器中的表单数据
                      widget.controller.setFieldValue(widget.config.name, file.fileInfo);
                    },
                    // 上传失败回调
                    onUploadFailed: (file, error) {
                      print('文件上传失败: ${file.name}, 错误: $error');
                    },
                  ),
                ),
                if (errorsInfo[widget.config.name] != null) Positioned(bottom: 0, left: 0, child: ErrorInfo(errorsInfo[widget.config.name]!)),
              ],
            ),
          ],
        );
      },
    );
  }
}
