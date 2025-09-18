import 'package:example/api/models/user.dart';
import 'package:example/api/user_api.dart';
import 'package:flutter/material.dart';
import 'package:simple_ui/models/file_upload.dart';
import 'package:simple_ui/models/form_builder_config.dart';
import 'package:simple_ui/simple_ui.dart';

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
          FileInfo(id: 111, fileName: 'default_image.jpeg', requestPath: 'http://192.168.8.188:3000/uploads/file-1758090930654-314645519.jpeg'),
          FileInfo(id: 111, fileName: 'default_image.jpeg', requestPath: 'http://192.168.8.188:3000/uploads/file-1758090930654-314645519.jpeg'),
          FileInfo(id: 111, fileName: 'default_image.jpeg', requestPath: 'http://192.168.8.188:3000/uploads/file-1758090930654-314645519.jpeg'),
        ],
        uploadText: '上传头像',
        listType: FileListType.card,
        limit: 3,
        fileSource: FileSource.imageOrCamera,
        onChange: (fieldName, value) {
          print('字段 $fieldName 值变更为: $value');
          List<dynamic> files = value ?? [];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已上传 ${files.length} 个文件'), duration: Duration(seconds: 1)));
        },
        onUploadCallback: (uploadedFile) {
          // 文件操作成功后的自定义回调函数
          print('文件操作成功: ${uploadedFile.fileName}');
          print('文件大小: ${uploadedFile.fileSize} bytes');
          print('文件路径: ${uploadedFile.filePath}');
          print('是否为图片: ${uploadedFile.isImage}');

          // 显示文件操作成功的提示
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('文件 "${uploadedFile.fileName}" 操作成功！'), duration: Duration(seconds: 2), backgroundColor: Colors.green));

          // 这里可以执行其他自定义逻辑，比如：
          // - 发送文件信息到服务器
          // - 更新其他UI状态
          // - 触发其他业务逻辑
        },
      ),
      FormBuilderConfig(name: 'customField', label: '自定义字段', type: FormBuilderType.custom, required: false, defaultValue: null),
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
