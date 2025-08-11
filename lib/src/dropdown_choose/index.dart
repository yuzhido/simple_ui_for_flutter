import 'package:flutter/material.dart';
import 'package:simple_ui/models/index.dart';
import 'dart:async'; // 新增：导入Timer

class DropdownChoose<T> extends StatefulWidget {
  final List<SelectData<T>>? list;
  final Future<List<SelectData<T>>> Function()? remoteFetch;
  final bool? multiple;
  // 统一使用defaultValue，支持单选和多选
  // 单选时传入 SelectData<T>?，多选时传入 List<SelectData<T>>?
  final dynamic defaultValue;
  final Function(SelectData<T>)? onSingleSelected;
  final Function(List<SelectData<T>>)? onMultipleSelected;
  final bool filterable;
  final bool remote;

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
  });

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

  @override
  void initState() {
    super.initState();
    assert(widget.list != null || widget.remoteFetch != null, 'DropdownChoose: 必须传入list或remoteFetch中的一个');
    assert(!(widget.filterable && widget.remote), 'DropdownChoose: filterable和remote不能同时使用，filterable用于本地筛选，remote用于远程搜索');
    assert(!widget.remote || widget.remoteFetch != null, 'DropdownChoose: 使用remote时必须提供remoteFetch参数');

    // 处理数据初始化
    _initializeData();

    // 设置默认值
    _setDefaultValues();
  }

  void _initializeData() {
    if (widget.list != null) {
      _list = List.from(widget.list!);
    }

    // 如果有默认值，将其合并到_list中
    _addDefaultValuesToDataList();

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
        for (final item in defaultList) {
          if (_list.any((existing) => existing.value == item.value)) {
            _selectedValues.add(item);
          }
        }
      }
    } else {
      // 单选模式
      if (widget.defaultValue is SelectData<T>) {
        final defaultItem = widget.defaultValue as SelectData<T>;
        if (_list.any((item) => item.value == defaultItem.value)) {
          _selectedValue = defaultItem;
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
      // 远程搜索模式：添加防抖自动搜索
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
        if (mounted) {
          await _performRemoteSearchInModal(updateState);
        }
      });
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
              // 在弹窗首次渲染完成后，如果是远程搜索且没有数据，立即触发数据加载
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (widget.remote && widget.remoteFetch != null && _list.isEmpty) {
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
                            widget.multiple == false ? '请选择' : '请选择（可多选）',
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 44,
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
                              height: 44,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        await _performRemoteSearchInModal(setState);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isLoading ? Colors.grey[300] : const Color(0xFF007AFF),
                                  foregroundColor: _isLoading ? Colors.grey[500] : Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                        ),
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
                                    const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                                      strokeWidth: 3,
                                    ),
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
                            : _filteredList.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    Text('暂无数据', style: TextStyle(color: Color(0xFF666666), fontSize: 16)),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.remote ? '请尝试其他关键词搜索' : '请尝试其他筛选条件',
                                      style: TextStyle(color: Color(0xFF999999), fontSize: 14),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _filteredList.length,
                                itemBuilder: (context, index) {
                                  final item = _filteredList[index];
                                  final isSelected = widget.multiple == false
                                      ? _selectedValue == item
                                      : _selectedValues.contains(item);
                                  return Container(
                                    margin: EdgeInsets.only(top: 12, right: 12, left: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: isSelected ? const Color(0xFF007AFF) : Colors.grey[200]!),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
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
                                              groupValue: _selectedValue,
                                              activeColor: const Color(0xFF007AFF),
                                              onChanged: (SelectData<T>? value) {
                                                setState(() {
                                                  _selectedValue = value;
                                                });
                                                if (value != null) widget.onSingleSelected?.call(value);
                                                Navigator.of(context).pop();
                                              },
                                            )
                                          : null,
                                      onTap: () {
                                        if (widget.multiple == false) {
                                          setState(() {
                                            _selectedValue = item;
                                          });
                                          widget.onSingleSelected?.call(item);
                                          Navigator.of(context).pop();
                                        } else if (widget.multiple == true) {
                                          setState(() {
                                            if (_selectedValues.contains(item)) {
                                              _selectedValues.remove(item);
                                            } else {
                                              _selectedValues.add(item);
                                            }
                                          });
                                        }
                                      },
                                    ),
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
                                  side: BorderSide(
                                    color: _selectedValues.isEmpty ? Colors.grey[300]! : const Color(0xFF007AFF),
                                    width: 1,
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                  color: _selectedValues.isEmpty ? Colors.grey[400] : const Color(0xFF007AFF),
                                ),
                                label: Text(
                                  '已选择 (${_selectedValues.length})',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _selectedValues.isEmpty ? Colors.grey[400] : const Color(0xFF007AFF),
                                  ),
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
                                icon: Icon(
                                  Icons.check,
                                  size: 18,
                                  color: _selectedValues.isEmpty ? Colors.grey[500] : Colors.white,
                                ),
                                label: Text(
                                  '确认选择',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _selectedValues.isEmpty ? Colors.grey[500] : Colors.white,
                                  ),
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
    // 弹窗关闭后，清理setState引用，避免后续误用
    modalFuture.whenComplete(() {
      _modalSetState = null;
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
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.check_circle, color: Color(0xFF007AFF), size: 16),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.label,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                      if (item.value != null)
                                        Text('值: ${item.value}', style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
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
                              side: BorderSide(
                                color: _selectedValues.isEmpty ? Colors.grey[300]! : const Color(0xFF007AFF),
                                width: 1,
                              ),
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
      final list = await widget.remoteFetch!();
      if (mounted) {
        setState(() {
          _list = List.from(list);

          // 确保defaultValue中的数据始终可见
          _addDefaultValuesToDataList();

          _filteredList = _list;
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
                        ? const Text('请选择选项', style: TextStyle(fontSize: 16, color: Color(0xFF999999)))
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
                      _selectedValue?.label ?? '请选择选项',
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
}
