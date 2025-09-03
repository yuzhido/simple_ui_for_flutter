import 'package:flutter/material.dart';
import 'package:simple_ui/models/index.dart';
import 'dart:async'; // 新增：导入Timer

class DropdownChoose<T> extends StatefulWidget {
  final List<SelectData<T>>? list;
  final Future<List<SelectData<T>>> Function(String? keyword)? remoteFetch;
  final bool? multiple;

  // 统一使用defaultValue，支持单选和多选 单选时传入 SelectData<T>?，多选时传入 List<SelectData<T>>?
  final dynamic defaultValue;
  final Function(SelectData<T>)? onSingleSelected;
  final Function(List<SelectData<T>>)? onMultipleSelected;
  final bool filterable;
  final bool remote;
  // 顶部标题文案（可选覆盖）。单选默认“请选择”，多选默认“请选择（可多选）”
  final String? singleTitleText;
  final String? multipleTitleText;
  // 未选择时的占位提示文案，默认“请选择选项”
  final String? placeholderText;
  // 远程搜索时，是否在列表底部显示“去新增”提示
  final bool showAdd;
  // 点击“去新增”的回调，携带当前输入框关键词
  final void Function(String keyword)? onAdd;

  const DropdownChoose({
    super.key,
    this.list,
    this.remoteFetch,
    this.multiple = false,
    this.defaultValue,
    this.onSingleSelected,
    this.onMultipleSelected,
    this.filterable = false,
    this.remote = false,
    this.singleTitleText,
    this.multipleTitleText,
    this.placeholderText,
    this.showAdd = false,
    this.onAdd,
  }) : assert(!(singleTitleText != null && multipleTitleText != null), 'DropdownChoose: singleTitleText 与 multipleTitleText 不能同时传入'),
       assert((showAdd == false && onAdd == null) || (showAdd == true && onAdd != null), 'DropdownChoose: 使用新增入口时必须同时传入 showAdd: true 与 onAdd 回调');

  @override
  State<DropdownChoose<T>> createState() => _DropdownChooseState<T>();
}

class _DropdownChooseState<T> extends State<DropdownChoose<T>> {
  final TextEditingController _searchController = TextEditingController();
  SelectData<T>? _selectedValue;
  final List<SelectData<T>> _selectedValues = [];
  List<SelectData<T>> _list = [];
  List<SelectData<T>> _filteredList = [];
  bool _isLoading = false;
  Timer? _debounceTimer; // 新增：防抖定时器
  // 保存底部弹窗的StatefulBuilder的setState，用于在其他弹窗操作后同步更新底部可选区域
  StateSetter? _modalSetState;
  // 远程搜索不再自动触发，必须点击“搜索”按钮
  // 弹窗显示且当前没有数据时，允许自动触发一次搜索
  bool _hasTriggeredInitialFetch = false;

  @override
  void initState() {
    super.initState();
    assert(widget.list != null || widget.remoteFetch != null, 'DropdownChoose: 必须传入list或remoteFetch中的一个');
    assert(!(widget.filterable && widget.remote), 'DropdownChoose: filterable和remote不能同时使用，filterable用于本地筛选，remote用于远程搜索');
    assert(!widget.remote || widget.remoteFetch != null, 'DropdownChoose: 使用remote时必须提供remoteFetch参数');

    // 验证defaultValue类型
    if (widget.defaultValue != null) {
      if (widget.multiple == true) {
        // 多选模式：defaultValue必须是List<SelectData<T>>
        assert(widget.defaultValue is List<SelectData<T>>, 'DropdownChoose: 多选模式下defaultValue必须是List<SelectData<T>>类型，当前类型: ${widget.defaultValue.runtimeType}');
      } else {
        // 单选模式：defaultValue必须是SelectData<T>，不能是List
        assert(
          widget.defaultValue is SelectData<T> && widget.defaultValue is! List,
          'DropdownChoose: 单选模式下defaultValue必须是SelectData<T>类型，不能是List，当前类型: ${widget.defaultValue.runtimeType}',
        );
      }
    }

    // 处理数据初始化
    _initializeData();

    // 设置默认值
    _setDefaultValues();
  }

  void _initializeData() {
    if (widget.list != null) {
      _list = List.from(widget.list!);
    }

    // 只有在非远程搜索模式下才添加默认值到数据列表
    // 远程搜索模式下，默认值会在首次搜索时处理
    if (!widget.remote) {
      _addDefaultValuesToDataList();
    }

    _filteredList = _list;
  }

  void _addDefaultValuesToDataList() {
    if (widget.defaultValue == null) return;

    if (widget.multiple == true) {
      // 多选模式：defaultValue应该是List<SelectData<T>>
      if (widget.defaultValue is List<SelectData<T>>) {
        final defaultList = widget.defaultValue as List<SelectData<T>>;
        for (final item in defaultList) {
          if (!_list.any((existing) => existing.value == item.value)) {
            _list.add(item);
          }
        }
      }
    } else {
      // 单选模式：defaultValue应该是SelectData<T>
      if (widget.defaultValue is SelectData<T>) {
        final defaultItem = widget.defaultValue as SelectData<T>;
        if (!_list.any((existing) => existing.value == defaultItem.value)) {
          _list.add(defaultItem);
        }
      }
    }
  }

  void _setDefaultValues() {
    if (widget.defaultValue == null) return;

    if (widget.multiple == true) {
      // 多选模式
      if (widget.defaultValue is List<SelectData<T>>) {
        final defaultList = widget.defaultValue as List<SelectData<T>>;
        if (widget.remote) {
          // 远程模式：直接设置默认值，不依赖_list匹配
          _selectedValues.addAll(defaultList);
        } else {
          // 本地模式：只在_list中找到的才设置
          for (final item in defaultList) {
            if (_list.any((existing) => existing.value == item.value)) {
              _selectedValues.add(item);
            }
          }
        }
      }
    } else {
      // 单选模式
      if (widget.defaultValue is SelectData<T>) {
        final defaultItem = widget.defaultValue as SelectData<T>;
        if (widget.remote) {
          // 远程模式：直接设置默认值，不依赖_list匹配
          _selectedValue = defaultItem;
        } else {
          // 本地模式：只在_list中找到的才设置
          if (_list.any((item) => item.value == defaultItem.value)) {
            _selectedValue = defaultItem;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel(); // 新增：取消防抖定时器
    super.dispose();
  }

  void _onSearchChanged(StateSetter updateState) {
    if (widget.filterable) {
      _filterLocalData();
      updateState(() {});
    } else if (widget.remote && widget.remoteFetch != null) {
      // 远程搜索模式：不自动搜索，仅更新本地输入状态
      // 不进行任何远程调用
    }
  }

  void _filterLocalData() {
    final keyword = _searchController.text.toLowerCase().trim();
    if (keyword.isEmpty) {
      _filteredList = _list;
    } else {
      _filteredList = _list.where((item) => item.label.toLowerCase().contains(keyword)).toList();
    }
  }

  // 根据 value 在当前列表中查找对应的项（用于单选Radio的选中同步）
  SelectData<T>? _findItemInListByValue(dynamic value) {
    if (value == null) return null;
    for (final item in _list) {
      if (item.value == value) return item;
    }
    return null;
  }

  // 判断多选列表里是否已包含某个 value（避免引用不一致导致的 contains 失效）
  bool _multiSelectedContainsValue(dynamic value) {
    return _selectedValues.any((e) => e.value == value);
  }

  // 从多选列表中按 value 移除对应项
  void _multiSelectedRemoveByValue(dynamic value) {
    _selectedValues.removeWhere((e) => e.value == value);
  }

  void _showDialog() async {
    if (!mounted) return;

    // 显示弹窗
    final modalFuture = showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              // 记录底部弹窗的setState，便于在其他地方（如“已选择”弹窗）触发刷新
              _modalSetState = setState;
              // 弹窗显示时如果没有任何数据，仅自动触发一次搜索；其余情况必须点击“搜索”按钮
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (widget.remote && widget.remoteFetch != null && !_hasTriggeredInitialFetch && _list.isEmpty) {
                  _hasTriggeredInitialFetch = true;
                  _performRemoteSearchInModal(setState);
                }
              });

              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  children: [
                    // 顶部标题区域
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.multiple == false ? (widget.singleTitleText ?? '请选择') : (widget.multipleTitleText ?? '请选择（可多选）'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                              child: const Icon(Icons.close, size: 20, color: Color(0xFF666666)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 搜索区域
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
                      ),
                      child: Row(
                        spacing: 10,
                        children: [
                          Expanded(
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: widget.remote ? '请输入关键字搜索' : '请输入关键字筛选',
                                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
                                ),
                                onChanged: (value) {
                                  _onSearchChanged(setState);
                                },
                              ),
                            ),
                          ),
                          if (widget.remote && widget.remoteFetch != null)
                            SizedBox(
                              height: 45,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        await _performRemoteSearchInModal(setState);
                                      },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  backgroundColor: _isLoading ? Colors.grey[300] : const Color(0xFF007AFF),
                                  foregroundColor: _isLoading ? Colors.grey[500] : Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.grey)),
                                      )
                                    : const Icon(Icons.search, size: 18),
                                label: Text(_isLoading ? '搜索中...' : '搜索', style: const TextStyle(fontSize: 14)),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // 选项列表
                    Expanded(
                      child: Container(
                        color: Colors.grey[50],
                        child: _isLoading
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)), strokeWidth: 3),
                                    const SizedBox(height: 16),
                                    Text(
                                      '搜索中...',
                                      style: TextStyle(color: Color(0xFF666666), fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('正在为您搜索相关数据', style: TextStyle(color: Color(0xFF999999), fontSize: 14)),
                                  ],
                                ),
                              )
                            : Builder(
                                builder: (context) {
                                  final bool showAddFooter = widget.remote && widget.showAdd == true;
                                  if (_filteredList.isEmpty && !showAddFooter) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                          const SizedBox(height: 16),
                                          Text('暂无数据', style: TextStyle(color: Color(0xFF666666), fontSize: 16)),
                                          const SizedBox(height: 8),
                                          Text(widget.remote ? '请尝试其他关键词搜索' : '请尝试其他筛选条件', style: TextStyle(color: Color(0xFF999999), fontSize: 14)),
                                        ],
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    itemCount: _filteredList.length + (showAddFooter ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      final bool isFooter = showAddFooter && index == _filteredList.length;
                                      if (isFooter) {
                                        return InkWell(
                                          onTap: () {
                                            print('Add');
                                            widget.onAdd?.call(_searchController.text);
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(top: 12, right: 12, left: 12, bottom: 16),
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.grey[200]!),
                                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))],
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Icon(Icons.info_outline, color: Colors.grey[500], size: 18),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: RichText(
                                                    text: const TextSpan(
                                                      style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                                                      children: [
                                                        TextSpan(text: '没有查询到你想要的内容，'),
                                                        TextSpan(
                                                          text: '去新增',
                                                          style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w600),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                TextButton(
                                                  onPressed: () {
                                                    print('Add');
                                                    widget.onAdd?.call(_searchController.text);
                                                  },
                                                  child: const Text('去新增'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                      final item = _filteredList[index];
                                      final isSelected = widget.multiple == false ? (_selectedValue?.value == item.value) : _selectedValues.any((e) => e.value == item.value);
                                      return Container(
                                        margin: EdgeInsets.only(top: 12, right: 12, left: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: isSelected ? const Color(0xFF007AFF) : Colors.grey[200]!),
                                          boxShadow: isSelected
                                              ? [BoxShadow(color: const Color(0xFF007AFF).withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]
                                              : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))],
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                          title: Text(
                                            item.label,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                              color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF333333),
                                            ),
                                          ),
                                          leading: widget.multiple == true
                                              ? Checkbox(
                                                  value: isSelected,
                                                  activeColor: const Color(0xFF007AFF),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      if (value == true) {
                                                        _selectedValues.add(item);
                                                      } else {
                                                        _selectedValues.remove(item);
                                                      }
                                                    });
                                                  },
                                                )
                                              : widget.multiple == false
                                              ? Radio<SelectData<T>>(
                                                  value: item,
                                                  groupValue: _findItemInListByValue(_selectedValue?.value),
                                                  activeColor: const Color(0xFF007AFF),
                                                  onChanged: (SelectData<T>? item) {
                                                    onSelectRadio(item, setState);
                                                  },
                                                )
                                              : null,
                                          onTap: () {
                                            if (widget.multiple == false) {
                                              onSelectRadio(item, setState);
                                            } else if (widget.multiple == true) {
                                              setState(() {
                                                if (_multiSelectedContainsValue(item.value)) {
                                                  _multiSelectedRemoveByValue(item.value);
                                                } else {
                                                  _selectedValues.add(item);
                                                }
                                              });
                                            }
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ),
                    // 多选模式下的底部按钮区域
                    if (widget.multiple == true)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(top: BorderSide(color: Colors.grey[100]!, width: 1)),
                        ),
                        child: Row(
                          children: [
                            // 左侧：已选择按钮
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _selectedValues.isEmpty
                                    ? null
                                    : () {
                                        _showSelectedItemsDialog(context);
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _selectedValues.isEmpty ? Colors.grey[400] : const Color(0xFF007AFF),
                                  side: BorderSide(color: _selectedValues.isEmpty ? Colors.grey[300]! : const Color(0xFF007AFF), width: 1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: Icon(Icons.check_circle_outline, size: 18, color: _selectedValues.isEmpty ? Colors.grey[400] : const Color(0xFF007AFF)),
                                label: Text(
                                  '已选择 (${_selectedValues.length})',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _selectedValues.isEmpty ? Colors.grey[400] : const Color(0xFF007AFF)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // 右侧：确认选择按钮
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _selectedValues.isEmpty
                                    ? null
                                    : () {
                                        widget.onMultipleSelected?.call(_selectedValues);
                                        Navigator.of(context).pop();
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedValues.isEmpty ? Colors.grey[200] : const Color(0xFF007AFF),
                                  foregroundColor: _selectedValues.isEmpty ? Colors.grey[500] : Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  elevation: 0,
                                ),
                                icon: Icon(Icons.check, size: 18, color: _selectedValues.isEmpty ? Colors.grey[500] : Colors.white),
                                label: Text(
                                  '确认选择',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _selectedValues.isEmpty ? Colors.grey[500] : Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
    // 弹窗关闭后，清理setState引用并重置首次搜索标志
    modalFuture.whenComplete(() {
      _modalSetState = null;
      _hasTriggeredInitialFetch = false;
    });
  }

  // 显示已选择项目的弹窗
  void _showSelectedItemsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            return AlertDialog(
              title: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF007AFF), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '已选择的项目',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                          ),
                          Text('共 ${_selectedValues.length} 项', style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: _selectedValues.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text(
                              '暂未选择任何项目',
                              style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            const Text('请返回选择一些项目', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _selectedValues.length,
                        itemBuilder: (context, index) {
                          final item = _selectedValues[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: const Color(0xFFE9ECEF)),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: const Color(0xFF007AFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                  child: const Icon(Icons.check_circle, color: Color(0xFF007AFF), size: 16),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.label,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF333333)),
                                      ),
                                      if (item.value != null) Text('值: ${item.value}', style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                                    ],
                                  ),
                                ),
                                // 移除按钮
                                Container(
                                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                                  child: IconButton(
                                    onPressed: () {
                                      // 更新主弹窗的状态
                                      setState(() {
                                        _selectedValues.remove(item);
                                      });
                                      // 同步刷新底部弹窗的可选列表和底部按钮状态
                                      _modalSetState?.call(() {});
                                      // 刷新当前弹窗内容
                                      dialogSetState(() {});
                                    },
                                    icon: Icon(Icons.remove_circle_outline, color: Colors.red[400], size: 20),
                                    tooltip: '移除',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _selectedValues.isEmpty ? Colors.grey[400] : const Color(0xFF007AFF),
                              side: BorderSide(color: _selectedValues.isEmpty ? Colors.grey[300]! : const Color(0xFF007AFF), width: 1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('关闭', style: TextStyle(fontSize: 16, color: Color(0xFF666666))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _selectedValues.isEmpty
                                ? null
                                : () {
                                    Navigator.of(context).pop();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedValues.isEmpty ? Colors.grey[200] : const Color(0xFF007AFF),
                              foregroundColor: _selectedValues.isEmpty ? Colors.grey[500] : Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                            ),
                            child: const Text('确认', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            );
          },
        );
      },
    );
  }

  // 新增：在弹窗内部执行远程搜索的方法
  Future<void> _performRemoteSearchInModal(StateSetter setState) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final list = await widget.remoteFetch?.call(_searchController.text);
      if (mounted) {
        setState(() {
          _list = List.from(list ?? []);

          // 仅在搜索框为空（初次或清空搜索）时，才将默认值合并进列表用于编辑回显
          // 有关键字时严格按搜索结果展示
          if (_searchController.text.isEmpty && widget.defaultValue != null) {
            _addDefaultValuesToDataList();
          }

          _filteredList = _list;
          // 远程搜索后保持已选中项的高亮（单选）
          if (widget.multiple != true && _selectedValue != null) {
            final matched = _findItemInListByValue(_selectedValue?.value);
            if (matched != null) {
              _selectedValue = matched;
            }
          }
          // 远程搜索后保持已选中项的高亮（多选）
          if (widget.multiple == true && widget.defaultValue != null) {
            if (widget.defaultValue is List<SelectData<T>>) {
              final defaultList = widget.defaultValue as List<SelectData<T>>;
              for (final defaultItem in defaultList) {
                final matched = _findItemInListByValue(defaultItem.value);
                if (matched != null && !_multiSelectedContainsValue(matched.value)) {
                  _selectedValues.add(matched);
                }
              }
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('远程搜索失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: widget.multiple == true
                  ? (_selectedValues.isEmpty
                        ? Text(widget.placeholderText ?? '请选择选项', style: const TextStyle(fontSize: 16, color: Color(0xFF999999)))
                        : SizedBox(
                            height: 30,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedValues.length,
                              separatorBuilder: (context, idx) => const SizedBox(width: 8),
                              itemBuilder: (context, idx) {
                                final val = _selectedValues[idx];
                                return Container(
                                  alignment: Alignment(0, 0),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF4FF),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFF007AFF)),
                                  ),
                                  child: Text(val.label, style: const TextStyle(fontSize: 15, color: Color(0xFF007AFF))),
                                );
                              },
                            ),
                          ))
                  : Text(
                      _selectedValue?.label ?? (widget.placeholderText ?? '请选择选项'),
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedValue != null ? const Color(0xFF333333) : const Color(0xFF999999),
                        fontWeight: _selectedValue != null ? FontWeight.w500 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600], size: 20),
            ),
          ],
        ),
      ),
    );
  }

  // 单选结果点击：统一处理，并打印详细信息
  onSelectRadio(SelectData<T>? value, StateSetter modalSetState) {
    if (value == null) return;
    // 更新当前组件选中值
    modalSetState(() {
      _selectedValue = value;
    });
    // 回调上抛
    widget.onSingleSelected?.call(value);
    // 关闭弹窗
    Navigator.of(context).pop();
  }
}
