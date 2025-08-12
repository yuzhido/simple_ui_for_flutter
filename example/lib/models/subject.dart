class Subject {
  final String? id;
  final String name;
  final String category;

  Subject({this.id, required this.name, required this.category});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(id: json['id']?.toString(), name: json['name'] ?? '', category: json['category'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {if (id != null) 'id': id, 'name': name, 'category': category};
  }
}
