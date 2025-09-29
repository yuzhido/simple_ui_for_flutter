import 'package:flutter/material.dart';
import 'package:simple_ui/models/form_config.dart';
import 'package:simple_ui/models/select_data.dart';
import 'package:simple_ui/src/config_form/config_form_controller.dart';
import 'package:simple_ui/src/config_form/widgets/index.dart';
import 'package:simple_ui/src/tree_select/index.dart';

class SelectForTree<T> extends StatefulWidget {
  final FormConfig config;
  final ConfigFormController controller;
  final void Function(Map<String, dynamic>)? onChanged;
  const SelectForTree({super.key, required this.config, required this.controller, required this.onChanged});
  @override
  State<SelectForTree> createState() => _SelectForTreeState<T>();
}

class _SelectForTreeState<T> extends State<SelectForTree> {
  late ValueNotifier<Map<String, String>> countNotifier;
  @override
  void initState() {
    countNotifier = ValueNotifier(widget.controller.errors);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final treeConfig = widget.config;
    return ValueListenableBuilder(
      valueListenable: countNotifier,
      builder: (context, _, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            LabelInfo(widget.config.label, widget.config.required),
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 18),
                  child: TreeSelect<T>(
                    key: ValueKey('treeSelect_${widget.config.name}_'), // 使用key强制重新创建组件
                    defaultValue: [],
                    options: (treeConfig.props as TreeSelectProps<T>?)?.options ?? [],
                    multiple: (treeConfig.props as TreeSelectProps<T>?)?.multiple ?? false,
                    title: (treeConfig.props as TreeSelectProps<T>?)?.title ?? '树形选择器',
                    hintText: (treeConfig.props as TreeSelectProps<T>?)?.hintText ?? '请输入关键字搜索',
                    remoteFetch: (treeConfig.props as TreeSelectProps<T>?)?.remoteFetch,
                    remote: (treeConfig.props as TreeSelectProps<T>?)?.remote ?? false,
                    filterable: (treeConfig.props as TreeSelectProps<T>?)?.filterable ?? false,
                    lazyLoad: (treeConfig.props as TreeSelectProps<T>?)?.lazyLoad ?? false,
                    lazyLoadFetch: (treeConfig.props as TreeSelectProps<T>?)?.lazyLoadFetch,
                    isCacheData: (treeConfig.props as TreeSelectProps<T>?)?.isCacheData ?? true,
                    onSingleChanged: (dynamic value, T data, SelectData<T> selectedData) {
                      final valueStr = value?.toString() ?? '';
                      widget.controller.setFieldValue(widget.config.name, valueStr);
                      (treeConfig.props as TreeSelectProps<T>?)?.onSingleChanged?.call(value, data, selectedData);
                    },
                    onMultipleChanged: (List<dynamic> values, List<T> datas, List<SelectData<T>> selectedDataList) {
                      final valueStr = values.map((v) => v?.toString() ?? '').where((s) => s.isNotEmpty).join(',');
                      widget.controller.setFieldValue(widget.config.name, valueStr);
                      (treeConfig.props as TreeSelectProps<T>?)?.onMultipleChanged?.call(values, datas, selectedDataList);
                    },
                  ),
                ),
                Positioned(bottom: 0, left: 0, child: ErrorInfo('state.errorText')),
              ],
            ),
          ],
        );
      },
    );
  }
}
