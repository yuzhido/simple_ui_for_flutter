// 公有数据结构
class SelectData<T> {
  final String label;
  final dynamic value;
  final T? data;
  const SelectData({required this.label, required this.value, this.data});
}
