// import 'package:flutter/material.dart';
// import 'package:simple_ui/simple_ui.dart';

// class AssetTransferPage extends StatefulWidget {
//   const AssetTransferPage({super.key});
//   @override
//   State<AssetTransferPage> createState() => _AssetTransferPageState();
// }

// class _AssetTransferPageState extends State<AssetTransferPage> {
//   late final FormConfig formConfig;

//   @override
//   void initState() {
//     super.initState();

//     // 创建FormConfig对象
//     formConfig = FormConfig(
//       fields: [
//         FormFieldConfig(
//           label: '接收人',
//           name: 'receiverId',
//           type: FormFieldType.dropdown, // 使用下拉选择
//           required: true,
//           defaultValue: SelectData(label: '张三', value: '1', data: 'null'),
//           dropdownFieldProps: DropdownFieldProps(
//             remote: true,
//             remoteFetch: _fetchRemoteData, // 远程搜索
//           ),
//         ),

//         FormFieldConfig(
//           label: '移交原因',
//           name: 'description',
//           type: FormFieldType.textarea,
//           required: false,
//           textareaFieldProps: TextareaFieldProps(placeholder: '请输入移交原因'),
//         ),

//         // 提交和重置按钮
//         FormFieldConfig(label: '提交', name: 'submit', type: FormFieldType.button, required: false, buttonFieldProps: ButtonFieldProps()),
//       ],
//     );
//   }

//   // 模拟远程搜索接口
//   Future<List<SelectData<dynamic>>> _fetchRemoteData(String? keyword) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     final all = <SelectData<dynamic>>[
//       SelectData(label: '张三', value: '1', data: '5656'),
//       SelectData(label: '李四', value: '2', data: '54354'),
//       SelectData(label: '王五', value: '3', data: 'n544435ull'),
//       SelectData(label: '赵六', value: '4', data: '56'),
//     ];
//     if (keyword == null || keyword.trim().isEmpty) return all;
//     final k = keyword.trim();
//     return all.where((e) => e.label.contains(k)).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('资产移交')),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // 使用动态表单组件
//             ConfigForm(
//               formConfig: formConfig,
//               onSubmit: (data) {
//                 print(data['receiverId'].label);
//                 print(data['receiverId'].value);
//                 print(data['receiverId'].data);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class AssetTransferPage extends StatefulWidget {
  const AssetTransferPage({super.key});
  @override
  State<AssetTransferPage> createState() => _AssetTransferPageState();
}

class _AssetTransferPageState extends State<AssetTransferPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导航栏标题')),
      body: const Text('页面内容正在开发中...'),
    );
  }
}
