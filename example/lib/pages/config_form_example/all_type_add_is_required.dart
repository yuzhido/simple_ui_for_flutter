import 'package:example/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class AllTypeAddIsRequiredPage extends StatefulWidget {
  const AllTypeAddIsRequiredPage({super.key});
  @override
  State<AllTypeAddIsRequiredPage> createState() => _AllTypeAddIsRequiredPageState();
}

class _AllTypeAddIsRequiredPageState extends State<AllTypeAddIsRequiredPage> {
  final ConfigFormController _formController = ConfigFormController();
  final Dio _dio = Dio();

  // 模拟人员信息默认值
  final Map<String, dynamic> _personInfo = {
    'avatar': '', // 头像
    'name': '张三', // 姓名
    'nickname': '小张', // 昵称
    'age': 25, // 年龄
    'height': 175.5, // 身高
    'birthday': '1998-06-15', // 生日
    'workTime': '09:00', // 工作时间
    'joinDate': '2023-01-15 09:00', // 入职时间
    'gender': 'male', // 性别
    'hobbies': ['reading', 'music'], // 爱好
    'education': 'bachelor', // 学历
    'city': ['beijing'], // 所在城市
    'department': ['tech'], // 部门
    'bio': '热爱生活，积极向上，喜欢学习新技术。', // 个人简介
  };

  bool _showWorkFields = false;

  @override
  void initState() {
    super.initState();
    // 初始化表单数据
    _formController.setFieldValues(_personInfo);
    _updateConditionalFields(_personInfo);
  }

  void _updateConditionalFields(Map<String, dynamic> data) {
    final age = data['age'];
    final shouldShow = age != null && age is num && age > 30;
    if (shouldShow != _showWorkFields) {
      setState(() {
        _showWorkFields = shouldShow;
      });
      if (!shouldShow) {
        // 如果不显示工作时间字段，则清除其值
        _formController.setFieldValue('workTime', null);
        _formController.setFieldValue('joinDate', null);
      }
    }
  }

  // 自定义上传函数
  Future<FileUploadModel?> _customUploadFunction(String filePath, Function(double) onProgress) async {
    try {
      final file = File(filePath);
      // 创建FormData
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        'type': 'avatar', // 上传类型
      });

      // 发送请求
      final response = await _dio.request(
        '${Config.baseUrl}/upload/api/upload-file',
        data: formData,
        options: Options(method: 'POST'),
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = sent / total;
            onProgress(progress);
          }
        },
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final fileRes = response.data['data'];
        FileInfo fileInfo = FileInfo(id: fileRes['id'], fileName: fileRes['fileName'], requestPath: fileRes['requestPath']);
        return FileUploadModel(name: file.path.split('/').last, fileInfo: fileInfo, url: "fileUrl", path: file.path);
      } else {
        throw Exception('上传失败: ${response.data['message'] ?? '未知错误'}');
      }
    } catch (e) {
      throw Exception('上传失败: $e');
    }
  }

  Map<String, dynamic> _formData = {};
  void _onFormChanged(Map<String, dynamic> data) {
    setState(() {
      _formData = data;
    });
    _updateConditionalFields(data);
  }

  void _clearForm() {
    _formController.setFieldValues({});
    _formController.clearAllFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人信息表单'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConfigForm(
          controller: _formController,
          initialValues: _personInfo,
          onChanged: _onFormChanged,
          configs: [
            // 1. 头像上传
            FormConfig.upload(
              UploadFieldConfig(
                name: 'avatar',
                label: '头像',
                required: true,
                maxFiles: 1,
                allowedTypes: ['image/jpeg', 'image/png', 'image/gif'],
                maxFileSize: 5 * 1024 * 1024, // 5MB
                customUpload: _customUploadFunction,
                onFileChange: (currentFile, selectedFiles, action) {
                  if (action == 'success') {
                    _formController.setFieldValue('avatar', currentFile.fileInfo);
                  } else if (action == 'remove') {
                    _formController.setFieldValue('avatar', '');
                  }
                },
              ),
            ),

            // 2. 姓名
            FormConfig.text(TextFieldConfig(name: 'name', label: '姓名', required: true, maxLength: 20)),

            // 3. 昵称
            FormConfig.text(TextFieldConfig(name: 'nickname', label: '昵称', required: false, maxLength: 15)),

            // 4. 年龄
            FormConfig.integer(IntegerFieldConfig(name: 'age', label: '年龄', required: true, minValue: 18, maxValue: 65)),

            // 5. 身高
            FormConfig.number(NumberFieldConfig(name: 'height', label: '身高(cm)', required: false, decimalPlaces: 1, minValue: 100.0, maxValue: 250.0)),

            // 6. 生日
            FormConfig.date(DateFieldConfig(name: 'birthday', label: '生日', required: true)),

            // 7. 工作时间
            FormConfig.time(TimeFieldConfig(name: 'workTime', label: '工作时间', required: false, isShow: _showWorkFields)),

            // 8. 入职时间
            FormConfig.datetime(DateTimeFieldConfig(name: 'joinDate', label: '入职时间', required: true, isShow: _showWorkFields)),

            // 9. 性别
            FormConfig.radio<String>(
              RadioFieldConfig<String>(
                name: 'gender',
                label: '性别',
                required: true,
                options: const [
                  SelectData(label: '男', value: 'male', data: 'male'),
                  SelectData(label: '女', value: 'female', data: 'female'),
                  SelectData(label: '其他', value: 'other', data: 'other'),
                ],
                onChanged: (value, data, selectData) {},
              ),
            ),

            // 10. 爱好
            FormConfig.checkbox<String>(
              CheckboxFieldConfig<String>(
                name: 'hobbies',
                label: '爱好',
                required: false,
                options: const [
                  SelectData(label: '阅读', value: 'reading', data: 'reading'),
                  SelectData(label: '音乐', value: 'music', data: 'music'),
                  SelectData(label: '运动', value: 'sports', data: 'sports'),
                  SelectData(label: '旅行', value: 'travel', data: 'travel'),
                  SelectData(label: '摄影', value: 'photography', data: 'photography'),
                  SelectData(label: '游戏', value: 'gaming', data: 'gaming'),
                ],
                onChanged: (values, dataList, selectDataList) {},
              ),
            ),

            // 11. 学历
            FormConfig.select<String>(
              SelectFieldConfig<String>(
                name: 'education',
                label: '学历',
                required: true,
                options: const [
                  SelectData(label: '高中', value: 'high_school', data: 'high_school'),
                  SelectData(label: '大专', value: 'college', data: 'college'),
                  SelectData(label: '本科', value: 'bachelor', data: 'bachelor'),
                  SelectData(label: '硕士', value: 'master', data: 'master'),
                  SelectData(label: '博士', value: 'phd', data: 'phd'),
                ],
                onSingleChanged: (value, data, selectData) {},
              ),
            ),

            // 12. 所在城市
            FormConfig.dropdown<String>(
              DropdownFieldConfig<String>(
                name: 'city',
                label: '所在城市',
                required: true,
                multiple: true,
                options: const [
                  SelectData(label: '北京', value: 'beijing', data: 'beijing'),
                  SelectData(label: '上海', value: 'shanghai', data: 'shanghai'),
                  SelectData(label: '广州', value: 'guangzhou', data: 'guangzhou'),
                  SelectData(label: '深圳', value: 'shenzhen', data: 'shenzhen'),
                  SelectData(label: '杭州', value: 'hangzhou', data: 'hangzhou'),
                  SelectData(label: '南京', value: 'nanjing', data: 'nanjing'),
                ],
                onMultipleChanged: (values, datas, selectedList) {},
              ),
            ),

            // 13. 部门
            FormConfig.treeSelect<String>(
              TreeSelectFieldConfig<String>(
                name: 'department',
                label: '部门',
                required: false,
                multiple: true,
                checkable: true,
                options: const [
                  SelectData(
                    label: '技术部',
                    value: 'tech',
                    data: 'tech',
                    children: [
                      SelectData(label: '前端组', value: 'frontend', data: 'frontend'),
                      SelectData(label: '后端组', value: 'backend', data: 'backend'),
                      SelectData(label: '测试组', value: 'testing', data: 'testing'),
                    ],
                  ),
                  SelectData(
                    label: '产品部',
                    value: 'product',
                    data: 'product',
                    children: [
                      SelectData(label: '产品经理', value: 'pm', data: 'pm'),
                      SelectData(label: 'UI设计师', value: 'ui', data: 'ui'),
                    ],
                  ),
                  SelectData(
                    label: '运营部',
                    value: 'operation',
                    data: 'operation',
                    children: [
                      SelectData(label: '市场运营', value: 'marketing', data: 'marketing'),
                      SelectData(label: '用户运营', value: 'user', data: 'user'),
                    ],
                  ),
                ],
                onMultipleChanged: (values, datas, selectedList) {},
              ),
            ),

            // 14. 个人简介
            FormConfig.textarea(TextareaFieldConfig(name: 'bio', label: '个人简介', required: false, rows: 4, maxLength: 200)),
          ],
          submitBuilder: (formData) => const SizedBox.shrink(),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'submitForm',
            onPressed: () {
              if (_formController.validate()) {
                final data = _formController.getFormData();
                showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: const Text('表单提交成功'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('提交的数据：', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...data?.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('${e.key}: ${e.value}'))) ?? [],
                          ],
                        ),
                      ),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('确定'))],
                    );
                  },
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请检查必填项')));
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('提交表单'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'viewData',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: const Text('当前表单数据'),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._formData.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('${e.key}: ${e.value} : ${e.value.runtimeType}'))),
                        ],
                      ),
                    ),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭'))],
                  );
                },
              );
            },
            icon: const Icon(Icons.visibility),
            label: const Text('查看数据'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(heroTag: 'clearData', onPressed: _clearForm, icon: const Icon(Icons.clear), label: const Text('清除数据')),
        ],
      ),
    );
  }
}
