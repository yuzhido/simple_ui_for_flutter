# simple_ui

自定义简单 UI 组件库，适用于 Flutter，提供常用的下拉选择、级联选择、树形选择、文件上传、消息通知等高复用性组件，助力中后台/表单/管理端等场景快速开发。

## 特性

- 🌟 下拉选择（支持本地/远程、单选/多选、可搜索）
- 🌈 级联多选（三级联动，支持多选/单选）
- 🌳 树形选择（支持本地/远程、初始值、双向绑定）
- 📤 文件上传（支持图片、文件、拍照、可自定义触发器）
- 🔔 消息通知（支持滚动、点击、样式自定义）
- 纯 Dart/Flutter 实现，易于二次开发

## 安装

在 `pubspec.yaml` 添加依赖：

```yaml
simple_ui: ^1.0.1
```

或使用命令：

```shell
flutter pub add simple_ui
```

## 快速上手

```dart
import 'package:simple_ui/simple_ui.dart';
```

## 组件用法示例

### 1. 下拉选择 DropdownChoose

```dart
DropdownChoose<String>(
  list: [
    SelectData(label: '选项1', value: '1'),
    SelectData(label: '选项2', value: '2'),
  ],
  multiple: false, // 单选/多选
  filterable: true, // 可搜索
  onSingleSelected: (val) => print(val.label),
)
```

### 2. 级联多选 CascadingSelect

```dart
CascadingSelect<String>(
  options: [
    CascadingItem(label: '省份', value: 'p', children: [
      CascadingItem(label: '城市', value: 'c', children: [
        CascadingItem(label: '区县', value: 'a'),
      ]),
    ]),
  ],
  multiple: true, // 多选/单选
  onConfirm: (selected) => print(selected.map((e) => e.label)),
)
```

### 3. 树形选择 TreeSelect

```dart
TreeSelect(
  data: [
    TreeNode(label: '节点1', id: '1', children: [TreeNode(label: '子节点', id: '1-1')]),
  ],
  placeholder: '请选择',
  onSelect: (node) => print(node.label),
)
```

### 4. 文件上传 UploadFile

```dart
UploadFile(
  allowedSources: {UploadSource.image, UploadSource.file, UploadSource.camera},
  onSelected: (result) => print(result.name),
)
```

### 5. 消息通知 NoticeInfo

```dart
NoticeInfo(
  message: '这是一条消息通知',
  enableScroll: true, // 超长自动滚动
  onTap: () => print('点击了通知'),
)
```

## 依赖

- file_picker
- image_picker
- flutter_svg

## 贡献

欢迎提 issue 或 PR 参与贡献！

## 开源协议

MIT License

更多用法和高级示例请见 [example/](example/) 目录和源码注释。
