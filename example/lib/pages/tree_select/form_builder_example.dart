import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_builder_config.dart';
import 'package:simple_ui/simple_ui.dart';
import '../../api/area_location_api.dart';
import '../../api/models/area_location.dart';

/// FormBuilder 中 TreeSelect 组件的真实API配置示例
///
/// 本示例展示了如何在FormBuilder表单中使用TreeSelect组件，
/// 并通过真实的API接口获取区域位置数据
class FormBuilderTreeSelectExample extends StatefulWidget {
  const FormBuilderTreeSelectExample({super.key});

  @override
  State<FormBuilderTreeSelectExample> createState() => _FormBuilderTreeSelectExampleState();
}

class _FormBuilderTreeSelectExampleState extends State<FormBuilderTreeSelectExample> {
  final FormBuilderController _formController = FormBuilderController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 加载状态
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FormBuilder TreeSelect 真实API示例'), backgroundColor: Colors.green.shade600, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 页面说明
            _buildPageDescription(),
            const SizedBox(height: 24),

            // 表单区域
            _buildForm(),
            const SizedBox(height: 24),

            // 操作按钮
            _buildActionButtons(),
            const SizedBox(height: 24),

            // 表单数据展示
            _buildFormDataDisplay(),
          ],
        ),
      ),
    );
  }

  /// 构建页面说明
  Widget _buildPageDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green.shade50, Colors.blue.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.api, color: Colors.green.shade600),
              const SizedBox(width: 8),
              Text(
                'FormBuilder TreeSelect 真实API示例',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '本示例展示了如何在FormBuilder表单中集成TreeSelect组件，'
            '并通过真实的API接口（AreaLocationApi.searchAreaLocations）获取区域位置数据。',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('支持远程搜索、懒加载、单选/多选等多种模式', style: TextStyle(fontSize: 12, color: Colors.amber.shade700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建表单
  Widget _buildForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: FormBuilder(
            controller: _formController,
            configs: [
              // 单选区域选择（远程搜索）
              FormBuilderConfig.treeSelect<dynamic>(
                name: 'region',
                label: '所在区域（单选 + 远程搜索）',
                required: true,
                title: '选择区域',
                hintText: '请选择所在区域',
                multiple: false,
                remote: true,
                filterable: true,
                remoteFetch: _fetchAreaLocations,
                onSingleSelected: (value, selectedItem) {
                  print('选中区域: $value, 数据: ${selectedItem?.data}');
                },
              ),

              // 多选区域选择（懒加载）
              FormBuilderConfig.treeSelect<dynamic>(
                name: 'workAreas',
                label: '工作区域（多选 + 懒加载）',
                required: false,
                options: [],
                title: '选择工作区域',
                hintText: '请选择工作区域（可多选）',
                multiple: true,
                lazyLoad: true,
                remote: true,
                remoteFetch: _fetchAreaLocations,
                lazyLoadFetch: _lazyLoadAreaLocations,
                onMultipleSelected: (values, selectedItems) {
                  print('选中工作区域: $values');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _submitForm,
            icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
            label: Text(_isLoading ? '提交中...' : '提交表单'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _resetForm,
            icon: const Icon(Icons.refresh),
            label: const Text('重置表单'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
      ],
    );
  }

  /// 构建表单数据展示
  Widget _buildFormDataDisplay() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.data_object, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  '表单数据',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListenableBuilder(
                listenable: _formController,
                builder: (context, child) {
                  final values = _formController.values;
                  if (values.isEmpty) {
                    return Text(
                      '暂无数据',
                      style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: values.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black87),
                            children: [
                              TextSpan(
                                text: '${entry.key}: ',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: _formatValue(entry.value),
                                style: TextStyle(color: Colors.blue.shade700),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade600, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 远程获取区域位置数据
  Future<List<SelectData<dynamic>>> _fetchAreaLocations(String keyword) async {
    try {
      setState(() {
        _errorMessage = null;
      });

      final response = await AreaLocationApi.searchAreaLocations(keyword: keyword, limit: 20);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> list = response['data']['list'] ?? [];
        return list.map((item) {
          final areaLocation = AreaLocation.fromJson(item);
          return SelectData<dynamic>(label: areaLocation.label ?? '', value: areaLocation.id ?? '', data: areaLocation, hasChildren: true);
        }).toList();
      }

      return [];
    } catch (e) {
      setState(() {
        _errorMessage = '获取区域数据失败: $e';
      });
      return [];
    }
  }

  /// 懒加载区域位置数据
  Future<List<SelectData<dynamic>>> _lazyLoadAreaLocations(SelectData<dynamic> parent) async {
    try {
      setState(() {
        _errorMessage = null;
      });

      final response = await AreaLocationApi.getAreaLocationList(parentId: parent.value, limit: 50);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> list = response['data']['list'] ?? [];
        return list.map((item) {
          final areaLocation = AreaLocation.fromJson(item);
          return SelectData<dynamic>(label: areaLocation.label ?? '', value: areaLocation.id ?? '', data: areaLocation, hasChildren: areaLocation.hasChildren ?? false);
        }).toList();
      }

      return [];
    } catch (e) {
      setState(() {
        _errorMessage = '懒加载区域数据失败: $e';
      });
      return [];
    }
  }

  /// 提交表单
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 模拟提交延迟
      await Future.delayed(const Duration(seconds: 1));

      final values = _formController.values;
      print('表单提交成功: $values');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('表单提交成功！'), backgroundColor: Colors.green));
      }
    } catch (e) {
      setState(() {
        _errorMessage = '提交失败: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 重置表单
  void _resetForm() {
    _formController.clear();
    _formKey.currentState?.reset();
    setState(() {
      _errorMessage = null;
    });
  }

  /// 格式化值显示
  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is List) {
      return '[${value.map((e) => e.toString()).join(', ')}]';
    }
    return value.toString();
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }
}
