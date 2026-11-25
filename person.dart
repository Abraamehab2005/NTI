abstract class Person {
  final String id;
  String name;
  String email;

  Person(this.id, this.name, this.email);

  String get role;

  @override
  String toString() => '[$id] $name <$email> ($role)';
}
