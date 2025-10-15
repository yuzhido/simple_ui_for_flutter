# TreeSelect 树形选择组件

一个功能完整的树形选择组件，支持本地/远程数据、懒加载、搜索过滤、单选/多选等功能。

## 特性

- 🌳 **树形结构**：支持多层级树形数据展示
- 🎯 **单选/多选**：灵活的选择模式
- 🔍 **搜索过滤**：支持本地搜索和远程搜索
- 🚀 **懒加载**：支持按需加载子节点数据
- 💾 **数据缓存**：远程数据自动缓存
- 🎨 **自定义样式**：可自定义外观和交互

## 基本用法

### 单选模式

```dart
TreeSelect<String>(
  options: [
    SelectData(
      label: '一级节点1',
      value: '1',
      children: [
        SelectData(label: '二级节点1-1', value: '1-1'),
        SelectData(label: '二级节点1-2', value: '1-2'),
      ],
    ),
    SelectData(
      label: '一级节点2',
      value: '2',
      children: [
        SelectData(label: '二级节点2-1', value: '2-1'),
        SelectData(label: '二级节点2-2', value: '2-2'),
      ],
    ),
  ],
  title: '单选树形选择',
  hintText: '请选择节点',
  onSingleChanged: (value, data, selectData) {
    print('选中: ${selectData.label}');
  },
)
```

### 多选模式

```dart
TreeSelect<String>(
  multiple: true,
  options: [
    SelectData(
      label: '部门A',
      value: 'deptA',
      children: [
        SelectData(label: '开发组', value: 'dev'),
        SelectData(label: '测试组', value: 'test'),
      ],
    ),
    SelectData(
      label: '部门B',
      value: 'deptB',
      children: [
        SelectData(label: '产品组', value: 'product'),
        SelectData(label: '设计组', value: 'design'),
      ],
    ),
  ],
  title: '多选树形选择',
  onMultipleChanged: (values, dataList, selectDataList) {
    print('选中项: ${selectDataList.map((e) => e.label).join(', ')}');
  },
)
```

### 本地搜索

```dart
TreeSelect<String>(
  filterable: true,
  options: [
    SelectData(
      label: '技术部',
      value: 'tech',
      children: [
        SelectData(label: 'Flutter开发', value: 'flutter'),
        SelectData(label: 'React开发', value: 'react'),
        SelectData(label: '后端开发', value: 'backend'),
      ],
    ),
  ],
  title: '搜索选择',
  hintText: '输入关键字搜索',
  onSingleChanged: (value, data, selectData) {
    print('选中: ${selectData.label}');
  },
)
```

### 远程搜索

```dart
TreeSelect<String>(
  remote: true,
  remoteFetch: (keyword) async {
    // 模拟API调用
    await Future.delayed(Duration(milliseconds: 500));
    return [
      SelectData(label: '搜索结果1', value: 'result1'),
      SelectData(label: '搜索结果2', value: 'result2'),
    ];
  },
  title: '远程搜索',
  hintText: '输入关键字远程搜索',
  onSingleChanged: (value, data, selectData) {
    print('选中: ${selectData.label}');
  },
)
```

### 懒加载

```dart
TreeSelect<String>(
  lazyLoad: true,
  options: [
    SelectData(
      label: '根节点1',
      value: 'root1',
      hasChildren: true, // 标识有子节点，但未加载
    ),
    SelectData(
      label: '根节点2',
      value: 'root2',
      hasChildren: true,
    ),
  ],
  lazyLoadFetch: (parentNode) async {
    // 根据父节点异步加载子节点
    await Future.delayed(Duration(milliseconds: 300));
    return [
      SelectData(label: '${parentNode.label}-子节点1', value: '${parentNode.value}-1'),
      SelectData(label: '${parentNode.label}-子节点2', value: '${parentNode.value}-2'),
    ];
  },
  title: '懒加载树形选择',
  onSingleChanged: (value, data, selectData) {
    print('选中: ${selectData.label}');
  },
)
```

### 带默认值

```dart
TreeSelect<String>(
  multiple: true,
  defaultValue: [
    SelectData(label: '默认选中1', value: 'default1'),
    SelectData(label: '默认选中2', value: 'default2'),
  ],
  options: [
    // ... 选项数据
  ],
  title: '带默认值的选择',
  onMultipleChanged: (values, dataList, selectDataList) {
    print('选中项: ${selectDataList.map((e) => e.label).join(', ')}');
  },
)
```

## API 参数

| 参数                | 类型                                                     | 默认值               | 说明             |
| ------------------- | -------------------------------------------------------- | -------------------- | ---------------- |
| `options`           | `List<SelectData<T>>`                                    | `[]`                 | 树形数据源       |
| `multiple`          | `bool`                                                   | `false`              | 是否多选         |
| `title`             | `String?`                                                | `null`               | 顶部标题         |
| `tips`              | `String?`                                                | `null`               | 顶部提示         |
| `hintText`          | `String`                                                 | `'请输入关键字搜索'` | 搜索框占位符     |
| `defaultValue`      | `List<SelectData<T>>?`                                   | `null`               | 默认选中值       |
| `filterable`        | `bool`                                                   | `false`              | 是否支持本地搜索 |
| `remote`            | `bool`                                                   | `false`              | 是否远程搜索     |
| `remoteFetch`       | `Future<List<SelectData<T>>> Function(String)?`          | `null`               | 远程搜索函数     |
| `lazyLoad`          | `bool`                                                   | `false`              | 是否懒加载       |
| `lazyLoadFetch`     | `Future<List<SelectData<T>>> Function(SelectData<T>)?`   | `null`               | 懒加载函数       |
| `isCacheData`       | `bool`                                                   | `false`              | 是否缓存数据     |
| `onSingleChanged`   | `Function(dynamic, T, SelectData<T>)?`                   | `null`               | 单选回调         |
| `onMultipleChanged` | `Function(List<dynamic>, List<T>, List<SelectData<T>>)?` | `null`               | 多选回调         |

## SelectData 数据结构

```dart
class SelectData<T> {
  final String label;              // 显示文本
  final dynamic value;             // 值
  final T? data;                  // 额外数据
  final List<SelectData<T>>? children; // 子节点
  final bool hasChildren;         // 是否有子节点（懒加载时使用）
  final bool isExpanded;          // 是否展开
  final bool isSelected;          // 是否选中
}
```

## 使用场景

1. **组织架构选择**：部门、岗位等层级选择
2. **地区选择**：省市区等地理位置选择
3. **分类选择**：商品分类、文档分类等
4. **权限选择**：菜单权限、功能权限等
5. **文件目录**：文件夹、文件选择

## 注意事项

1. `filterable` 和 `remote` 不能同时为 `true`
2. 当 `remote` 为 `true` 时，必须提供 `remoteFetch` 函数
3. 当 `lazyLoad` 为 `true` 时，必须提供 `lazyLoadFetch` 函数
4. 懒加载模式下，父节点需要设置 `hasChildren: true`
5. 多选模式下使用 `onMultipleChanged` 回调
6. 单选模式下使用 `onSingleChanged` 回调

## 示例

更多使用示例请参考 [example](../../../example/lib/pages/) 目录中的相关示例页面。
