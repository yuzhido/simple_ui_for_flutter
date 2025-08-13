# 外部表单验证调用指南

## 概述

`ConfigForm` 组件现在支持从外部页面调用表单验证、重置和数据获取方法。这提供了更大的灵活性，允许外部页面完全控制表单的行为。

## 功能特性

### 1. 外部验证调用

- 可以在外部页面调用表单验证
- 获取验证结果和错误信息
- 实时监听验证状态变化

### 2. 外部重置调用

- 可以在外部页面重置表单
- 清空所有字段和错误状态
- 恢复默认值

### 3. 外部数据获取

- 可以获取当前表单数据
- 实时获取表单状态
- 支持数据导出和保存

## 使用方法

### 方案 1：通过 GlobalKey 调用（推荐）

```dart
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  // 创建表单的GlobalKey
  final GlobalKey<State<ConfigForm>> _formKey = GlobalKey<State<ConfigForm>>();

  // 外部验证表单
  void _validateFormExternally() {
    if (_formKey.currentState != null) {
      final formState = _formKey.currentState as dynamic;

      // 调用验证方法
      if (formState.validateForm != null) {
        final isValid = formState.validateForm();
        print('验证结果: $isValid');

        if (isValid) {
          // 获取表单数据
          final formData = formState.getFormData();
          print('表单数据: $formData');
        } else {
          // 获取错误信息
          final errors = formState.getErrors();
          print('验证错误: $errors');
        }
      }
    }
  }

  // 外部重置表单
  void _resetFormExternally() {
    if (_formKey.currentState != null) {
      final formState = _formKey.currentState as dynamic;
      if (formState.resetForm != null) {
        formState.resetForm();
        print('表单已重置');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 外部控制按钮
          Row(
            children: [
              ElevatedButton(
                onPressed: _validateFormExternally,
                child: Text('验证表单'),
              ),
              ElevatedButton(
                onPressed: _resetFormExternally,
                child: Text('重置表单'),
              ),
            ],
          ),

          // 表单组件
          ConfigForm(
            key: _formKey,  // 重要：添加key
            formConfig: formConfig,
            onSubmit: (data) => print('提交: $data'),
          ),
        ],
      ),
    );
  }
}
```

### 方案 2：通过验证状态回调

```dart
ConfigForm(
  formConfig: formConfig,
  onValidationChanged: (isValid, errors) {
    // 监听验证状态变化
    setState(() {
      _isFormValid = isValid;
      _currentErrors = errors;
    });

    print('验证状态: $isValid');
    print('错误信息: $errors');
  },
  onSubmit: (data) => print('提交: $data'),
)
```

## 可用的外部方法

### 1. `validateForm()`

- **功能**: 验证表单
- **返回值**: `bool` - 验证是否通过
- **说明**: 执行完整的表单验证，返回验证结果

### 2. `getFormData()`

- **功能**: 获取当前表单数据
- **返回值**: `Map<String, dynamic>` - 表单数据
- **说明**: 返回不可修改的表单数据副本

### 3. `getErrors()`

- **功能**: 获取当前错误信息
- **返回值**: `Map<String, String?>` - 错误信息
- **说明**: 返回不可修改的错误信息副本

### 4. `resetForm()`

- **功能**: 重置表单
- **返回值**: `void`
- **说明**: 清空所有字段，恢复默认值，清除错误状态

## 完整示例

参考 `example/lib/pages/data_for_form/index.dart` 和 `example/lib/pages/data_for_form/new_data_form.dart` 文件，这些文件展示了完整的使用示例。

## 注意事项

1. **GlobalKey 使用**: 必须给 `ConfigForm` 添加 `key` 属性才能从外部调用方法
2. **类型安全**: 使用 `dynamic` 类型来访问表单状态，确保方法存在后再调用
3. **状态管理**: 建议使用 `onValidationChanged` 回调来监听验证状态变化
4. **错误处理**: 在调用外部方法前检查 `_formKey.currentState` 是否存在

## 最佳实践

1. **组合使用**: 结合 GlobalKey 和回调函数，既支持主动调用，又支持状态监听
2. **错误处理**: 在调用外部方法前进行适当的检查
3. **用户体验**: 提供清晰的外部控制界面，让用户了解可以执行的操作
4. **状态同步**: 使用回调函数保持外部状态与表单状态的同步

## 总结

通过这些新功能，`ConfigForm` 组件现在提供了完整的双向通信能力：

- 外部页面可以主动控制表单
- 表单状态变化可以实时通知外部页面
- 支持复杂的表单交互场景
- 提供了灵活的表单管理方案
