import 'package:flutter/material.dart';
import 'package:simple_ui/models/select_data.dart';

class ChooseAsset extends StatefulWidget {
  const ChooseAsset({super.key});
  @override
  State<ChooseAsset> createState() => _ChooseAssetState();
}

class _ChooseAssetState extends State<ChooseAsset> {
  final List<SelectData<dynamic>> _selectedValues = [];
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const Dialog(child: Text('123')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: (_selectedValues.isEmpty
                  ? Text('请选择选项', style: const TextStyle(fontSize: 16, color: Color(0xFF999999)))
                  : SizedBox(
                      height: 30,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedValues.length,
                        separatorBuilder: (context, idx) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final val = _selectedValues[idx];
                          return Container(
                            alignment: Alignment(0, 0),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF4FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF007AFF)),
                            ),
                            child: Text(val.label, style: const TextStyle(fontSize: 15, color: Color(0xFF007AFF))),
                          );
                        },
                      ),
                    )),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600], size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
