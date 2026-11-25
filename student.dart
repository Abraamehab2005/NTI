import 'config.dart';
import 'reportable.dart';
import 'course.dart';
import 'person.dart';

class Student extends Person implements Reportable {
  final Set<String> skills = {}; // unique skills
  final Map<String, Course> enrolled = {};
  final Map<String, List<double>> courseGrades = {};
  final Map<String, List<bool>> attendance = {};

  /// Flat list of every exam score of this student (one row of examGrades).
  final List<double> examScores = [];

  Student(super.id, super.name, super.email);

  @override
  String get role => 'Student';

  void addGrade(String code, double grade) {
    courseGrades.putIfAbsent(code, () => []).add(grade);
    examScores.add(grade);
  }

  void addAttendance(String code, bool present) {
    attendance.putIfAbsent(code, () => []).add(present);
  }

  void dropCourse(String code) {
    enrolled.remove(code);
    courseGrades.remove(code);
    attendance.remove(code);
    examScores
      ..clear()
      ..addAll(courseGrades.values.expand((g) => g)); // keep same list object
  }

  double? courseAverage(String code) {
    final g = courseGrades[code];
    if (g == null || g.isEmpty) return null;
    return g.reduce((a, b) => a + b) / g.length;
  }

  double? get overallAverage {
    final avgs =
        enrolled.keys.map(courseAverage).whereType<double>().toList();
    if (avgs.isEmpty) return null;
    return avgs.reduce((a, b) => a + b) / avgs.length;
  }

  double? attendancePercent(String code) {
    final a = attendance[code];
    if (a == null || a.isEmpty) return null;
    return a.where((p) => p).length * 100 / a.length;
  }

  double? get overallAttendance {
    final all = attendance.values.expand((x) => x).toList();
    if (all.isEmpty) return null;
    return all.where((p) => p).length * 100 / all.length;
  }

  static String performanceLevel(double avg) {
    if (avg >= 90) return 'Excellent';
    if (avg >= 80) return 'Very Good';
    if (avg >= 70) return 'Good';
    if (avg >= 60) return 'Pass';
    return 'Fail';
  }

  String get finalStatus {
    if (enrolled.isEmpty) return 'Not enrolled';
    final avg = overallAverage;
    if (avg == null) return 'In progress (no grades yet)';
    if (avg < kPassMark) return 'Failed (average below $kPassMark)';
    final att = overallAttendance;
    if (att != null && att < kRequiredAttendance) {
      return 'Failed (attendance below $kRequiredAttendance%)';
    }
    return 'Passed';
  }

  @override
  String generateReport() {
    final b = StringBuffer();
    b.writeln('=' * 52);
    b.writeln('STUDENT REPORT');
    b.writeln('=' * 52);
    b.writeln('ID    : $id');
    b.writeln('Name  : $name');
    b.writeln('Email : $email');
    b.writeln('Skills: ${skills.isEmpty ? "none" : skills.join(", ")}');
    b.writeln('-' * 52);
    if (enrolled.isEmpty) {
      b.writeln('Not enrolled in any course.');
    } else {
      for (final c in enrolled.values) {
        final grades = courseGrades[c.code] ?? [];
        final avg = courseAverage(c.code);
        final att = attendancePercent(c.code);
        b.writeln('${c.code} - ${c.name}');
        b.writeln(
            '  Grades    : ${grades.isEmpty ? "none" : grades.map((g) => g.toStringAsFixed(1)).join(", ")}');
        b.writeln(
            '  Average   : ${avg == null ? "-" : "${avg.toStringAsFixed(2)} (${performanceLevel(avg)})"}');
        final low = att != null && att < kRequiredAttendance ? '  << LOW' : '';
        b.writeln(
            '  Attendance: ${att == null ? "-" : "${att.toStringAsFixed(1)}%"}$low');
      }
    }
    b.writeln('-' * 52);
    final avg = overallAverage;
    final att = overallAttendance;
    b.writeln(
        'Overall average   : ${avg == null ? "-" : "${avg.toStringAsFixed(2)} (${performanceLevel(avg)})"}');
    b.writeln(
        'Overall attendance: ${att == null ? "-" : "${att.toStringAsFixed(1)}%"}');
    b.writeln('Final status      : $finalStatus');
    b.writeln('=' * 52);
    return b.toString();
  }

  @override
  String toString() =>
      '${super.toString()} - courses: ${enrolled.isEmpty ? "none" : enrolled.keys.join(", ")}';
}
