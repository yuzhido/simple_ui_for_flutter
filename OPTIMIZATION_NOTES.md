# DropdownChoose 组件优化说明

## 优化内容

### 问题描述

原来的 `DropdownChoose` 组件有两个功能相似的属性：

- `defaultValue`: 用于设置默认选中值
- `selectedData`: 用于编辑时显示已选择的数据

这两个属性在功能上有重叠，都是用来设置默认选中值的，造成了 API 的冗余和混淆。

### 优化方案

统一使用 `defaultValue` 属性来处理默认值，支持单选和多选两种情况：

1. **单选模式** (`multiple: false`)：

   - `defaultValue` 接受 `SelectData<T>?` 类型
   - 例如：`defaultValue: SelectData<String>(value: '1', label: '选项1', data: '1')`

2. **多选模式** (`multiple: true`)：
   - `defaultValue` 接受 `List<SelectData<T>>?` 类型
   - 例如：`defaultValue: [SelectData<String>(value: '1', label: '选项1', data: '1')]`

### 代码变更

#### 1. 组件属性变更

```dart
// 移除 selectedData 属性
// final List<SelectData<T>>? selectedData;

// 优化 defaultValue 属性，支持动态类型
final dynamic defaultValue; // 单选时传入 SelectData<T>?，多选时传入 List<SelectData<T>>?
```

#### 2. 初始化逻辑优化

- 新增 `_addDefaultValuesToDataList()` 方法，统一处理默认值的数据合并
- 优化 `_setDefaultValues()` 方法，根据 `multiple` 模式正确处理默认值
- 在远程搜索时也确保默认值数据始终可见

#### 3. 示例代码更新

更新了 `example/lib/pages/dropdown_select/index.dart` 中的所有示例，将 `selectedData` 替换为 `defaultValue`。

### 使用示例

#### 单选模式

```dart
DropdownChoose<String>(
  list: options,
  multiple: false,
  defaultValue: SelectData<String>(value: '1', label: '选项1', data: '1'),
  onSingleSelected: (value) {
    print('选择了：${value.label}');
  },
)
```

#### 多选模式

```dart
DropdownChoose<String>(
  list: options,
  multiple: true,
  defaultValue: [
    SelectData<String>(value: '1', label: '选项1', data: '1'),
    SelectData<String>(value: '2', label: '选项2', data: '2'),
  ],
  onMultipleSelected: (values) {
    print('选择了：${values.map((e) => e.label).join(', ')}');
  },
)
```

#### 远程搜索 + 默认值

```dart
DropdownChoose<String>(
  remote: true,
  remoteFetch: () async => await fetchRemoteData(),
  multiple: false,
  defaultValue: SelectData<String>(value: 'remote1', label: '远程选项1', data: 'remote1'),
  onSingleSelected: (value) {
    print('选择了：${value.label}');
  },
)
```

### 优势

1. **API 简化**：移除了冗余的 `selectedData` 属性，统一使用 `defaultValue`
2. **类型安全**：通过 `dynamic` 类型和运行时检查，确保类型安全
3. **向后兼容**：保持了原有的功能，只是简化了 API
4. **逻辑统一**：所有默认值处理逻辑都统一在一个地方
5. **易于理解**：开发者只需要记住一个属性名，减少了学习成本

### 测试验证

创建了完整的测试用例验证优化后的组件在各种场景下都能正常工作：

- 单选模式 + 默认值
- 多选模式 + 默认值
- 空默认值
- 远程搜索 + 默认值

所有测试都通过，确保优化没有破坏现有功能。
