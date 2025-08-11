import 'package:flutter/material.dart';

class NoticeInfo extends StatefulWidget {
  final String message;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final bool enableScroll;
  final Duration scrollDuration;
  final Duration pauseDuration;

  const NoticeInfo({
    super.key,
    this.message = '恭述提示文字',
    this.onTap,
    this.padding,
    this.height,
    this.enableScroll = false,
    this.scrollDuration = const Duration(seconds: 10),
    this.pauseDuration = const Duration(seconds: 2),
  });

  @override
  State<NoticeInfo> createState() => _NoticeInfoState();
}

class _NoticeInfoState extends State<NoticeInfo> {
  late ScrollController _scrollController;
  bool _needsScroll = false;
  double _textWidth = 0.0;
  double _containerWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // 延迟检查是否需要滚动
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfScrollNeeded();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkIfScrollNeeded() {
    if (!widget.enableScroll) return;

    // 获取文本的实际宽度
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.message,
        style: const TextStyle(color: Color(0xFF424242), fontSize: 14.0, fontWeight: FontWeight.w400),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    _textWidth = textPainter.width;

    // 获取容器的可用宽度
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      _containerWidth = renderBox.size.width - 52.0; // 减去图标和间距的宽度

      if (_textWidth > _containerWidth) {
        setState(() {
          _needsScroll = true;
        });
        _startScrolling();
      }
    }
  }

  void _startScrolling() {
    if (!_needsScroll) return;

    // 开始无限循环滚动
    _startInfiniteScroll();
  }

  void _startInfiniteScroll() {
    if (!_needsScroll) return;

    // 使用更平滑的循环方式
    _animateScroll();
  }

  void _animateScroll() {
    if (!mounted || !_needsScroll) return;

    // 重置到开始位置
    _scrollController.jumpTo(0);

    // 延迟开始滚动
    Future.delayed(widget.pauseDuration, () {
      if (mounted && _needsScroll) {
        // 使用animateTo而不是jumpTo，提供更平滑的动画
        _scrollController.animateTo(_textWidth - _containerWidth, duration: widget.scrollDuration, curve: Curves.linear).then((
          _,
        ) {
          // 滚动完成后，延迟暂停时间，然后重新开始
          Future.delayed(widget.pauseDuration, () {
            if (mounted && _needsScroll) {
              _animateScroll();
            }
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: widget.height ?? 48.0,
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F4FF), // 浅紫色背景
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            // 左侧蓝色扬声器图标
            Container(
              width: 24.0,
              height: 24.0,
              child: const Icon(
                Icons.volume_up,
                color: Color(0xFF2196F3), // 蓝色
                size: 24.0,
              ),
            ),
            const SizedBox(width: 12.0), // 图标和文字之间的间距
            // 右侧中文提示文字
            Expanded(
              child: _needsScroll && widget.enableScroll
                  ? SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(), // 禁用手动滚动
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Color(0xFF424242), // 深灰色文字
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  : Text(
                      widget.message,
                      style: const TextStyle(
                        color: Color(0xFF424242), // 深灰色文字
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
