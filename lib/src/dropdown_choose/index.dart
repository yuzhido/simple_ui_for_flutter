import 'package:flutter/material.dart';
import 'package:simple_ui/models/select_data.dart';
import 'package:simple_ui/src/dropdown_choose/widgets/choose_content.dart';
import 'package:simple_ui/src/widgets/dropdown_container.dart';

class DropdownChoose<T> extends StatefulWidget {
  // 是否可以过滤
  final bool filterable;
  // 是否开启远程搜索
  final bool remote;
  // 远程搜索方法-一个返回Future<List<SelectData<T>>>的函数
  final Future<List<SelectData<T>>> Function(String)? remoteSearch;
  // 是否显示新增按钮
  final bool showAdd;
  // 是否多选
  final bool multiple;
  // 新增回调
  final Function(String)? onAdd;
  // 单选模式回调 - 参数: (选中的value值, 选中的data值, 选中的完整数据)
  final void Function(dynamic, T, SelectData<T>)? onSingleChanged;
  // 多选模式回调 - 参数: (选中的value值列表, 选中的data值列表, 选中的完整数据列表)
  final void Function(List<dynamic>, List<T>, List<SelectData<T>>)? onMultipleChanged;
  // 默认展示的数据
  final List<SelectData<T>> options;
  // 占位符文本
  final String tips;
  // 默认选中的数据 - 支持单个或多个
  final dynamic defaultValue; // SelectData<T> 或 List<SelectData<T>>
  const DropdownChoose({
    super.key,
    this.filterable = false,
    this.remote = false,
    this.showAdd = false,
    this.multiple = false,
    this.onAdd,
    this.onSingleChanged,
    this.onMultipleChanged,
    this.options = const [],
    this.defaultValue,
    this.tips = '',
    this.remoteSearch,
  }) : assert(defaultValue == null || defaultValue is SelectData<T> || defaultValue is List<SelectData<T>>, 'defaultValue 必须是 null、SelectData<T> 或 List<SelectData<T>> 类型'),
       assert(!remote || remoteSearch != null, 'remote为 true 时必须提供 remoteSearch'),
       assert(!(filterable && remote), 'filterable 和 remote 不能同时为 true，请选择本地过滤或远程搜索其中一种模式');
  @override
  State<DropdownChoose<T>> createState() => _DropdownChooseState<T>();
}

class _DropdownChooseState<T> extends State<DropdownChoose<T>> {
  // 当前选中的值
  SelectData<T>? _selectedValue;
  final List<SelectData<T>> _selectedValues = [];
  // 是否正在选择
  bool isChoosing = false;
  // 缓存的远程数据
  List<SelectData<T>> _cachedOptions = [];
  // 是否已经加载过数据
  bool _hasLoadedData = false;

  @override
  void initState() {
    super.initState();
    // 初始化默认值
    _initDefaultValue();
    // 如果是远程搜索且options为空，自动加载一次数据
    _autoLoadDataIfNeeded();
  }

  // 初始化默认值
  void _initDefaultValue() {
    if (widget.defaultValue != null) {
      if (widget.multiple) {
        // 多选模式：defaultValue应该是List<SelectData<T>>
        if (widget.defaultValue is List<SelectData<T>>) {
          _selectedValues.clear();
          _selectedValues.addAll(widget.defaultValue as List<SelectData<T>>);
        }
      } else {
        // 单选模式：defaultValue应该是SelectData<T>
        if (widget.defaultValue is SelectData<T>) {
          _selectedValue = widget.defaultValue as SelectData<T>;
        }
      }
    }
  }

  // 自动加载数据（如果需要）
  void _autoLoadDataIfNeeded() async {
    // 只有在远程搜索模式下，且options为空或长度为0时，才自动加载
    if (widget.remote && widget.remoteSearch != null && (widget.options.isEmpty) && !_hasLoadedData) {
      try {
        final result = await widget.remoteSearch!('');
        if (mounted) {
          setState(() {
            _cachedOptions = result;
            _hasLoadedData = true;
          });
        }
      } catch (e) {
        // 加载失败时不做处理，保持原有逻辑
        if (mounted) {
          setState(() {
            _hasLoadedData = true; // 标记已尝试加载，避免重复请求
          });
        }
      }
    }
  }

  // 获取有效的options数据
  List<SelectData<T>> _getEffectiveOptions() {
    List<SelectData<T>> effectiveOptions;

    // 如果是远程搜索模式且有缓存数据，优先使用缓存数据
    if (widget.remote && _cachedOptions.isNotEmpty) {
      effectiveOptions = List.from(_cachedOptions);
    } else {
      // 否则使用原始的widget.options
      effectiveOptions = List.from(widget.options);
    }

    // 确保选中的数据也包含在options中，以便正确显示选中状态
    return _mergeSelectedItemsWithOptions(effectiveOptions);
  }

  // 将选中的项目合并到options中，确保选中状态能正确显示
  List<SelectData<T>> _mergeSelectedItemsWithOptions(List<SelectData<T>> options) {
    final Set<dynamic> existingValues = options.map((e) => e.value).toSet();
    final List<SelectData<T>> mergedOptions = List.from(options);

    if (widget.multiple) {
      // 多选模式：将不在options中的选中项添加到列表开头
      for (final selectedItem in _selectedValues) {
        if (!existingValues.contains(selectedItem.value)) {
          mergedOptions.insert(0, selectedItem);
        }
      }
    } else {
      // 单选模式：如果选中项不在options中，添加到列表开头
      if (_selectedValue != null && !existingValues.contains(_selectedValue!.value)) {
        mergedOptions.insert(0, _selectedValue!);
      }
    }

    return mergedOptions;
  }

  // 处理选中回调
  void _onSelected(SelectData<T>? selectedValue, List<SelectData<T>>? selectedValues) {
    setState(() {
      _selectedValue = selectedValue;
      _selectedValues.clear();
      _selectedValues.addAll(selectedValues ?? []);
    });

    // 调用外部回调
    if (selectedValues != null) {
      // 多选模式：调用多选回调
      if (widget.onMultipleChanged != null) {
        final values = _selectedValues.map((e) => e.value).toList(); // List<dynamic>
        final datas = _selectedValues.map((e) => e.data).toList(); // List<T>
        widget.onMultipleChanged!(values, datas, _selectedValues);
      }
    }
    if (selectedValue != null) {
      // 单选模式：调用单选回调
      final value = selectedValue.value; // dynamic
      final data = selectedValue.data; // T?
      widget.onSingleChanged!(value, data, selectedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // 点击显示弹窗
      onTap: _showDialog,
      child: DropdownContainer(
        // 是否正在选择
        isChoosing: isChoosing,
        item: _selectedValue,
        items: _selectedValues,
        multiple: widget.multiple,
        tips: widget.tips,
      ),
    );
  }

  // 显示弹窗
  _showDialog() async {
    setState(() => isChoosing = true);
    if (!mounted) {
      setState(() => isChoosing = false);
      return;
    }
    // 显示弹窗
    await showModalBottomSheet(
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
          child: ChooseContent<T>(
            options: _getEffectiveOptions(),
            filterable: widget.filterable,
            remote: widget.remote,
            remoteSearch: widget.remoteSearch,
            showAdd: widget.showAdd,
            multiple: widget.multiple,
            defaultValue: widget.multiple ? _selectedValues : _selectedValue,
            onSelected: _onSelected,
            onAdd: widget.onAdd,
          ),
          // child: StatefulBuilder(
          //   builder: (BuildContext context, StateSetter setState) {
          //     return ChooseContent();
          //   },
          // ),
        );
      },
    );
    setState(() => isChoosing = false);
  }
}
