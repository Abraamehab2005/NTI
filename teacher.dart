import 'course.dart';
import 'person.dart';

class Teacher extends Person {
  final Map<String, Course> courses = {};

  Teacher(super.id, super.name, super.email);

  @override
  String get role => 'Teacher';

  @override
  String toString() =>
      '${super.toString()} - courses: ${courses.isEmpty ? "none" : courses.keys.join(", ")}';
}
