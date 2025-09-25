import 'dart:io';

import 'package:dio/dio.dart';
import 'package:example/utils/compress_image.dart';
import 'package:example/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';

class AllFormTypeRequiredDemoPage extends StatefulWidget {
  const AllFormTypeRequiredDemoPage({super.key});
  @override
  State<AllFormTypeRequiredDemoPage> createState() => _AllFormTypeRequiredDemoPageState();
}

class _AllFormTypeRequiredDemoPageState extends State<AllFormTypeRequiredDemoPage> {
  final ConfigFormController _formController = ConfigFormController();
  String _compressionStatus = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('所有表单项必填')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConfigForm(
          controller: _formController,
          configs: [
            // 文本
            FormConfig.text(const TextFieldConfig(name: 'text', label: '文本', required: true)),
            // 多行文本
            FormConfig.textarea(const TextareaFieldConfig(name: 'textarea', label: '多行文本', rows: 3, required: true)),
            // 数字
            FormConfig.number(const NumberFieldConfig(name: 'number', label: '数字', decimalPlaces: 2, required: true)),
            // 整数
            FormConfig.integer(const IntegerFieldConfig(name: 'integer', label: '整数', required: true)),
            // 日期
            FormConfig.date(const DateFieldConfig(name: 'date', label: '日期', required: true)),
            // 时间
            FormConfig.time(const TimeFieldConfig(name: 'time', label: '时间', required: true)),
            // 日期时间
            FormConfig.datetime(const DateTimeFieldConfig(name: 'datetime', label: '日期时间', required: true)),
            // 单选（使用字符串）
            FormConfig.radio<String>(
              RadioFieldConfig<String>(
                name: 'radio',
                label: '单选',
                required: true,
                options: const [
                  SelectData(label: 'A', value: 'A', data: 'A'),
                  SelectData(label: 'B', value: 'B', data: 'B'),
                ],
              ),
            ),
            // 多选
            FormConfig.checkbox<String>(
              CheckboxFieldConfig<String>(
                name: 'checkbox',
                label: '多选',
                required: true,
                options: const [
                  SelectData(label: '苹果', value: 'apple', data: 'apple'),
                  SelectData(label: '香蕉', value: 'banana', data: 'banana'),
                  SelectData(label: '橙子', value: 'orange', data: 'orange'),
                ],
              ),
            ),
            // 下拉选择（简单）
            FormConfig.select<String>(
              SelectFieldConfig<String>(
                name: 'select',
                label: '下拉选择',
                required: true,
                options: const [
                  SelectData(label: '一', value: '1', data: '1'),
                  SelectData(label: '二', value: '2', data: '2'),
                  SelectData(label: '三', value: '3', data: '3'),
                ],
              ),
            ),
            // 自定义下拉 DropdownChoose（可多选/本地）
            FormConfig.dropdown<String>(
              DropdownFieldConfig<String>(
                name: 'dropdown',
                label: 'Dropdown 选择',
                required: true,
                options: const [
                  SelectData(label: '杭州', value: 'hz', data: 'hz'),
                  SelectData(label: '上海', value: 'sh', data: 'sh'),
                  SelectData(label: '北京', value: 'bj', data: 'bj'),
                ],
                multiple: true,
              ),
            ),

            // 上传（必填）
            FormConfig.upload(
              UploadFieldConfig(
                name: 'upload',
                label: '文件上传',
                required: true,
                maxFiles: 5,
                customUpload: (String filePath, Function(double) onProgress) async {
                  print('🖼️ 开始图片压缩上传: $filePath');
                  try {
                    setState(() {
                      _compressionStatus = '正在压缩图片...';
                    });
                    // 检查是否为图片文件
                    String finalFilePath = filePath;

                    // 获取原始文件信息
                    final originalFile = File(filePath);
                    final originalSize = await originalFile.length();
                    print('📊 原始文件大小: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB');

                    // 根据文件大小选择压缩配置
                    final compressConfig = ImageCompressUtil.smartConfig(originalSize);

                    // 执行图片压缩
                    final compressResult = await ImageCompressUtil.compressImage(filePath, config: compressConfig);

                    if (compressResult.success) {
                      finalFilePath = compressResult.filePath;
                      print('✅ 压缩成功！');
                      print('📊 压缩后大小: ${(compressResult.compressedSize / 1024 / 1024).toStringAsFixed(2)} MB');
                      print('📊 压缩比例: ${(compressResult.compressionRatio * 100).toStringAsFixed(1)}%');

                      setState(() {
                        _compressionStatus = '压缩完成，节省 ${(compressResult.compressionRatio * 100).toStringAsFixed(1)}% 空间';
                      });
                    } else {
                      print('❌ 压缩失败: ${compressResult.error}');
                      setState(() {
                        _compressionStatus = '压缩失败，使用原文件上传';
                      });
                    }

                    // 获取原始文件信息
                    final currentFile = File(finalFilePath);
                    final currentFileSize = await currentFile.length();
                    print('📊 压缩后文件大小: ${(currentFileSize / 1024 / 1024).toStringAsFixed(2)} MB');
                    print('📊 压缩后文件大小: ${(currentFileSize / 1024 / 1024).toStringAsFixed(2)} MB');
                    print('📊 压缩后文件大小: ${(currentFileSize / 1024 / 1024).toStringAsFixed(2)} MB');
                    print('📊 压缩后文件大小: ${(currentFileSize / 1024 / 1024).toStringAsFixed(2)} MB');

                    // 执行上传
                    final dio = Dio();
                    final formData = FormData();
                    final fileName = finalFilePath.split('/').last.split('\\').last;

                    formData.files.add(MapEntry('file', await MultipartFile.fromFile(finalFilePath, filename: fileName)));

                    final response = await dio.request(
                      '${Config.baseUrl}/upload/api/upload-file',
                      data: formData,
                      options: Options(method: 'POST'),
                      onSendProgress: (sent, total) {
                        if (total > 0) {
                          final progress = sent / total;
                          onProgress(progress);
                          print('📤 上传进度: ${(progress * 100).toInt()}%');
                        }
                      },
                    );

                    final isSuccess = response.statusCode == 200;

                    if (isSuccess) {
                      print('✅ 压缩上传成功！');
                      return FileUploadModel(
                        fileInfo: FileInfo(id: null, fileName: '', requestPath: ''),
                        name: '',
                        path: '',
                      );
                    } else {
                      throw Exception('上传失败：HTTP状态码 ${response.statusCode}');
                    }
                  } catch (e) {
                    print('❌ 压缩上传异常: $e');
                    throw Exception('压缩上传失败: $e');
                  }
                },
              ),
            ),
            // 树选择（简单静态树）
            FormConfig.treeSelect<String>(
              TreeSelectFieldConfig<String>(
                name: 'tree',
                label: '树选择',
                required: true,
                options: const [
                  SelectData(
                    label: '华东',
                    value: 'east',
                    data: 'east',
                    children: [
                      SelectData(label: '上海', value: 'sh', data: 'sh'),
                      SelectData(label: '杭州', value: 'hz', data: 'hz'),
                    ],
                  ),
                  SelectData(
                    label: '华北',
                    value: 'north',
                    data: 'north',
                    children: [SelectData(label: '北京', value: 'bj', data: 'bj')],
                  ),
                ],
                multiple: true,
                checkable: true,
              ),
            ),
            // 自定义
            FormConfig.custom(
              CustomFieldConfig(
                name: 'custom',
                label: '自定义',
                required: true,
                contentBuilder: (cfg, controller, onChanged) {
                  return TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '输入自定义内容'),
                    onChanged: onChanged,
                  );
                },
              ),
            ),
          ],
          submitBuilder: (formData) {
            // 保持占位布局一致
            return const SizedBox.shrink();
          },
        ),
      ),
      bottomNavigationBar: Container(
        //
        color: Colors.grey.shade200,
        padding: const EdgeInsets.all(16),
        child: Text('$_compressionStatus'),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'submitRequired',
            onPressed: () {
              if (_formController.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('校验通过，已提交')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请完善必填项')));
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('提交'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'viewDataRequired',
            onPressed: () {
              final data = _formController.getFormData() ?? {};
              showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: const Text('当前表单数据'),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [...data.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('${e.key}: ${e.value} : ${e.value.runtimeType}')))],
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
        ],
      ),
    );
  }
}
