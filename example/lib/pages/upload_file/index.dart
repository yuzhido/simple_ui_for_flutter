import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';

class UploadFilePage extends StatefulWidget {
  const UploadFilePage({super.key});
  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  UploadResult? _lastResult;

  void _handleSelected(UploadResult result) {
    setState(() => _lastResult = result);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已选择: ${result.name}'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)));
  }

  Widget _buildResultPreview() {
    if (_lastResult == null) {
      return const Text('还未选择文件', style: TextStyle(color: Colors.grey));
    }

    final result = _lastResult!;
    final isImage = result.mimeType?.startsWith('image/') == true;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isImage && result.bytes != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(result.bytes!, width: 96, height: 96, fit: BoxFit.cover),
          )
        else
          Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Icon(
              result.source == UploadSource.camera
                  ? Icons.photo_camera_rounded
                  : result.source == UploadSource.image
                  ? Icons.photo_library_rounded
                  : Icons.insert_drive_file_rounded,
              color: Colors.grey.shade600,
              size: 32,
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              _InfoRow(label: '来源', value: result.source.toString().split('.').last),
              _InfoRow(label: '类型', value: result.mimeType ?? '未知'),
              if (result.size != null) _InfoRow(label: '大小', value: _formatBytes(result.size!)),
              if (result.path != null) _InfoRow(label: '路径', value: result.path!),
            ],
          ),
        ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    const unit = 1024;
    if (bytes < unit) return '$bytes B';
    final kb = bytes / unit;
    if (kb < unit) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / unit;
    if (mb < unit) return '${mb.toStringAsFixed(1)} MB';
    final gb = mb / unit;
    return '${gb.toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('上传文件示例')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('选择来源', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  // 1) 相册选图：chooseImage=true 用 svg 图片触发
                  Upload(buttonText: '相册选图', buttonIcon: Icons.photo_library_rounded, allowedSources: const {UploadSource.image}, chooseImage: true, onSelected: _handleSelected),
                  // 2) 拍照：chooseImage=true 用 svg 图片触发
                  Upload(buttonText: '拍照', buttonIcon: Icons.photo_camera_rounded, allowedSources: const {UploadSource.camera}, chooseImage: true, onSelected: _handleSelected),
                  // 3) 选择文件：默认按钮
                  Upload(buttonText: '选择文件', buttonIcon: Icons.description_rounded, allowedSources: const {UploadSource.file}, onSelected: _handleSelected),
                  // 4) 自定义触发组件
                  Upload(
                    allowedSources: const {UploadSource.image, UploadSource.camera, UploadSource.file},
                    onSelected: _handleSelected,
                    triggerBuilder: (context, isPicking) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isPicking)
                              const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            else
                              const Icon(Icons.cloud_upload_rounded, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text('自定义上传'),
                          ],
                        ),
                      );
                    },
                  ),
                  // 5) 自动选择来源（默认按钮）
                  Upload(buttonText: '自动选择来源', buttonIcon: Icons.upload_rounded, onSelected: _handleSelected),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 16),
              const Text('已选择', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _buildResultPreview(),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
