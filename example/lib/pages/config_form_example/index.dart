import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_type.dart';
import 'package:simple_ui/simple_ui.dart';
import 'package:dio/dio.dart';
import '../../../utils/config.dart';

class ConfigFormExamplePage extends StatefulWidget {
  const ConfigFormExamplePage({super.key});
  @override
  State<ConfigFormExamplePage> createState() => _ConfigFormExamplePageState();
}

class _ConfigFormExamplePageState extends State<ConfigFormExamplePage> {
  late ConfigFormController _controller;
  Map<String, dynamic> _formData = {};
  String _uploadStatus = '等待上传...';

  @override
  void initState() {
    super.initState();
    _controller = ConfigFormController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 真实接口上传函数
  Future<FileUploadModel?> _realUploadFunction(String filePath, Function(double) onProgress) async {
    try {
      final dio = Dio();

      // 准备FormData
      final formData = FormData.fromMap({'file': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last)});

      // 发送请求
      final response = await dio.request(
        '${Config.baseUrl}/upload/api/upload-file',
        data: formData,
        options: Options(method: 'POST', headers: {'Authorization': 'Bearer your-token-here'}),
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = sent / total;
            onProgress(progress);
          }
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return FileUploadModel(
          name: filePath.split('/').last,
          path: filePath,
          source: FileSource.file,
          status: UploadStatus.success,
          progress: 1.0,
          fileSize: responseData['size'] ?? 0,
          fileSizeInfo: _formatFileSize(responseData['size'] ?? 0),
          url: responseData['url'] ?? '',
          fileInfo: FileInfo(
            id: responseData['id'] ?? DateTime.now().millisecondsSinceEpoch,
            fileName: responseData['filename'] ?? filePath.split('/').last,
            requestPath: responseData['path'] ?? '',
          ),
        );
      }
      return null;
    } catch (e) {
      print('上传失败: $e');
      return null;
    }
  }

  // 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  // 表单配置
  List<FormConfig> get _formConfigs {
    // 检查性别字段的值，决定是否显示爱好字段
    final genderValue = _controller.getValue<String?>('gender');
    final shouldShowHobbies = genderValue == 'male';

    return [
      // 真实接口文件上传示例
      FormConfig(
        type: FormType.upload,
        name: 'realUploadFile',
        label: '真实接口文件上传',
        required: true,
        validator: (value) {
          if (value == null || (value is List && value.isEmpty)) {
            return '请上传文件';
          }
          return null;
        },
        props: UploadProps(
          maxFiles: 2,
          fileListType: FileListType.card,
          fileSource: FileSource.all,
          autoUpload: true,
          isRemoveFailFile: false,
          // 使用真实接口上传
          customUpload: _realUploadFunction,

          // 上传进度回调
        ),
      ),
      // 文件上传
      FormConfig(
        type: FormType.upload,
        name: 'fileInfo',
        label: '模拟文件上传',
        required: true,
        validator: (value) {
          // 自定义验证器：检查是否上传了文件
          if (value == null || (value is List && value.isEmpty)) {
            return '请上传文件';
          }
          return null; // 验证通过
        },
        props: UploadProps(
          maxFiles: 3, // 最多上传3个文件
          fileListType: FileListType.card, // 卡片样式
          fileSource: FileSource.all, // 允许所有类型文件
          autoUpload: true, // 自动上传
          isRemoveFailFile: false, // 上传失败时不自动移除
          // 自定义上传函数
          customUpload: (filePath, onProgress) async {
            // 模拟上传过程
            print('开始上传文件: $filePath');

            // 模拟上传进度
            for (int i = 0; i <= 100; i += 10) {
              await Future.delayed(Duration(milliseconds: 100));
              onProgress(i / 100.0);
            }

            // 模拟上传成功，返回文件信息
            return FileUploadModel(
              name: filePath.split('/').last,
              path: filePath,
              source: FileSource.file,
              status: UploadStatus.success,
              progress: 1.0,
              fileSize: 1024 * 1024, // 1MB
              fileSizeInfo: '1.0MB',
              url: 'https://example.com/uploads/${filePath.split('/').last}',
              fileInfo: FileInfo(id: DateTime.now().millisecondsSinceEpoch, fileName: filePath.split('/').last, requestPath: '/uploads/${filePath.split('/').last}'),
            );
          },
          // 文件变化回调
          onFileChange: (current, selected, action) {
            print('文件变化: $action, 当前文件: ${current.name}, 总文件数: ${selected.length}');
          },
        ),
      ),
      FormConfig(
        type: FormType.text,
        name: 'username',
        label: '用户名',
        required: true,
        defaultValue: 'admin',
        validator: (value) {
          // 自定义验证器示例：用户名不能包含特殊字符
          final username = value?.toString() ?? '';
          if (username.isEmpty) {
            return '请输入用户名';
          }
          if (username.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
            return '用户名不能包含特殊字符';
          }
          return null; // 验证通过
        },
        props: const TextFieldProps(minLength: 3, maxLength: 20, keyboardType: TextInputType.text),
      ),
      FormConfig(
        type: FormType.dropdown,
        name: 'gender',
        label: '性别',
        required: true,
        props: DropdownProps<String>(
          options: const [
            SelectData(label: '男', value: 'male', data: '男性'),
            SelectData(label: '女', value: 'female', data: '女性'),
            SelectData(label: '其他', value: 'other', data: '其他'),
          ],
        ),
      ),
      FormConfig(
        type: FormType.dropdown,
        name: 'hobbies',
        label: '爱好',
        required: true,
        isShow: shouldShowHobbies, // 根据性别字段的值动态控制显示
        props: DropdownProps<String>(
          multiple: true,
          options: const [
            SelectData(label: '阅读', value: 'reading', data: '阅读'),
            SelectData(label: '音乐', value: 'music', data: '音乐'),
            SelectData(label: '运动', value: 'sports', data: '运动'),
            SelectData(label: '旅行', value: 'travel', data: '旅行'),
            SelectData(label: '摄影', value: 'photography', data: '摄影'),
          ],
        ),
      ),

      // 数字输入
      FormConfig(
        type: FormType.number,
        name: 'price',
        label: '价格',
        required: true,
        defaultValue: 99.99,
        validator: (value) {
          // 自定义验证器示例：价格验证
          final priceStr = value?.toString() ?? '';
          if (priceStr.isEmpty) {
            return '请输入价格';
          }
          final price = double.tryParse(priceStr);
          if (price == null) {
            return '请输入有效的价格';
          }
          if (price > 5000) {
            return '价格不能超过5000元';
          }
          return null; // 验证通过
        },
        props: const NumberProps(minValue: 0, maxValue: 9999.99, decimalPlaces: 2),
      ),

      // 整数输入（使用默认验证）
      FormConfig(type: FormType.integer, name: 'quantity', label: '数量', required: true, defaultValue: 1, props: const IntegerProps(minValue: 1, maxValue: 100)),

      // 多行文本（非必填，不会进行验证）
      FormConfig(type: FormType.textarea, name: 'description', label: '描述', required: false, defaultValue: '这是一个示例描述', props: const TextareaProps(rows: 4, maxLength: 500)),

      // 多选
      FormConfig(
        type: FormType.checkbox,
        name: 'hobbies_checkbox',
        label: '爱好（多选）',
        required: false,
        defaultValue: ['reading', 'music'],
        isShow: shouldShowHobbies, // 根据性别字段的值动态控制显示
        props: CheckboxProps<String>(
          options: const [
            SelectData(label: '阅读', value: 'reading', data: '阅读'),
            SelectData(label: '音乐', value: 'music', data: '音乐'),
            SelectData(label: '运动', value: 'sports', data: '运动'),
            SelectData(label: '旅行', value: 'travel', data: '旅行'),
            SelectData(label: '摄影', value: 'photography', data: '摄影'),
          ],
        ),
      ),

      // 下拉选择（使用默认验证）
      FormConfig(
        type: FormType.dropdown,
        name: 'city',
        label: '城市',
        required: true,
        defaultValue: SelectData(label: '北京', value: 'beijing', data: '北京市'),
        props: DropdownProps(
          options: const [
            SelectData<String>(label: '北京', value: 'beijing', data: '北京市'),
            SelectData<String>(label: '上海', value: 'shanghai', data: '上海市'),
            SelectData<String>(label: '广州', value: 'guangzhou', data: '广州市'),
            SelectData<String>(label: '深圳', value: 'shenzhen', data: '深圳市'),
            SelectData<String>(label: '杭州', value: 'hangzhou', data: '杭州市'),
          ],
        ),
      ),

      // 日期选择
      FormConfig(
        type: FormType.date,
        name: 'birthday',
        label: '生日',
        required: false,
        defaultValue: '1990-01-01',
        props: const DateProps(format: 'YYYY-MM-DD'),
      ),

      // 时间选择
      FormConfig(
        type: FormType.time,
        name: 'meeting_time',
        label: '会议时间',
        required: false,
        defaultValue: '14:30',
        props: const TimeProps(format: 'HH:mm'),
      ),

      // 日期时间选择
      FormConfig(
        type: FormType.datetime,
        name: 'created_at',
        label: '创建时间',
        required: false,
        defaultValue: '2024-01-01 10:00',
        props: const DateTimeProps(format: 'YYYY-MM-DD HH:mm'),
      ),
    ];
  }

  // 表单数据变化回调
  void _onFormChanged(Map<String, dynamic> data) {
    setState(() {
      _formData = data;
    });
    print('表单数据变化: $data');

    // 如果性别字段发生变化，需要重新构建表单以更新爱好字段的显示状态
    if (data.containsKey('gender')) {
      // 性别字段变化，重新构建表单
      setState(() {});
    }
  }

  // 提交表单
  void _submitForm() {
    // 进行表单验证（现在不需要传参了！）
    final isValid = _controller.validate();
    setState(() {});
    if (!isValid) return;

    // 验证通过，显示提交结果
    final formData = _controller.formData;
    print('提交表单数据: $formData');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('表单提交成功'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('提交的数据:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...formData.entries.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('${entry.key}: ${entry.value}'))),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('确定'))],
      ),
    );
  }

  // 重置表单
  void _resetForm() {
    _controller.reset();
    setState(() {
      _formData = {};
    });
  }

  // 清除表单
  void _clearForm() {
    _controller.clearAllFields();
    setState(() {
      _formData = {};
    });
  }

  // 设置默认值
  void _setDefaultValues() {
    final defaultValues = {
      'username': 'test_user',
      'gender': 'male',
      'hobbies': ['reading', 'music'],
      'price': 199.99,
      'quantity': 5,
      'description': '这是设置的默认描述',
      'city': 'beijing',
      'birthday': '1995-05-15',
      'meeting_time': '09:30',
      'created_at': '2024-12-01 15:30',
    };
    _controller.setFieldValues(defaultValues);
    setState(() {
      _formData = _controller.formData;
    });
  }

  // 查看表单数据
  void _viewFormData() {
    final formData = _controller.formData;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('当前表单数据'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('当前数据:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...formData.entries.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('${entry.key}: ${entry.value}'))),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('确定'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ConfigForm 示例'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 表单标题
            const Text('ConfigForm 组件使用示例', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // 表单组件
            ConfigForm(configs: _formConfigs, controller: _controller, onChanged: _onFormChanged),

            const SizedBox(height: 16),

            // 上传状态显示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '上传状态: $_uploadStatus',
                      style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 实时数据显示
            if (_formData.isNotEmpty) ...[
              const Text('实时表单数据:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _formData.entries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('${entry.key}: ${entry.value}', style: const TextStyle(fontFamily: 'monospace')),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Wrap(
        children: [
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('提交表单'),
          ),
          ElevatedButton(
            onPressed: _clearForm,
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('清除表单'),
          ),
          ElevatedButton(
            onPressed: _setDefaultValues,
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('设置默认值'),
          ),
          ElevatedButton(
            onPressed: _resetForm,
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('重置表单'),
          ),
          ElevatedButton(
            onPressed: _viewFormData,
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('查看表单数据'),
          ),
        ],
      ),
    );
  }
}
