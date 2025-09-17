/// 用户数据模型（符合 API 文档）
class User {
  final String? id;
  final String? name;
  final int? age;
  final String? address;
  final String? school;
  final String? birthday;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({this.id, this.name, this.age, this.address, this.school, this.birthday, this.createdAt, this.updatedAt});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      age: json['age'],
      address: json['address'],
      school: json['school'],
      birthday: json['birthday'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (age != null) data['age'] = age;
    if (address != null) data['address'] = address;
    if (school != null) data['school'] = school;
    if (birthday != null) data['birthday'] = birthday;
    return data;
  }
}
