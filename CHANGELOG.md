# Changelog

## 1.0.1

- **优化 DropdownChoose 组件 API**

  - 移除冗余的 `selectedData` 属性，统一使用 `defaultValue` 处理默认值
  - 支持单选和多选两种模式的默认值设置：
    - 单选模式：`defaultValue: SelectData<T>?`
    - 多选模式：`defaultValue: List<SelectData<T>>?`
  - 优化内部逻辑，统一默认值处理方式
  - 更新示例代码和文档说明
  - 保持向后兼容性，不影响现有功能

- **新增多选模式底部按钮功能**
  - 左侧添加"已选择"按钮，显示已选择项目数量
  - 右侧保持"确认选择"按钮
  - 点击"已选择"按钮可查看已选择的详细列表
  - 支持在弹窗中直接移除已选择的项目
  - 当没有选择项目时，两个按钮都会被禁用
  - 修复已选择弹窗中移除项目后主弹窗状态同步问题

## 1.0.0

- 初始版本发布
- 包含以下组件：
  - DropdownChoose: 下拉选择组件，支持单选、多选、远程搜索
  - TreeSelect: 树形选择组件
  - CascadingSelect: 级联选择组件
  - NoticeInfo: 通知信息组件
  - UploadFile: 文件上传组件
