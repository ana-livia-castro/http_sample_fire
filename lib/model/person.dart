class Person {
  final String name;
  final int age;
  final String key;

  Person(this.name, this.age, this.key);

  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        age = json['age'],
        key = json['key'];
}
