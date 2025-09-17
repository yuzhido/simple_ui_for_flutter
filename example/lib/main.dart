import 'package:example/pages/data_for_form/index.dart';
import 'package:example/pages/form_builder_demo/default_value.dart';
import 'package:example/pages/loading_data/index.dart';
import 'package:example/pages/notice_info/index.dart';
import 'package:example/pages/tree_select/index.dart';
import 'package:example/pages/upload_file/index.dart';
import 'package:example/pages/database_demo/index.dart';
import 'package:example/pages/permission_request/index.dart';
import 'package:example/pages/table_show/index.dart';
import 'package:example/pages/form_builder_demo/index.dart';
import 'package:example/pages/user_list/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/dropdown_choose/index.dart';
import 'pages/cascading_select/index.dart';
import 'pages/config_form/index.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple UI 组件示例',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      supportedLocales: const [
        Locale('zh', 'CN'), // 中文
        Locale('en', 'US'), // 英文
      ],
      locale: const Locale('zh', 'CN'),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple UI 组件示例'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DropdownSelectPage())),
              child: const Text('下拉选择（DropdownChoose）示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TableShowPage())),
              child: const Text('表格展示（TableShow）示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CascadingSelectPage())),
              child: const Text('三级级联多选（CascadingSelect）示例'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TreeSelectPage()));
              },
              child: Text('跳转查看树形选择（TreeSelect）示例'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadFilePage()));
              },
              child: Text('跳转查看上传文件（UploadFile）示例'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NoticeInfoPage()));
              },
              child: Text('跳转查看消息通知（NoticeInfo）示例'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DatabaseDemoPage()));
              },
              child: Text('跳转查看数据库演示（DatabaseDemo）示例'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PermissionRequestPage()));
              },
              child: Text('跳转查看权限请求（PermissionRequest）示例'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DataForFormPage()));
              },
              child: Text('跳转查看数据驱动表单（DataForForm）示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfigFormPage()));
              },
              child: Text('跳转查看动态表单（ConfigForm）示例'),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FormBuilderDemo()));
              },
              child: Text('跳转查看数据驱动表单（FormBuilder）示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UserListPage()));
              },
              child: Text('跳转查看数据驱动表单（UserListPage）用户管理页面示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DefaultValuePage()));
              },
              child: Text('跳转查看数据驱动表单（DefaultValuePage）自定义显示表单默认值示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoadingDataPage()));
              },
              child: Text('跳转查看数据驱动表单（LoadingDataPage）加载数据示例'),
            ),
          ],
        ),
      ),
    );
  }
}
