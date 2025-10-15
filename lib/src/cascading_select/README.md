# CascadingSelect 级联选择组件

一个功能强大的三级级联选择组件，支持多选和单选模式，适用于省市区选择、分类选择等场景。

## 特性

- 🏗️ **三级联动**：支持一级 → 二级 → 三级的级联选择
- 🎯 **多选/单选**：灵活的选择模式
- 🚫 **不限选项**：支持"不限"选项（与具体选项互斥）
- 🎨 **自定义数据**：支持泛型，可携带额外数据
- 📱 **移动端优化**：适配移动端交互体验

## 基本用法

### 多选模式（默认）

```dart
CascadingSelect<String>(
  title: '地区选择',
  multiple: true,
  showUnlimited: true,
  options: [
    CascadingItem(
      label: '广东省',
      value: 'gd',
      children: [
        CascadingItem(
          label: '广州市',
          value: 'gz',
          children: [
            CascadingItem(label: '天河区', value: 'th'),
            CascadingItem(label: '越秀区', value: 'yx'),
            CascadingItem(label: '海珠区', value: 'hz'),
          ],
        ),
        CascadingItem(
          label: '深圳市',
          value: 'sz',
          children: [
            CascadingItem(label: '南山区', value: 'ns'),
            CascadingItem(label: '福田区', value: 'ft'),
          ],
        ),
      ],
    ),
    CascadingItem(
      label: '北京市',
      value: 'bj',
      children: [
        CascadingItem(
          label: '北京市',
          value: 'bjc',
          children: [
            CascadingItem(label: '朝阳区', value: 'cy'),
            CascadingItem(label: '海淀区', value: 'hd'),
          ],
        ),
      ],
    ),
  ],
  onConfirm: (selected) {
    print('选中的区域: ${selected.map((e) => e.label).join(', ')}');
  },
)
```

### 单选模式

```dart
CascadingSelect<String>(
  title: '分类选择',
  multiple: false,
  showUnlimited: false,
  options: [
    CascadingItem(
      label: '电子产品',
      value: 'electronics',
      children: [
        CascadingItem(
          label: '手机',
          value: 'phone',
          children: [
            CascadingItem(label: 'iPhone', value: 'iphone'),
            CascadingItem(label: 'Android', value: 'android'),
          ],
        ),
        CascadingItem(
          label: '电脑',
          value: 'computer',
          children: [
            CascadingItem(label: '笔记本', value: 'laptop'),
            CascadingItem(label: '台式机', value: 'desktop'),
          ],
        ),
      ],
    ),
  ],
  onConfirm: (selected) {
    if (selected.isNotEmpty) {
      print('选中路径: ${selected.map((e) => e.label).join(' → ')}');
    }
  },
)
```

### 带默认选中值

```dart
CascadingSelect<String>(
  title: '地区选择',
  multiple: true,
  defaultSelectedValues: ['th', 'yx', 'ns'], // 默认选中天河区、越秀区、南山区
  options: [
    // ... 选项数据
  ],
  onConfirm: (selected) {
    print('选中的区域: ${selected.map((e) => e.label).join(', ')}');
  },
)
```

### 携带额外数据

```dart
class RegionData {
  final String code;
  final String pinyin;
  
  RegionData({required this.code, required this.pinyin});
}

CascadingSelect<RegionData>(
  title: '地区选择',
  options: [
    CascadingItem(
      label: '广东省',
      value: 'gd',
      extra: RegionData(code: '440000', pinyin: 'guangdong'),
      children: [
        CascadingItem(
          label: '广州市',
          value: 'gz',
          extra: RegionData(code: '440100', pinyin: 'guangzhou'),
          children: [
            CascadingItem(
              label: '天河区',
              value: 'th',
              extra: RegionData(code: '440106', pinyin: 'tianhe'),
            ),
          ],
        ),
      ],
    ),
  ],
  onConfirm: (selected) {
    for (var item in selected) {
      print('${item.label}: ${item.extra?.code}');
    }
  },
)
```

## API 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `options` | `List<CascadingItem<T>>` | 必填 | 级联数据源 |
| `title` | `String` | `'三级联选多选'` | 顶部标题 |
| `multiple` | `bool` | `true` | 选择模式：true=多选，false=单选 |
| `showUnlimited` | `bool` | `true` | 是否显示"不限"选项（仅多选模式） |
| `defaultSelectedValues` | `List<dynamic>?` | `null` | 默认选中的第三级值列表 |
| `onConfirm` | `Function(List<CascadingItem<T>>)?` | `null` | 确认选择回调 |

## CascadingItem 数据结构

```dart
class CascadingItem<T> {
  final String label;        // 显示文本
  final dynamic value;       // 值（用于选中判断）
  final T? extra;           // 额外数据
  final List<CascadingItem<T>> children; // 子级数据
}
```

## 选择模式说明

### 多选模式 (`multiple: true`)
- 在第三级进行多选
- 支持"不限"选项（与具体选项互斥）
- `onConfirm` 返回所有选中的第三级项

### 单选模式 (`multiple: false`)
- 每级单选，不自动选中下级
- 需要手动逐级选择
- `onConfirm` 返回当前选中的完整路径 [一级, 二级, 三级]

## 注意事项

1. 数据结构必须是三级结构：一级 → 二级 → 三级
2. 每个 `CascadingItem` 的 `value` 必须唯一
3. `defaultSelectedValues` 仅在多选模式下有效
4. "不限"选项仅在多选模式且 `showUnlimited: true` 时显示

## 示例

更多使用示例请参考 [example](../../../example/lib/pages/) 目录中的相关示例页面。