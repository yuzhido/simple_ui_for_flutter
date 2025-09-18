import 'package:flutter/material.dart';
import 'package:simple_ui/models/file_upload.dart';
import 'package:simple_ui/simple_ui.dart';

class DataForFormPage extends StatefulWidget {
  const DataForFormPage({super.key});
  @override
  State<DataForFormPage> createState() => _DataForFormPageState();
}

class _DataForFormPageState extends State<DataForFormPage> {
  final ConfigFormController _controller = ConfigFormController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('配置表单使用示例')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 示例1：直接使用（无默认值）
            _buildSectionTitle('示例1：直接使用（无默认值）'),
            const SizedBox(height: 16),
            _buildBasicForm(),
            const SizedBox(height: 32),

            // 示例2：有默认值
            _buildSectionTitle('示例2：有默认值'),
            const SizedBox(height: 16),
            _buildFormWithDefaults(),
            const SizedBox(height: 32),

            // 示例3：使用控制器
            _buildSectionTitle('示例3：使用控制器'),
            const SizedBox(height: 16),
            _buildFormWithController(),
            const SizedBox(height: 32),

            // 示例4：使用FormFieldType直接配置
            _buildSectionTitle('示例4：使用FormFieldType直接配置'),
            const SizedBox(height: 16),
            _buildFormWithFieldType(),
            const SizedBox(height: 32),

            // 示例5：从后端获取数据回显
            _buildSectionTitle('示例5：从后端获取数据回显'),
            const SizedBox(height: 16),
            _buildFormWithBackendData(),
            const SizedBox(height: 32),

            // 显示当前表单值
            _buildSectionTitle('当前表单值'),
            const SizedBox(height: 16),
            _buildFormValues(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
    );
  }

  // 示例1：基础表单（无默认值）
  Widget _buildBasicForm() {
    final formConfig = FormConfig(
      fields: [
        FormFieldConfig.text(name: 'name', label: '姓名', placeholder: '请输入姓名', required: true),
        FormFieldConfig.number(name: 'age', label: '年龄', placeholder: '请输入年龄', required: true),
        FormFieldConfig.select(
          name: 'gender',
          label: '性别',
          placeholder: '请选择性别',
          required: true,
          props: SelectFieldProps(
            options: const [
              SelectData(label: '男', value: 'male', data: 'male'),
              SelectData(label: '女', value: 'female', data: 'female'),
            ],
          ),
        ),
        FormFieldConfig.textarea(name: 'description', label: '个人描述', placeholder: '请输入个人描述', props: const TextareaFieldProps(maxLines: 3)),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ConfigForm(formConfig: formConfig),
    );
  }

  // 示例2：有默认值的表单
  Widget _buildFormWithDefaults() {
    final formConfig = FormConfig(
      fields: [
        FormFieldConfig.text(name: 'username', label: '用户名', placeholder: '请输入用户名', defaultValue: 'admin', required: true),
        FormFieldConfig.number(name: 'score', label: '分数', placeholder: '请输入分数', defaultValue: 85.5, required: true),
        FormFieldConfig.radio(
          name: 'level',
          label: '等级',
          defaultValue: 'intermediate',
          required: true,
          props: const RadioFieldProps(
            options: [
              SelectData(label: '初级', value: 'beginner', data: 'beginner'),
              SelectData(label: '中级', value: 'intermediate', data: 'intermediate'),
              SelectData(label: '高级', value: 'advanced', data: 'advanced'),
            ],
          ),
        ),
        FormFieldConfig.checkbox(
          name: 'skills',
          label: '技能',
          defaultValue: ['flutter', 'dart'],
          props: const CheckboxFieldProps(
            options: [
              SelectData(label: 'Flutter', value: 'flutter', data: 'flutter'),
              SelectData(label: 'Dart', value: 'dart', data: 'dart'),
              SelectData(label: 'React', value: 'react', data: 'react'),
              SelectData(label: 'Vue', value: 'vue', data: 'vue'),
            ],
          ),
        ),
        FormFieldConfig.date(name: 'birthday', label: '生日', placeholder: '请选择生日', defaultValue: '1990年1月1日'),
        FormFieldConfig.time(name: 'workTime', label: '工作时间', placeholder: '请选择工作时间', defaultValue: '09:00'),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ConfigForm(formConfig: formConfig),
    );
  }

  // 示例3：使用控制器的表单
  Widget _buildFormWithController() {
    final formConfig = FormConfig(
      fields: [
        FormFieldConfig.text(name: 'email', label: '邮箱', placeholder: '请输入邮箱', required: true),
        FormFieldConfig.integer(name: 'phone', label: '电话', placeholder: '请输入电话号码', required: true),
        FormFieldConfig.dropdown(
          name: 'city',
          label: '城市',
          required: true,
          props: DropdownFieldProps(
            options: const [
              SelectData(label: '北京', value: 'beijing', data: 'beijing'),
              SelectData(label: '上海', value: 'shanghai', data: 'shanghai'),
              SelectData(label: '广州', value: 'guangzhou', data: 'guangzhou'),
              SelectData(label: '深圳', value: 'shenzhen', data: 'shenzhen'),
            ],
            filterable: true,
            placeholderText: '请选择城市',
          ),
        ),
        FormFieldConfig.upload(
          name: 'avatar',
          label: '头像',
          props: const UploadFieldProps(uploadText: '上传头像', limit: 1),
        ),
      ],
    );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ConfigForm(formConfig: formConfig, controller: _controller, formKey: _formKey),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('表单验证通过！')));
                }
              },
              child: const Text('验证表单'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                _controller.clear();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('表单已清空')));
              },
              child: const Text('清空表单'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                _controller.setValues({'email': 'test@example.com', 'phone': '13800138000', 'city': 'beijing'});
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已设置默认值')));
              },
              child: const Text('设置默认值'),
            ),
          ],
        ),
      ],
    );
  }

  // 示例4：使用FormFieldType直接配置
  Widget _buildFormWithFieldType() {
    final formConfig = FormConfig(
      fields: [
        // 文本输入 - 使用FormFieldType直接配置
        const FormFieldConfig(name: 'productName', type: FormFieldType.text, label: '产品名称', placeholder: '请输入产品名称', required: true, defaultValue: 'Flutter开发工具'),
        // 数字输入 - 使用FormFieldType直接配置
        const FormFieldConfig(name: 'price', type: FormFieldType.number, label: '价格', placeholder: '请输入价格', required: true, defaultValue: 99.99),
        // 整数输入 - 使用FormFieldType直接配置
        const FormFieldConfig(name: 'stock', type: FormFieldType.integer, label: '库存数量', placeholder: '请输入库存数量', required: true, defaultValue: 100),
        // 文本域 - 使用FormFieldType直接配置
        const FormFieldConfig(
          name: 'description',
          type: FormFieldType.textarea,
          label: '产品描述',
          placeholder: '请输入产品描述',
          props: TextareaFieldProps(maxLines: 4),
          defaultValue: '这是一个优秀的产品，具有以下特点：\n1. 功能强大\n2. 易于使用\n3. 性能卓越',
        ),
        // 单选按钮 - 使用FormFieldType直接配置
        const FormFieldConfig(
          name: 'category',
          type: FormFieldType.radio,
          label: '产品分类',
          required: true,
          defaultValue: 'software',
          props: RadioFieldProps(
            options: [
              SelectData(label: '软件', value: 'software', data: 'software'),
              SelectData(label: '硬件', value: 'hardware', data: 'hardware'),
              SelectData(label: '服务', value: 'service', data: 'service'),
            ],
          ),
        ),
        // 复选框 - 使用FormFieldType直接配置
        const FormFieldConfig(
          name: 'tags',
          type: FormFieldType.checkbox,
          label: '产品标签',
          defaultValue: ['mobile', 'cross-platform'],
          props: CheckboxFieldProps(
            options: [
              SelectData(label: '移动端', value: 'mobile', data: 'mobile'),
              SelectData(label: '跨平台', value: 'cross-platform', data: 'cross-platform'),
              SelectData(label: '开源', value: 'open-source', data: 'open-source'),
              SelectData(label: '免费', value: 'free', data: 'free'),
            ],
          ),
        ),
        // 下拉选择 - 使用FormFieldType直接配置
        const FormFieldConfig(
          name: 'status',
          type: FormFieldType.select,
          label: '产品状态',
          placeholder: '请选择产品状态',
          required: true,
          defaultValue: 'active',
          props: SelectFieldProps(
            options: [
              SelectData(label: '上架', value: 'active', data: 'active'),
              SelectData(label: '下架', value: 'inactive', data: 'inactive'),
              SelectData(label: '维护中', value: 'maintenance', data: 'maintenance'),
            ],
          ),
        ),
        // 自定义下拉选择 - 使用FormFieldType直接配置
        const FormFieldConfig(
          name: 'priority',
          type: FormFieldType.dropdown,
          label: '优先级',
          required: true,
          props: DropdownFieldProps(
            options: [
              SelectData(label: '高', value: 'high', data: 'high'),
              SelectData(label: '中', value: 'medium', data: 'medium'),
              SelectData(label: '低', value: 'low', data: 'low'),
            ],
            filterable: true,
            placeholderText: '请选择优先级',
            defaultValue: SelectData(label: '高', value: 'high', data: 'high'),
          ),
        ),
        // 日期选择 - 使用FormFieldType直接配置
        const FormFieldConfig(name: 'releaseDate', type: FormFieldType.date, label: '发布日期', placeholder: '请选择发布日期', defaultValue: '2024年1月1日'),
        // 时间选择 - 使用FormFieldType直接配置
        const FormFieldConfig(name: 'updateTime', type: FormFieldType.time, label: '更新时间', placeholder: '请选择更新时间', defaultValue: '14:30'),
        // 日期时间选择 - 使用FormFieldType直接配置
        const FormFieldConfig(name: 'lastModified', type: FormFieldType.datetime, label: '最后修改时间', placeholder: '请选择最后修改时间', defaultValue: '2024年1月1日 14:30'),
        // 文件上传 - 使用FormFieldType直接配置
        const FormFieldConfig(
          name: 'productImages',
          type: FormFieldType.upload,
          label: '产品图片',
          props: UploadFieldProps(uploadText: '上传产品图片', limit: 3, listType: FileListType.card),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ConfigForm(formConfig: formConfig),
    );
  }

  // 示例5：从后端获取数据回显
  Widget _buildFormWithBackendData() {
    return _BackendDataForm();
  }

  // 显示当前表单值
  Widget _buildFormValues() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('控制器中的表单值：', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final values = _controller.values;
              if (values.isEmpty) {
                return const Text('暂无数据', style: TextStyle(color: Colors.grey));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: values.entries.map((entry) {
                  return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text('${entry.key}: ${entry.value}'));
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// 专门用于处理后端数据的 StatefulWidget
class _BackendDataForm extends StatefulWidget {
  @override
  State<_BackendDataForm> createState() => _BackendDataFormState();
}

class _BackendDataFormState extends State<_BackendDataForm> {
  final ConfigFormController _backendDataController = ConfigFormController();
  String _currentUserId = 'U001'; // 当前用户ID
  bool _isLoading = false;
  String _loadingMessage = '';

  @override
  void initState() {
    super.initState();
    // 初始化时加载数据
    _loadBackendData();
  }

  // 加载后端数据
  Future<void> _loadBackendData() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = '正在从后端加载数据...';
    });

    try {
      // 模拟从后端获取数据
      final backendData = await _fetchBackendData(_currentUserId);

      // 设置数据到控制器
      _backendDataController.setValues(backendData);

      setState(() {
        _isLoading = false;
        _loadingMessage = '数据加载完成';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _loadingMessage = '数据加载失败: $e';
      });
    }
  }

  // 模拟从后端获取数据的函数
  Future<Map<String, dynamic>> _fetchBackendData(String userId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    // 模拟根据用户ID返回不同的数据
    if (userId == 'U001') {
      return {
        'userId': 'U001',
        'username': '张三',
        'email': 'zhangsan@example.com',
        'phone': '13800138000',
        'age': 28,
        'salary': 15000.50,
        'department': '技术部',
        'position': '高级工程师',
        'skills': ['Flutter', 'Dart', 'React'],
        'level': 'senior',
        'status': 'active',
        'joinDate': '2020年3月15日',
        'lastLogin': '2024年1月15日 09:30',
        'description': '具有5年开发经验，擅长移动端开发，熟悉Flutter、React Native等技术栈。',
      };
    } else if (userId == 'U002') {
      return {
        'userId': 'U002',
        'username': '李四',
        'email': 'lisi@example.com',
        'phone': '13900139000',
        'age': 32,
        'salary': 18000.00,
        'department': '产品部',
        'position': '产品经理',
        'skills': ['Vue', 'Angular', 'Node.js'],
        'level': 'expert',
        'status': 'active',
        'joinDate': '2018年6月10日',
        'lastLogin': '2024年1月16日 14:20',
        'description': '资深产品经理，具有8年产品设计经验，熟悉用户体验设计和产品规划。',
      };
    } else {
      // 默认返回空数据
      return {
        'userId': userId,
        'username': '',
        'email': '',
        'phone': '',
        'age': 0,
        'salary': 0.0,
        'department': '',
        'position': '',
        'skills': [],
        'level': '',
        'status': '',
        'joinDate': '',
        'lastLogin': '',
        'description': '',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final formConfig = FormConfig(
      fields: [
        FormFieldConfig.text(name: 'userId', label: '用户ID', placeholder: '请输入用户ID', required: true),
        FormFieldConfig.text(name: 'username', label: '用户名', placeholder: '请输入用户名', required: true),
        FormFieldConfig.text(name: 'email', label: '邮箱', placeholder: '请输入邮箱', required: true),
        FormFieldConfig.integer(name: 'phone', label: '电话', placeholder: '请输入电话号码', required: true),
        FormFieldConfig.number(name: 'age', label: '年龄', placeholder: '请输入年龄', required: true),
        FormFieldConfig.number(name: 'salary', label: '薪资', placeholder: '请输入薪资'),
        FormFieldConfig.select(
          name: 'department',
          label: '部门',
          placeholder: '请选择部门',
          required: true,
          props: SelectFieldProps(
            options: const [
              SelectData(label: '技术部', value: '技术部', data: '技术部'),
              SelectData(label: '产品部', value: '产品部', data: '产品部'),
              SelectData(label: '运营部', value: '运营部', data: '运营部'),
              SelectData(label: '人事部', value: '人事部', data: '人事部'),
            ],
          ),
        ),
        FormFieldConfig.text(name: 'position', label: '职位', placeholder: '请输入职位', required: true),
        FormFieldConfig.checkbox(
          name: 'skills',
          label: '技能',
          props: CheckboxFieldProps(
            options: const [
              SelectData(label: 'Flutter', value: 'Flutter', data: 'Flutter'),
              SelectData(label: 'Dart', value: 'Dart', data: 'Dart'),
              SelectData(label: 'React', value: 'React', data: 'React'),
              SelectData(label: 'Vue', value: 'Vue', data: 'Vue'),
              SelectData(label: 'Angular', value: 'Angular', data: 'Angular'),
            ],
          ),
        ),
        FormFieldConfig.radio(
          name: 'level',
          label: '级别',
          required: true,
          props: RadioFieldProps(
            options: const [
              SelectData(label: '初级', value: 'junior', data: 'junior'),
              SelectData(label: '中级', value: 'intermediate', data: 'intermediate'),
              SelectData(label: '高级', value: 'senior', data: 'senior'),
              SelectData(label: '专家', value: 'expert', data: 'expert'),
            ],
          ),
        ),
        FormFieldConfig.dropdown(
          name: 'status',
          label: '状态',
          required: true,
          props: DropdownFieldProps(
            options: const [
              SelectData(label: '在职', value: 'active', data: 'active'),
              SelectData(label: '离职', value: 'inactive', data: 'inactive'),
              SelectData(label: '休假', value: 'vacation', data: 'vacation'),
            ],
            filterable: true,
            placeholderText: '请选择状态',
          ),
        ),
        FormFieldConfig.date(name: 'joinDate', label: '入职日期', placeholder: '请选择入职日期'),
        FormFieldConfig.datetime(name: 'lastLogin', label: '最后登录时间', placeholder: '请选择最后登录时间'),
        FormFieldConfig.textarea(name: 'description', label: '个人描述', placeholder: '请输入个人描述', props: const TextareaFieldProps(maxLines: 3)),
      ],
    );

    return Column(
      children: [
        // 加载状态提示
        if (_isLoading)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 12),
                Text(_loadingMessage, style: TextStyle(color: Colors.orange.shade700)),
              ],
            ),
          ),

        if (_isLoading) const SizedBox(height: 16),

        // 表单
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ConfigForm(formConfig: formConfig, controller: _backendDataController),
        ),
        const SizedBox(height: 16),

        // 操作按钮
        Row(
          children: [
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      _currentUserId = 'U001';
                      _loadBackendData();
                    },
              child: const Text('加载用户U001'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      _currentUserId = 'U002';
                      _loadBackendData();
                    },
              child: const Text('加载用户U002'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      _currentUserId = 'U003';
                      _loadBackendData();
                    },
              child: const Text('加载用户U003'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 保存和清空按钮
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                // 模拟保存到后端
                final currentData = _backendDataController.values;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已保存数据到后端：${currentData.length}个字段')));
              },
              child: const Text('保存到后端'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                _backendDataController.clear();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已清空表单')));
              },
              child: const Text('清空表单'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 显示当前后端数据
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '当前后端数据：',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: _backendDataController,
                builder: (context, child) {
                  final values = _backendDataController.values;
                  if (values.isEmpty) {
                    return const Text('暂无数据', style: TextStyle(color: Colors.grey));
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: values.entries.map((entry) {
                      return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text('${entry.key}: ${entry.value}'));
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
