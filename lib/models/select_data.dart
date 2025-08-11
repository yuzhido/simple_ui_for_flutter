// 公有数据结构
class SelectData<T> {
  final String label;
  final dynamic value;
  final T data;
  const SelectData({required this.label, required this.value, required this.data});
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SelectData && runtimeType == other.runtimeType && value == other.value;
  @override
  int get hashCode => value.hashCode;
}
