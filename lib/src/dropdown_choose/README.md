# DropdownChoose 下拉选择组件

一个功能丰富的下拉选择组件，支持本地/远程数据、单选/多选、搜索过滤等功能。

## 特性

- 🔍 **搜索过滤**：支持本地搜索和远程搜索
- 🎯 **单选/多选**：灵活的选择模式
- 🌐 **远程数据**：支持异步加载数据
- ➕ **新增功能**：支持动态添加选项
- 💾 **数据缓存**：远程数据自动缓存
- 🎨 **自定义样式**：可自定义外观

## 基本用法

### 单选模式

```dart
DropdownChoose<String>(
  options: [
    SelectData(label: '选项1', value: '1'),
    SelectData(label: '选项2', value: '2'),
    SelectData(label: '选项3', value: '3'),
  ],
  tips: '请选择',
  onSingleChanged: (value, data, selectData) {
    print('选中: ${selectData.label}');
  },
)
```

### 多选模式

```dart
DropdownChoose<String>(
  multiple: true,
  options: [
    SelectData(label: '选项1', value: '1'),
    SelectData(label: '选项2', value: '2'),
    SelectData(label: '选项3', value: '3'),
  ],
  tips: '请选择（多选）',
  onMultipleChanged: (values, dataList, selectDataList) {
    print('选中项: ${selectDataList.map((e) => e.label).join(', ')}');
  },
)
```

### 本地搜索

```dart
DropdownChoose<String>(
  filterable: true,
  options: [
    SelectData(label: '苹果', value: 'apple'),
    SelectData(label: '香蕉', value: 'banana'),
    SelectData(label: '橙子', value: 'orange'),
  ],
  tips: '搜索水果',
  onSingleChanged: (value, data, selectData) {
    print('选中: ${selectData.label}');
  },
)
```

### 远程搜索

```dart
DropdownChoose<String>(
  remote: true,
  remoteSearch: (keyword) async {
    // 模拟API调用
    await Future.delayed(Duration(milliseconds: 500));
    return [
      SelectData(label: '远程数据1', value: 'remote1'),
      SelectData(label: '远程数据2', value: 'remote2'),
    ];
  },
  tips: '输入关键字搜索',
  onSingleChanged: (value, data, selectData) {
    print('选中: ${selectData.label}');
  },
)
```

### 支持新增

```dart
DropdownChoose<String>(
  showAdd: true,
  options: [
    SelectData(label: '现有选项1', value: '1'),
    SelectData(label: '现有选项2', value: '2'),
  ],
  tips: '选择或新增',
  onAdd: (newValue) {
    print('新增: $newValue');
    // 处理新增逻辑
  },
  onSingleChanged: (value, data, selectData) {
    print('选中: ${selectData.label}');
  },
)
```

## API 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `options` | `List<SelectData<T>>` | `[]` | 选项数据列表 |
| `multiple` | `bool` | `false` | 是否多选 |
| `filterable` | `bool` | `false` | 是否支持本地搜索 |
| `remote` | `bool` | `false` | 是否远程搜索 |
| `remoteSearch` | `Future<List<SelectData<T>>> Function(String)?` | `null` | 远程搜索函数 |
| `alwaysRefresh` | `bool` | `false` | 是否总是刷新远程数据 |
| `showAdd` | `bool` | `false` | 是否显示新增按钮 |
| `tips` | `String` | `''` | 占位符文本 |
| `defaultValue` | `dynamic` | `null` | 默认选中值 |
| `onSingleChanged` | `Function(dynamic, T, SelectData<T>)?` | `null` | 单选回调 |
| `onMultipleChanged` | `Function(List<dynamic>, List<T>, List<SelectData<T>>)?` | `null` | 多选回调 |
| `onAdd` | `Function(String)?` | `null` | 新增回调 |
| `onCacheUpdate` | `Function(List<SelectData<T>>)?` | `null` | 缓存更新回调 |

## 注意事项

1. `filterable` 和 `remote` 不能同时为 `true`
2. 当 `remote` 为 `true` 时，必须提供 `remoteSearch` 函数
3. `defaultValue` 支持 `SelectData<T>` 或 `List<SelectData<T>>` 类型
4. 多选模式下使用 `onMultipleChanged` 回调
5. 单选模式下使用 `onSingleChanged` 回调

## 示例

更多使用示例请参考 [example](../../../example/lib/pages/) 目录中的相关示例页面。