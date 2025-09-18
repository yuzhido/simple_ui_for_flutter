import 'package:flutter/cupertino.dart';
import 'package:simple_ui/models/file_upload.dart';
import 'file_picker_utils.dart';

/// 显示文件来源选择弹窗
showFileSourceDialog(BuildContext context, {Function(FileUploadModel)? onFileSelected}) {
  return showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        title: const Text('请选择文件来源', style: TextStyle(fontSize: 16, color: CupertinoColors.secondaryLabel)),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              FilePickerUtils.pickFile(onFileSelected: onFileSelected);
            },
            child: const Row(
              children: [
                Icon(CupertinoIcons.folder, color: CupertinoColors.systemBlue),
                SizedBox(width: 12),
                Text('选择文件'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              FilePickerUtils.pickImageFromGallery(onFileSelected: onFileSelected);
            },
            child: const Row(
              children: [
                Icon(CupertinoIcons.photo_on_rectangle, color: CupertinoColors.systemBlue),
                SizedBox(width: 12),
                Text('从相册选择'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              FilePickerUtils.pickImageFromCamera(onFileSelected: onFileSelected);
            },
            child: const Row(
              children: [
                Icon(CupertinoIcons.camera, color: CupertinoColors.systemBlue),
                SizedBox(width: 12),
                Text('拍照上传'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('取消', style: TextStyle(fontSize: 18)),
        ),
      );
    },
  );
}

/// 显示图片或拍照选择弹窗（苹果风格）
showImageOrCameraDialog(BuildContext context, {Function(FileUploadModel)? onFileSelected}) {
  return showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        title: const Text('请选择', style: TextStyle(fontSize: 16, color: CupertinoColors.secondaryLabel)),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              FilePickerUtils.pickImageFromGallery(onFileSelected: onFileSelected);
            },
            child: const Row(
              children: [
                Icon(CupertinoIcons.photo_on_rectangle, color: CupertinoColors.systemBlue),
                SizedBox(width: 12),
                Text('从相册选择'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              FilePickerUtils.pickImageFromCamera(onFileSelected: onFileSelected);
            },
            child: const Row(
              children: [
                Icon(CupertinoIcons.camera, color: CupertinoColors.systemBlue),
                SizedBox(width: 12),
                Text('拍照'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('取消', style: TextStyle(fontSize: 18)),
        ),
      );
    },
  );
}
