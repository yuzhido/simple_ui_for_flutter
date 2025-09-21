import 'package:flutter/material.dart';

// 头部标题区域
class HeaderTitle extends StatelessWidget {
  final String? singleTitleText;
  final String? multipleTitleText;
  final bool multiple;
  const HeaderTitle({super.key, this.singleTitleText, this.multipleTitleText, this.multiple = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            multiple == false ? (singleTitleText ?? '请选择') : (multipleTitleText ?? '请选择（可多选）'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.close, size: 20, color: Color(0xFF666666)),
            ),
          ),
        ],
      ),
    );
  }
}
