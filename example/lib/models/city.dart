class City {
  final String name;
  final String province;
  final int population;
  final int area;

  City({required this.name, required this.province, required this.population, required this.area});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(name: json['name'] ?? '', province: json['province'] ?? '', population: json['population'] ?? 0, area: json['area'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'province': province, 'population': population, 'area': area};
  }
}
