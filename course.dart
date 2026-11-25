import 'reportable.dart';
import 'teacher.dart';

class Course implements Reportable {
  final String code; // unique
  String name;
  int capacity;
  Teacher? teacher;
  final Set<String> enrolledIds = {};

  Course(this.code, this.name, this.capacity);

  bool get isFull => enrolledIds.length >= capacity;

  @override
  String generateReport() {
    return '$code - $name | Teacher: ${teacher?.name ?? "unassigned"} | '
        'Seats: ${enrolledIds.length}/$capacity';
  }

  @override
  String toString() => generateReport();
}
