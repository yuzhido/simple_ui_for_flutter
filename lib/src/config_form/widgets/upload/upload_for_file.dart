import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:simple_ui/models/field_configs.dart';
import 'package:simple_ui/models/file_upload.dart';
import 'package:simple_ui/src/config_form/utils/validation_utils.dart';
import 'package:simple_ui/src/config_form/widgets/index.dart';
import 'package:simple_ui/src/file_upload/index.dart';
import '../base_field_widget.dart';

class UploadForFile extends BaseFieldWidget {
  const UploadForFile({super.key, required super.config, required super.controller, required super.onChanged});

  @override
  Widget buildField(BuildContext context) {
    final UploadFieldConfig uploadField = config.config as UploadFieldConfig;

    // 解析默认值
    final List<FileUploadModel> defaultFiles = _parseDefaultValue(config.defaultValue);
    // 初始化 controller（用于 required 校验与表单值收集）
    final initialSerialized = _serializeFiles(defaultFiles);
    final initialValueForForm = controller.text.isNotEmpty ? controller.text : initialSerialized;
    if (controller.text.isEmpty && initialValueForForm.isNotEmpty) {
      controller.text = initialValueForForm;
      onChanged(initialValueForForm);
    }

    // 构造上传配置
    final UploadConfig? uploadConfig = uploadField.uploadUrl != null && uploadField.uploadUrl!.isNotEmpty ? UploadConfig(uploadUrl: uploadField.uploadUrl) : null;

    return FormField<String>(
      initialValue: initialValueForForm,
      validator: (value) {
        // 复用通用校验：对 required 生效
        final validator = ValidationUtils.getValidator(config);
        return validator?.call(value);
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 18),
                  child: FileUpload(
                    // 数量限制
                    limit: uploadField.maxFiles ?? -1,
                    fileListType: uploadField.fileListType,
                    fileSource: uploadField.fileSource,
                    // 自动上传：仅当提供了uploadUrl或customUpload时生效
                    autoUpload: uploadField.autoUpload && (uploadConfig != null || uploadField.customUpload != null),
                    // 上传配置与行为
                    uploadConfig: uploadConfig,
                    isRemoveFailFile: uploadField.isRemoveFailFile,
                    customUpload: uploadField.customUpload,
                    // 默认文件（显示已上传）
                    defaultValue: defaultFiles.isEmpty ? null : defaultFiles,
                    // 回调：统一维护 controller 文本为 JSON 字符串
                    onFileChange: (current, selected, action) {
                      final serialized = _serializeFiles(selected);
                      controller.text = serialized;
                      onChanged(serialized);
                      state.didChange(serialized);
                      uploadField.onFileChange?.call(current, selected, action);
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

  List<FileUploadModel> _parseDefaultValue(dynamic defaultValue) {
    if (defaultValue == null) return [];
    if (defaultValue is List<FileUploadModel>) return List<FileUploadModel>.from(defaultValue);
    if (defaultValue is List) {
      // 尝试从 List<Map> 构造
      try {
        return defaultValue
            .map((e) {
              if (e is FileUploadModel) return e;
              if (e is Map<String, dynamic>) return FileUploadModel.fromMap(e);
              return null;
            })
            .whereType<FileUploadModel>()
            .toList();
      } catch (_) {}
    }
    if (defaultValue is String && defaultValue.trim().isNotEmpty) {
      // 尝试从 JSON 字符串解析
      try {
        final decoded = jsonDecode(defaultValue);
        if (decoded is List) {
          return decoded.map((e) => FileUploadModel.fromMap(Map<String, dynamic>.from(e as Map))).toList();
        }
      } catch (_) {}
    }
    return [];
  }

  String _serializeFiles(List<FileUploadModel> files) {
    if (files.isEmpty) return '';
    final list = files.map((e) => e.toMap()).toList();
    return jsonEncode(list);
  }
}
