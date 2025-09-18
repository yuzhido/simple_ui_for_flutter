import 'package:flutter/material.dart';
import 'package:simple_ui/models/file_upload.dart';
import 'package:simple_ui/src/file_upload/choose_file_source.dart';
import 'package:simple_ui/src/file_upload/file_picker_utils.dart';

class FileUpload extends StatefulWidget {
  /// 文件改变的回调
  /// 参数1: 当前操作的文件 (添加时为新文件，移除时为被移除的文件)
  /// 参数2: 当前已选择的文件列表 (操作后的最新状态)
  /// 参数3: 操作类型 ('add' 或 'remove')
  final Function(FileUploadModel currentFile, List<FileUploadModel> selectedFiles, String action)? onFileChange;

  /// 上传成功回调
  final Function(FileUploadModel file)? onUploadSuccess;

  /// 上传失败回调
  final Function(FileUploadModel file, String error)? onUploadFailed;

  /// 上传进度回调
  final Function(FileUploadModel file, double progress)? onUploadProgress;

  /// 上传配置信息
  final UploadConfig? uploadConfig;

  /// 文件来源
  final FileSource fileSource;

  /// 自定义上传文件列表样式
  final Widget? customFileList;

  /// 上传文件列表类型
  final FileListType fileListType;

  /// 文件数量限制，-1表示无限制
  final int limit;

  /// 是否显示文件列表
  final bool showFileList;

  /// 是否自动上传-默认为true
  final bool autoUpload;

  /// 上传失败时是否移除文件-默认为false
  final bool isRemoveFailFile;

  const FileUpload({
    super.key,
    this.customFileList,
    this.fileListType = FileListType.card,
    this.onFileChange,
    this.onUploadSuccess,
    this.onUploadFailed,
    this.onUploadProgress,
    this.fileSource = FileSource.all,
    this.limit = -1,
    this.showFileList = true,
    this.autoUpload = true,
    this.isRemoveFailFile = false,
    this.uploadConfig,
  });

  @override
  State<FileUpload> createState() => _FileUploadState();
}

class _FileUploadState extends State<FileUpload> {
  /// 已选择的文件列表（只保存上传成功的文件）
  List<FileUploadModel> selectedFiles = [];

  /// 临时文件列表，用于显示正在上传的文件
  List<FileUploadModel> _tempFiles = [];

  @override
  void initState() {
    super.initState();
    // 验证自动上传配置
    _validateAutoUploadConfig();
  }

  /// 验证自动上传配置
  void _validateAutoUploadConfig() {
    if (widget.autoUpload && (widget.uploadConfig == null || widget.uploadConfig!.uploadUrl == null || widget.uploadConfig!.uploadUrl!.isEmpty)) {
      throw ArgumentError('自动上传需要提供有效的上传配置，请确保 uploadConfig.uploadUrl 不为空');
    }
  }

  /// 添加文件到列表
  void _addFileToList(FileUploadModel fileModel) {
    // 检查文件数量限制（包含临时文件和已上传的文件）
    final totalFiles = _tempFiles.length + selectedFiles.length;
    if (widget.limit > 0 && totalFiles >= widget.limit) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('最多只能选择 ${widget.limit} 个文件')));
      return;
    }

    // 创建带有上传配置的文件模型
    final fileWithConfig = fileModel.copyWith(uploadConfig: widget.uploadConfig, autoUpload: widget.autoUpload);

    setState(() {
      _tempFiles.add(fileWithConfig);
    });

    // 触发回调，传递当前添加的文件、所有文件列表和操作类型
    final allFiles = [...selectedFiles, ..._tempFiles];
    widget.onFileChange?.call(fileWithConfig, allFiles, 'add');

    // 如果启用自动上传且配置有效，立即开始上传
    if (widget.autoUpload && widget.uploadConfig != null && widget.uploadConfig!.isValid) {
      _startUpload(_tempFiles.length - 1);
    }
  }

  /// 从列表中移除文件（支持从_tempFiles或selectedFiles中移除）
  void _removeFileFromList(int index, {bool fromPending = true}) {
    FileUploadModel? removedFile;

    if (fromPending && index >= 0 && index < _tempFiles.length) {
      // 从待上传列表中移除
      removedFile = _tempFiles[index];
      setState(() {
        _tempFiles.removeAt(index);
      });
    } else if (!fromPending && index >= 0 && index < selectedFiles.length) {
      // 从已上传列表中移除
      removedFile = selectedFiles[index];
      setState(() {
        selectedFiles.removeAt(index);
      });
    }

    if (removedFile != null) {
      // 触发回调，传递被移除的文件、所有文件列表和操作类型
      final allFiles = [...selectedFiles, ..._tempFiles];
      widget.onFileChange?.call(removedFile, allFiles, 'remove');
    }
  }

  /// 开始上传文件
  void _startUpload(int index) {
    if (index >= 0 && index < _tempFiles.length) {
      final file = _tempFiles[index];

      // 检查上传配置
      if (file.uploadConfig == null || !file.uploadConfig!.isValid) {
        _handleUploadError(index, '上传配置无效：缺少上传URL');
        return;
      }

      // 开始上传
      updateFileStatus(index, UploadStatus.uploading, progress: 0.0);

      // 这里应该调用真实的上传方法，目前使用模拟上传
      _simulateUpload(index);
    }
  }

  /// 处理上传错误
  void _handleUploadError(int index, String error) {
    if (index >= 0 && index < _tempFiles.length) {
      final failedFile = _tempFiles[index];

      // 如果设置了失败时移除文件，则直接移除
      if (widget.isRemoveFailFile) {
        _removeFileFromList(index, fromPending: true);
      } else {
        // 否则只更新状态为失败
        updateFileStatus(index, UploadStatus.failed);
      }

      // 触发失败回调
      widget.onUploadFailed?.call(failedFile, error);
    }
  }

  /// 处理上传成功
  void _handleUploadSuccess(int index) {
    if (index >= 0 && index < _tempFiles.length) {
      setState(() {
        // 更新文件状态为成功
        final successFile = _tempFiles[index].copyWith(status: UploadStatus.success, progress: 1.0);

        // 将文件从_tempFiles移动到selectedFiles
        selectedFiles.add(successFile);
        _tempFiles.removeAt(index);
      });

      // 触发上传成功回调
      widget.onUploadSuccess?.call(selectedFiles.last);

      // 触发文件变更回调
      final allFiles = [...selectedFiles, ..._tempFiles];
      widget.onFileChange?.call(selectedFiles.last, allFiles, 'success');
    }
  }

  /// 更新文件状态
  void updateFileStatus(int index, UploadStatus status, {double progress = 0.0}) {
    if (index >= 0 && index < _tempFiles.length) {
      setState(() {
        final oldFile = _tempFiles[index];
        _tempFiles[index] = oldFile.copyWith(status: status, progress: progress);
      });

      // 触发进度回调
      if (status == UploadStatus.uploading && widget.onUploadProgress != null) {
        widget.onUploadProgress?.call(_tempFiles[index], progress);
      }
    }
  }

  /// 根据文件ID更新状态
  void updateFileStatusById(dynamic fileId, UploadStatus status, {double progress = 0.0}) {
    final index = _tempFiles.indexWhere((file) => file.fileInfo.id == fileId);
    if (index != -1) {
      updateFileStatus(index, status, progress: progress);
    }
  }

  /// 模拟上传进度（用于演示）
  void _simulateUpload(int index) {
    if (index >= 0 && index < _tempFiles.length) {
      // 模拟上传进度
      int progressStep = 0;
      const totalSteps = 10;

      void updateProgress() {
        if (progressStep < totalSteps) {
          progressStep++;
          final progress = progressStep / totalSteps;
          updateFileStatus(index, UploadStatus.uploading, progress: progress);

          // 继续下一步
          Future.delayed(const Duration(milliseconds: 300), updateProgress);
        } else {
          // 上传完成，随机决定成功或失败
          final isSuccess = DateTime.now().millisecond % 2 == 0;
          if (isSuccess) {
            _handleUploadSuccess(index);
          } else {
            _handleUploadError(index, '模拟上传失败');
          }
        }
      }

      // 开始进度更新
      Future.delayed(const Duration(milliseconds: 500), updateProgress);
    }
  }

  /// 根据fileSource决定交互方式
  void _handleFileSelection() {
    switch (widget.fileSource) {
      case FileSource.file:
        // 只允许选择文件，直接调用文件选择
        FilePickerUtils.pickFile(onFileSelected: _addFileToList);
        break;
      case FileSource.image:
        // 只允许选择图片，直接调用相册选择
        FilePickerUtils.pickImageFromGallery(onFileSelected: _addFileToList);
        break;
      case FileSource.camera:
        // 只允许拍照，直接调用摄像头
        FilePickerUtils.pickImageFromCamera(onFileSelected: _addFileToList);
        break;
      case FileSource.imageOrCamera:
        // 允许选择图片或拍照，显示包含这两个选项的弹窗
        showImageOrCameraDialog(context, onFileSelected: _addFileToList);
        break;
      case FileSource.all:
        // 允许所有类型，显示完整的选择弹窗
        showFileSourceDialog(context, onFileSelected: _addFileToList);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 当前布局的最大宽度
        final maxWidth = constraints.maxWidth;
        // 卡片模式每一个卡片的宽度
        final width = (maxWidth - 20) / 3;

        // 合并所有文件列表用于显示
        final allFiles = [..._tempFiles, ...selectedFiles];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 文件列表展示
            if (widget.showFileList && allFiles.isNotEmpty) ...[
              if (widget.fileListType == FileListType.card)
                // 卡片模式
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    // 所有文件（待上传和已上传）
                    ...allFiles.asMap().entries.map((entry) {
                      final index = entry.key;
                      final fileModel = entry.value;
                      final isPending = index < _tempFiles.length;
                      return GestureDetector(
                        onTap: () {
                          // 演示：点击文件项模拟上传
                          if (fileModel.status == UploadStatus.pending && isPending) {
                            _simulateUpload(index);
                          }
                        },
                        child: FilePickerUtils.buildCardFileItem(
                          fileModel,
                          isPending ? index : index - _tempFiles.length,
                          width,
                          isPending ? (idx) => _removeFileFromList(idx, fromPending: true) : (idx) => _removeFileFromList(idx, fromPending: false),
                        ),
                      );
                    }),
                    // 上传按钮（如果未达到限制）
                    if (widget.limit == -1 || allFiles.length < widget.limit)
                      GestureDetector(
                        onTap: _handleFileSelection,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          width: width,
                          height: width,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.grey.shade600, size: 40),
                              const SizedBox(height: 4),
                              Text('添加文件', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                  ],
                )
              else
                // 文本信息模式
                Column(
                  children: [
                    ...allFiles.asMap().entries.map((entry) {
                      final index = entry.key;
                      final fileModel = entry.value;
                      final isPending = index < _tempFiles.length;
                      return GestureDetector(
                        onTap: () {
                          // 演示：点击文件项模拟上传
                          if (fileModel.status == UploadStatus.pending && isPending) {
                            _simulateUpload(index);
                          }
                        },
                        child: FilePickerUtils.buildTextInfoFileItem(
                          fileModel,
                          isPending ? index : index - _tempFiles.length,
                          isPending ? (idx) => _removeFileFromList(idx, fromPending: true) : (idx) => _removeFileFromList(idx, fromPending: false),
                        ),
                      );
                    }),
                    // 上传按钮（如果未达到限制）
                    if (widget.limit == -1 || allFiles.length < widget.limit)
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton.icon(onPressed: _handleFileSelection, icon: const Icon(Icons.add), label: const Text('添加文件')),
                      ),
                  ],
                ),
            ],

            // 初始上传区域（当没有文件时显示）
            if (allFiles.isEmpty) ...[
              if (widget.fileListType == FileListType.textInfo || widget.fileListType == FileListType.custom)
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton.icon(onPressed: _handleFileSelection, icon: const Icon(Icons.upload_file), label: const Text('选择文件')),
                )
              else if (widget.fileListType == FileListType.card)
                GestureDetector(
                  onTap: _handleFileSelection,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    width: width,
                    height: width,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 上传文件图标
                        Icon(Icons.camera_enhance_outlined),
                        // 上传标题
                        const SizedBox(height: 4), Text('拍照上传'),
                      ],
                    ),
                  ),
                ),
            ],

            // 自定义文件列表
            if (widget.customFileList != null) widget.customFileList!,
          ],
        );
      },
    );
  }
}

///
///1.要求可以自定义上传方法,也就是选择文件或者拍照之后将文件通过回调函数传出去等待自定义上传
///2.支持默认的上传方法,也就是直接将文件上传到指定的url
///3.支持自定义请求头
///4.支持自定义上传成功的回调函数
///5.上传成功的回调
///6.上传失败的回调
///7.支持上传进度的回调
///8.文件改变的回调(无论成功还是失败都要调用)
///9.上传文件列表展示类型(默认展示文件名称和大小,可以自定义展示)-卡片模式,文子列表模式
///10.支持删除文件
///11.卡片模式的卡片大小
///12.支持上传图片数量控制.默认-1,可以传递无限,给定指定数量就控制上传文件的数量
///13.文件来源控制
///14.默认文件列表
///15.icon上传文件图标,图标大小
///16.自定义上传文本信息
///
