import 'package:example/api/models/user.dart';
import 'package:example/api/user_api.dart';
import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';
import 'package:simple_ui/simple_ui.dart';
import 'package:dio/dio.dart';

class FormBuilderDemo extends StatefulWidget {
  const FormBuilderDemo({super.key});

  @override
  State<FormBuilderDemo> createState() => _FormBuilderDemoState();
}

class _FormBuilderDemoState extends State<FormBuilderDemo> {
  final FormBuilderController _controller = FormBuilderController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SelectData<User>? remoteSelectedValue;
  late List<FormBuilderConfig> _configs;

  @override
  void initState() {
    super.initState();
    _initConfigs();
  }

  /// 自定义上传函数示例
  Future<FileUploadModel?> _customUploadFunction(String filePath, Function(double) onProgress) async {
    print('🚀 开始自定义上传文件: $filePath');

    try {
      final dio = Dio();
      final formData = FormData();
      final fileName = filePath.split('/').last.split('\\').last;

      formData.files.add(MapEntry('file', await MultipartFile.fromFile(filePath, filename: fileName)));

      final response = await dio.post(
        'http://192.168.1.19:3001/upload/api/upload-file',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer token123'}),
        onSendProgress: (sent, total) {
          final progress = sent / total;
          onProgress(progress);
          print('📤 上传进度: ${(progress * 100).toInt()}%');
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('✅ 上传成功: $responseData');

        // 构建完整的图片URL
        final serverUrl = responseData['url'] ?? responseData['path'] ?? 'https://picsum.photos/300/200?random=${DateTime.now().millisecondsSinceEpoch}';

        return FileUploadModel(
          fileInfo: FileInfo(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            fileName: fileName,
            requestPath: responseData['path'] ?? '', // requestPath存储服务器返回的相对路径
          ),
          name: fileName,
          path: serverUrl, // path字段存储完整的图片URL
          status: UploadStatus.success,
          progress: 1.0,
        );
      } else {
        print('❌ 上传失败: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ 上传异常: $e');
      return null;
    }
  }

  void _initConfigs() {
    _configs = [
      FormBuilderConfig(
        name: 'name',
        label: '姓名',
        type: FormBuilderType.text,
        required: true,
        defaultValue: '',
        onChange: (fieldName, value) {
          print('字段 $fieldName 值变更为: $value');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('姓名已更改为: $value'), duration: Duration(seconds: 1)));
        },
      ),
      FormBuilderConfig(
        name: 'age',
        label: '年龄',
        type: FormBuilderType.integer,
        required: true,
        defaultValue: null,
        onChange: (fieldName, value) {
          print('字段 $fieldName 值变更为: $value');
          if (value != null && value > 0) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('年龄设置为: $value 岁'), duration: Duration(seconds: 1)));
          }
        },
      ),
      FormBuilderConfig(
        name: 'salary',
        label: '薪资',
        type: FormBuilderType.number,
        required: false,
        defaultValue: null,
        onChange: (fieldName, value) {
          print('字段 $fieldName 值变更为: $value');
        },
      ),
      FormBuilderConfig(
        name: 'description',
        label: '个人描述',
        type: FormBuilderType.textarea,
        required: false,
        defaultValue: '',
        onChange: (fieldName, value) {
          print('字段 $fieldName 值变更为: $value');
        },
      ),
      FormBuilderConfig.date(
        name: 'birthday',
        label: '生日',
        required: false,
        defaultValue: null,
        valueFormat: 'yyyy-MM-dd', // 使用 ISO 格式
        onChange: (fieldName, value) {
          print('字段 $fieldName 值变更为: $value');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('生日设置为: $value'), duration: Duration(seconds: 1)));
        },
      ),
      FormBuilderConfig.time(
        name: 'workTime',
        label: '工作时间',
        required: false,
        defaultValue: null,
        valueFormat: 'HH:mm', // 24小时格式
        onChange: (fieldName, value) {
          print('字段 $fieldName 值变更为: $value');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('工作时间设置为: $value'), duration: Duration(seconds: 1)));
        },
      ),
      FormBuilderConfig.datetime(
        name: 'appointment',
        label: '预约时间',
        required: false,
        defaultValue: null,
        valueFormat: 'yyyy-MM-dd HH:mm', // 完整的日期时间格式
        onChange: (fieldName, value) {
          print('字段 $fieldName 值变更为: $value');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('预约时间设置为: $value'), duration: Duration(seconds: 1)));
        },
      ),
      FormBuilderConfig.radio(
        name: 'gender',
        label: '性别',
        required: true,
        defaultValue: null,
        options: const [
          SelectOption(label: '男', value: 'male'),
          SelectOption(label: '女', value: 'female'),
          SelectOption(label: '其他', value: 'other'),
        ],
        onChange: (fieldName, value) {
          print('字段 $fieldName 值变更为: $value');
          String genderText = value == 'male'
              ? '男'
              : value == 'female'
              ? '女'
              : '其他';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('性别选择: $genderText'), duration: Duration(seconds: 1)));
        },
      ),
      FormBuilderConfig.checkbox(
        name: 'hobbies',
        label: '爱好',
        required: false,
        defaultValue: [],
        options: const [
          SelectOption(label: '阅读', value: 'reading'),
          SelectOption(label: '运动', value: 'sports'),
          SelectOption(label: '音乐', value: 'music'),
          SelectOption(label: '旅行', value: 'travel'),
          SelectOption(label: '游戏', value: 'gaming'),
        ],
        onChange: (fieldName, value) {
          print('字段 $fieldName 值变更为: $value');
          List<dynamic> hobbies = value ?? [];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已选择 ${hobbies.length} 个爱好'), duration: Duration(seconds: 1)));
        },
      ),
      FormBuilderConfig.select(
        name: 'city',
        label: '城市',
        required: false,
        defaultValue: null,
        placeholder: '请选择城市',
        options: const [
          SelectOption(label: '北京', value: 'beijing'),
          SelectOption(label: '上海', value: 'shanghai'),
          SelectOption(label: '广州', value: 'guangzhou'),
          SelectOption(label: '深圳', value: 'shenzhen'),
          SelectOption(label: '杭州', value: 'hangzhou'),
          SelectOption(label: '成都', value: 'chengdu'),
        ],
        onChange: (fieldName, value) {
          print('字段 $fieldName 值变更为: $value');
          if (value != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('城市选择: $value'), duration: Duration(seconds: 1)));
          }
        },
      ),
      FormBuilderConfig.dropdown(
        name: 'skills',
        label: '技能',
        required: false,
        defaultValue: null,
        placeholder: '请选择技能',
        multiple: true,
        filterable: true,
        options: const [
          SelectData(label: 'Flutter', value: 'flutter'),
          SelectData(label: 'Dart', value: 'dart'),
          SelectData(label: 'React', value: 'react'),
          SelectData(label: 'Vue', value: 'vue'),
          SelectData(label: 'Angular', value: 'angular'),
          SelectData(label: 'Node.js', value: 'nodejs'),
          SelectData(label: 'Python', value: 'python'),
          SelectData(label: 'Java', value: 'java'),
        ],
        onChange: (fieldName, value) {
          print('字段 $fieldName 值变更为: $value');
          List<dynamic> skills = value ?? [];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已选择 ${skills.length} 项技能'), duration: Duration(seconds: 1)));
        },
      ),
      FormBuilderConfig.dropdown<User>(
        name: 'remoteUsers',
        label: '远程用户',
        required: false,
        remote: true,
        remoteFetch: _fetchRemoteUsers,
        defaultValue: remoteSelectedValue,
        showAdd: true,
        onAdd: (val) {
          debugPrint('添加新项: $val');
        },
        onSingleSelected: (val) {
          print(val.data);
        },
        onChange: (fieldName, value) {
          print('字段 $fieldName 值变更为: $value');
          if (value != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('远程用户已选择'), duration: Duration(seconds: 1)));
          }
        },
      ),
      FormBuilderConfig.upload(
        name: 'avatar',
        label: '头像',
        required: false,
        defaultValue: [
          FileUploadModel(
            fileInfo: FileInfo(id: 'default_1', fileName: 'default_image_1.jpg', requestPath: '/uploads/file-1758210644301-129721823.jpg'),
            name: 'default_image_1.jpg',
            path: 'http://192.168.1.19:3001/uploads/file-1758210644301-129721823.jpg',
          ),
          FileUploadModel(
            fileInfo: FileInfo(id: 'default_2', fileName: 'document.pdf', requestPath: 'http://192.168.8.188:3000/uploads/document-123456789.pdf'),
            name: 'document.pdf',
            path: 'http://192.168.8.188:3000/uploads/document-123456789.pdf',
            status: UploadStatus.success,
            progress: 1.0,
            fileSize: 2048000,
            fileSizeInfo: '2.0 MB',
          ),
          FileUploadModel(
            fileInfo: FileInfo(id: 'default_3', fileName: 'presentation.pptx', requestPath: 'http://192.168.8.188:3000/uploads/presentation-987654321.pptx'),
            name: 'presentation.pptx',
            path: 'http://192.168.8.188:3000/uploads/presentation-987654321.pptx',
            status: UploadStatus.success,
            progress: 1.0,
            fileSize: 5120000,
            fileSizeInfo: '5.0 MB',
          ),
        ],
        uploadConfig: UploadConfig(uploadUrl: 'http://192.168.1.19:3001/upload/api/upload-file', headers: {'Authorization': 'Bearer token123'}),

        fileListType: FileListType.card,
        limit: 3,
        fileSource: FileSource.imageOrCamera,
        onChange: (fieldName, value) {
          print('字段 $fieldName 值变更为: $value');
          List<dynamic> files = value ?? [];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已上传 ${files.length} 个文件'), duration: Duration(seconds: 1)));
        },
      ),
      // 自定义图标和文本的上传字段示例
      FormBuilderConfig.upload(
        name: 'customUpload',
        label: '自定义上传区域',
        required: false,
        uploadIcon: Icon(Icons.cloud_upload, size: 48, color: Colors.green),
        uploadText: Text(
          '点击或拖拽文件到这里上传\n支持多种文件格式',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        uploadConfig: UploadConfig(uploadUrl: 'http://192.168.1.19:3001/upload/api/upload-file', headers: {'Authorization': 'Bearer token123'}),
        fileListType: FileListType.textInfo,
        limit: 5,
        fileSource: FileSource.all,
        onChange: (fieldName, value) {
          print('自定义上传字段 $fieldName 值变更为: $value');
          List<dynamic> files = value ?? [];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('自定义上传区域已上传 ${files.length} 个文件'), duration: Duration(seconds: 1)));
        },
      ),
      // 使用自定义上传函数的示例
      FormBuilderConfig.upload(
        name: 'customUploadFunction',
        label: '自定义上传函数示例',
        required: false,
        customUpload: _customUploadFunction,
        fileListType: FileListType.textInfo,
        limit: 2,
        fileSource: FileSource.all,
        onChange: (fieldName, value) {
          print('自定义上传函数字段 $fieldName 值变更为: $value');
          List<dynamic> files = value ?? [];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('自定义上传函数已上传 ${files.length} 个文件'), duration: Duration(seconds: 1)));
        },
      ),
      FormBuilderConfig.custom(
        name: 'customField',
        label: '自定义字段',
        required: false,
        defaultValue: 0,
        contentBuilder: (context, config, value, onChanged) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.blue.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '这是一个自定义评分组件',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blue.shade700),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('评分: ', style: TextStyle(fontSize: 16)),
                    ...List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => onChanged(index + 1),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Icon(Icons.star, size: 32, color: (value ?? 0) > index ? Colors.amber : Colors.grey.shade300),
                        ),
                      );
                    }),
                    const SizedBox(width: 16),
                    Text('${value ?? 0}/5', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          );
        },
        onChange: (fieldName, value) {
          print('字段 $fieldName 值变更为: $value');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('评分已设置为: $value 星'), duration: const Duration(seconds: 1)));
        },
      ),
    ];
  }

  // 远程搜索用户数据
  Future<List<SelectData<User>>> _fetchRemoteUsers(String? keyword) async {
    try {
      final response = await UserApi.getUserList(page: 1, limit: 20, name: keyword?.isNotEmpty == true ? keyword : null);

      // 检查响应结构
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        // 检查data是直接数组还是包含users字段的Map
        List<dynamic> usersData;
        if (data is List) {
          // data直接是用户数组
          usersData = data;
        } else if (data is Map<String, dynamic> && data['users'] is List) {
          // data是Map，包含users字段
          usersData = data['users'];
        } else {
          return [];
        }

        if (usersData.isEmpty) {
          return [];
        }

        return usersData.map((userJson) {
          try {
            if (userJson is Map<String, dynamic>) {
              final user = User.fromJson(userJson);
              return SelectData<User>(label: '${user.name ?? '未知用户'} (${user.age ?? '未知年龄'}岁)', value: user.id ?? '', data: user);
            } else {
              return SelectData<User>(
                label: '数据格式错误',
                value: 'error',
                data: User(name: '数据格式错误', age: 0, address: '', school: '', birthday: ''),
              );
            }
          } catch (e) {
            return SelectData<User>(
              label: '解析失败的用户',
              value: 'error',
              data: User(name: '解析失败', age: 0, address: '', school: '', birthday: ''),
            );
          }
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FormBuilder 示例'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(
            child: FormBuilder(configs: _configs, controller: _controller, formKey: _formKey, autovalidate: true),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetForm,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white),
                    child: const Text('重置'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    child: const Text('提交'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _controller.reset(_configs);
    _formKey.currentState?.reset();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final values = _controller.values;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('表单数据'),
          content: SingleChildScrollView(child: Text(values.entries.map((e) => '${e.key}: ${e.value}').join('\n'))),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('确定'))],
        ),
      );
    }
  }
}
