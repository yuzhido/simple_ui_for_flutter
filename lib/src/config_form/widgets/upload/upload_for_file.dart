import 'package:flutter/material.dart';
import 'package:simple_ui/models/file_upload.dart';
import 'package:simple_ui/models/form_config.dart';
import 'package:simple_ui/src/config_form/config_form_controller.dart';
import 'package:simple_ui/src/config_form/utils/validation_utils.dart';
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
  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (value) {
        // 复用通用校验：对 required 生效
        final validator = ValidationUtils.getValidator(widget.config);
        return validator?.call(value);
      },
      builder: (state) {
        final props = widget.config.props as UploadProps;
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
                    // 回调：统一维护 controller 文本为 JSON 字符串
                    onFileChange: (current, selected, action) {
                      props.onFileChange?.call(current, selected, action);
                    },
                  ),
                ),
                if (state.errorText != null) Positioned(bottom: 0, left: 0, child: ErrorInfo(state.errorText)),
              ],
            ),
          ],
        );
      },
    );
  }
}
