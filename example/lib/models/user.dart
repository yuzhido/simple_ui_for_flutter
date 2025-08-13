class User {
  final String? id;
  final String name;
  final String gender;
  final int age;
  final String occupation;
  final String education;
  final List<String> hobbies;
  final String avatar;
  final String introduction;
  final String city;

  User({
    this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.occupation,
    required this.education,
    required this.hobbies,
    required this.avatar,
    required this.introduction,
    required this.city,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] ?? 0,
      occupation: json['occupation'] ?? '',
      education: json['education'] ?? '',
      hobbies: List<String>.from(json['hobbies'] ?? []),
      avatar: json['avatar'] ?? '',
      introduction: json['introduction'] ?? '',
      city: json['city'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'gender': gender,
      'age': age,
      'occupation': occupation,
      'education': education,
      'hobbies': hobbies,
      'avatar': avatar,
      'introduction': introduction,
      'city': city,
    };
  }
}
