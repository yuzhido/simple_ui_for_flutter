import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:simple_ui/models/index.dart';

class UploadFile extends StatefulWidget {
  final Set<UploadSource> allowedSources;
  final void Function(UploadResult result) onSelected;

  final String buttonText;
  final IconData buttonIcon;
  final ButtonStyle? buttonStyle;
  final bool showSourceChooserWhenMultiple; // 当允许多种方式时是否弹出选择器

  // 新增：当仅相册/拍照时，是否用图片触发
  final bool chooseImage;

  // 新增：外部自定义触发组件（优先级最高）。参数为 (context, isPicking)
  final Widget Function(BuildContext context, bool isPicking)? triggerBuilder;

  const UploadFile({
    super.key,
    required this.onSelected,
    this.allowedSources = const {UploadSource.image, UploadSource.file, UploadSource.camera},
    this.buttonText = '上传文件',
    this.buttonIcon = Icons.upload_rounded,
    this.buttonStyle,
    this.showSourceChooserWhenMultiple = true,
    this.chooseImage = false,
    this.triggerBuilder,
  });

  @override
  State<UploadFile> createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isPicking = false;

  // 资源可用性：null 未检测，true 存在，false 不存在
  bool? _svgAvailable;
  static const String _svgAssetPath = 'packages/simple_ui/assets/image/icon-image.svg';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureSvgCheckedIfNeeded();
  }

  void _ensureSvgCheckedIfNeeded() {
    if (_svgAvailable != null) return;
    if (!(widget.chooseImage && _isOnlyImageSources())) return;

    // 检查包内 SVG 是否存在
    rootBundle
        .load(_svgAssetPath)
        .then((_) {
          if (mounted) setState(() => _svgAvailable = true);
        })
        .catchError((_) {
          if (mounted) setState(() => _svgAvailable = false);
        });
  }

  Future<void> _pick(UploadSource source) async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      switch (source) {
        case UploadSource.image:
          await _pickFromGallery();
          break;
        case UploadSource.file:
          await _pickFromFileSystem();
          break;
        case UploadSource.camera:
          await _takePhoto();
          break;
      }
    } catch (e) {
      _showError('选择文件失败，请稍后重试');
      debugPrint('UploadFile pick error: $e');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    widget.onSelected(
      UploadResult(source: UploadSource.image, name: picked.name, path: picked.path, bytes: bytes, size: bytes.lengthInBytes, mimeType: _guessMimeTypeFromName(picked.name)),
    );
  }

  Future<void> _takePhoto() async {
    final XFile? captured = await _imagePicker.pickImage(source: ImageSource.camera);
    if (captured == null) return;
    final bytes = await captured.readAsBytes();
    widget.onSelected(
      UploadResult(source: UploadSource.camera, name: captured.name, path: captured.path, bytes: bytes, size: bytes.lengthInBytes, mimeType: _guessMimeTypeFromName(captured.name)),
    );
  }

  Future<void> _pickFromFileSystem() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;

    final PlatformFile file = result.files.first;
    widget.onSelected(UploadResult(source: UploadSource.file, name: file.name, path: file.path, bytes: file.bytes, size: file.size, mimeType: _guessMimeTypeFromName(file.name)));
  }

  void _showChooser() {
    final List<UploadSource> sources = widget.allowedSources.toList();

    if (sources.length == 1) {
      _pick(sources.first);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
                ...sources.map((s) => _buildSourceTile(s)),
                const SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceTile(UploadSource source) {
    late final IconData icon;
    late final String title;

    switch (source) {
      case UploadSource.image:
        icon = Icons.photo_library_rounded;
        title = '从相册选择图片';
        break;
      case UploadSource.camera:
        icon = Icons.photo_camera_rounded;
        title = '拍照上传';
        break;
      case UploadSource.file:
        icon = Icons.description_rounded;
        title = '从文件中选择';
        break;
    }

    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade600),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop();
        _pick(source);
      },
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String? _guessMimeTypeFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.txt')) return 'text/plain';
    if (lower.endsWith('.doc')) return 'application/msword';
    if (lower.endsWith('.docx')) return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    if (lower.endsWith('.ppt')) return 'application/vnd.ms-powerpoint';
    if (lower.endsWith('.pptx')) return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    if (lower.endsWith('.xls')) return 'application/vnd.ms-excel';
    if (lower.endsWith('.xlsx')) return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    return null;
  }

  void _onTrigger() {
    final hasMultiple = widget.allowedSources.length > 1 && widget.showSourceChooserWhenMultiple;
    if (_isPicking) return;
    if (hasMultiple) {
      _showChooser();
    } else {
      _pick(widget.allowedSources.first);
    }
  }

  bool _isOnlyImageSources() {
    if (widget.allowedSources.isEmpty) return false;
    for (final s in widget.allowedSources) {
      if (s != UploadSource.image && s != UploadSource.camera) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // 优先使用外部自定义触发器
    if (widget.triggerBuilder != null) {
      final custom = widget.triggerBuilder!(context, _isPicking);
      return AbsorbPointer(
        absorbing: _isPicking,
        child: InkWell(onTap: _onTrigger, child: custom),
      );
    }

    // 根据 chooseImage 使用图片作为触发器（仅相册/拍照）
    if (widget.chooseImage && _isOnlyImageSources()) {
      // 如果已经检测到不存在，则回退按钮
      if (_svgAvailable == false) {
        return _buildDefaultButton();
      }
      // 启动检测后，优先显示图片；若尚未完成检测，仍尝试显示，检测失败会在下一帧回退
      return AbsorbPointer(
        absorbing: _isPicking,
        child: InkWell(
          onTap: _onTrigger,
          borderRadius: BorderRadius.circular(12),
          child: SvgPicture.asset('assets/image/icon-image.svg', package: 'simple_ui', width: 96, height: 96, fit: BoxFit.contain),
        ),
      );
    }

    // 默认按钮
    return _buildDefaultButton();
  }

  Widget _buildDefaultButton() {
    return ElevatedButton.icon(
      onPressed: _isPicking ? null : _onTrigger,
      icon: _isPicking
          ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
          : Icon(widget.buttonIcon),
      label: Text(widget.buttonText),
      style: widget.buttonStyle,
    );
  }
}
