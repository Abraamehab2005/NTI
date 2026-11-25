import 'config.dart';
import 'academic_exception.dart';
import 'course.dart';
import 'student.dart';
import 'teacher.dart';

class AcademicSystem {
  final Map<String, Student> students = {};
  final Map<String, Teacher> teachers = {};
  final Map<String, Course> courses = {};
  final List<List<double>> examGrades = []; 
  final Map<String, Map<String, double>> studentGrades =
      {}; 
  final Set<Set<String>> studentSkills = {}; 

  int _studentSeq = 0;
  int _teacherSeq = 0;

  // registration 
  Student registerStudent(String name, String email) {
    final id = 'S${(++_studentSeq).toString().padLeft(3, '0')}';
    final s = Student(id, name, email);
    students[id] = s;
    examGrades.add(s.examScores);
    studentGrades[id] = {};
    studentSkills.add(s.skills);
    return s;
  }

  Teacher registerTeacher(String name, String email) {
    final id = 'T${(++_teacherSeq).toString().padLeft(3, '0')}';
    final t = Teacher(id, name, email);
    teachers[id] = t;
    return t;
  }

  Course createCourse(String code, String name, int capacity) {
    final key = code.toUpperCase();
    if (courses.containsKey(key)) {
      throw AcademicException('Course code "$key" already exists.');
    }
    if (capacity <= 0) throw AcademicException('Capacity must be positive.');
    final c = Course(key, name, capacity);
    courses[key] = c;
    return c;
  }

  //  lookups 
  Student getStudent(String id) =>
      students[id.toUpperCase()] ??
      (throw AcademicException('Student "$id" not found.'));

  Teacher getTeacher(String id) =>
      teachers[id.toUpperCase()] ??
      (throw AcademicException('Teacher "$id" not found.'));

  Course getCourse(String code) =>
      courses[code.toUpperCase()] ??
      (throw AcademicException('Course "$code" not found.'));

  //  operations 
  void assignTeacher(String courseCode, String teacherId) {
    final c = getCourse(courseCode);
    final t = getTeacher(teacherId);
    c.teacher?.courses.remove(c.code);
    c.teacher = t;
    t.courses[c.code] = c;
  }

  void enroll(String studentId, String courseCode) {
    final s = getStudent(studentId);
    final c = getCourse(courseCode);
    if (s.enrolled.containsKey(c.code)) {
      throw AcademicException('${s.name} is already enrolled in ${c.code}.');
    }
    if (c.isFull) {
      throw AcademicException(
          '${c.code} is full (${c.capacity}/${c.capacity}).');
    }
    c.enrolledIds.add(s.id);
    s.enrolled[c.code] = c;
  }

  void recordGrade(String studentId, String courseCode, double grade) {
    final s = getStudent(studentId);
    final c = getCourse(courseCode);
    if (!s.enrolled.containsKey(c.code)) {
      throw AcademicException('${s.name} is not enrolled in ${c.code}.');
    }
    if (grade < 0 || grade > 100) {
      throw AcademicException('Grade must be between 0 and 100.');
    }
    s.addGrade(c.code, grade);
    studentGrades[s.id]![c.code] = s.courseAverage(c.code)!;
  }

  void recordAttendance(String studentId, String courseCode, bool present) {
    final s = getStudent(studentId);
    final c = getCourse(courseCode);
    if (!s.enrolled.containsKey(c.code)) {
      throw AcademicException('${s.name} is not enrolled in ${c.code}.');
    }
    s.addAttendance(c.code, present);
  }

  List<MapEntry<Student, Course>> lowAttendanceFlags() {
    final flags = <MapEntry<Student, Course>>[];
    for (final s in students.values) {
      for (final c in s.enrolled.values) {
        final p = s.attendancePercent(c.code);
        if (p != null && p < kRequiredAttendance) flags.add(MapEntry(s, c));
      }
    }
    return flags;
  }

  // ---------- search ----------
  List<Student> searchStudents(String q) {
    final k = q.toLowerCase();
    return students.values
        .where((s) =>
            s.id.toLowerCase() == k ||
            s.name.toLowerCase().contains(k) ||
            s.skills.any((x) => x.toLowerCase().contains(k)))
        .toList();
  }

  List<Course> searchCourses(String q) {
    final k = q.toLowerCase();
    return courses.values
        .where((c) =>
            c.code.toLowerCase() == k || c.name.toLowerCase().contains(k))
        .toList();
  }

  // ---------- update ----------
  void updateStudent(String id, {String? name, String? email}) {
    final s = getStudent(id);
    if (name != null && name.isNotEmpty) s.name = name;
    if (email != null && email.isNotEmpty) s.email = email;
  }

  void updateTeacher(String id, {String? name, String? email}) {
    final t = getTeacher(id);
    if (name != null && name.isNotEmpty) t.name = name;
    if (email != null && email.isNotEmpty) t.email = email;
  }

  void updateCourse(String code, {String? name, int? capacity}) {
    final c = getCourse(code);
    if (capacity != null) {
      if (capacity < c.enrolledIds.length) {
        throw AcademicException(
            'Capacity cannot be below current enrollment (${c.enrolledIds.length}).');
      }
      c.capacity = capacity;
    }
    if (name != null && name.isNotEmpty) c.name = name;
  }

  // ---------- remove ----------
  void removeStudent(String id) {
    final s = getStudent(id);
    for (final c in s.enrolled.values) {
      c.enrolledIds.remove(s.id);
    }
    examGrades.remove(s.examScores);
    studentSkills.remove(s.skills);
    studentGrades.remove(s.id);
    students.remove(s.id);
  }

  void removeTeacher(String id) {
    final t = getTeacher(id);
    for (final c in t.courses.values) {
      c.teacher = null;
    }
    teachers.remove(t.id);
  }

  void removeCourse(String code) {
    final c = getCourse(code);
    for (final sid in c.enrolledIds) {
      final s = students[sid];
      if (s == null) continue;
      s.dropCourse(c.code);
      studentGrades[sid]?.remove(c.code);
    }
    c.teacher?.courses.remove(c.code);
    courses.remove(c.code);
  }

  // ---------- skills ----------
  void addSkill(String studentId, String skill) {
    final s = getStudent(studentId);
    final k = skill.trim();
    if (k.isEmpty) throw AcademicException('Skill cannot be empty.');
    if (s.skills.any((x) => x.toLowerCase() == k.toLowerCase())) {
      throw AcademicException('"$k" already exists for ${s.name}.');
    }
    s.skills.add(k);
  }

  void removeSkill(String studentId, String skill) {
    final s = getStudent(studentId);
    final match =
        s.skills.where((x) => x.toLowerCase() == skill.trim().toLowerCase());
    if (match.isEmpty) throw AcademicException('Skill "$skill" not found.');
    s.skills.remove(match.first);
  }

  void renameSkill(String studentId, String oldSkill, String newSkill) {
    removeSkill(studentId, oldSkill);
    try {
      addSkill(studentId, newSkill);
    } catch (_) {
      addSkill(studentId, oldSkill); // roll back
      rethrow;
    }
  }

  // ---------- sample data ----------
  void loadSample() {
    if (students.isNotEmpty || courses.isNotEmpty) {
      throw AcademicException(
          'Sample data can only be loaded into an empty system.');
    }
    final t = registerTeacher('Dr. Mona Hassan', 'mona@uni.edu');
    createCourse('CS101', 'Intro to Programming', 2);
    createCourse('MA201', 'Linear Algebra', 30);
    assignTeacher('CS101', t.id);
    assignTeacher('MA201', t.id);
    final a = registerStudent('Ahmed Ali', 'ahmed@uni.edu');
    final b = registerStudent('Sara Mohamed', 'sara@uni.edu');
    final c = registerStudent('Omar Khaled', 'omar@uni.edu');
    enroll(a.id, 'CS101');
    enroll(a.id, 'MA201');
    enroll(b.id, 'CS101');
    enroll(c.id, 'MA201');
    for (final g in [88.0, 92.0]) {
      recordGrade(a.id, 'CS101', g);
    }
    recordGrade(a.id, 'MA201', 75);
    for (final g in [95.0, 85.0]) {
      recordGrade(b.id, 'CS101', g);
    }
    for (final g in [50.0, 58.0]) {
      recordGrade(c.id, 'MA201', g);
    }
    for (final p in [true, true, true, true]) {
      recordAttendance(a.id, 'CS101', p);
    }
    for (final p in [true, false, true, true]) {
      recordAttendance(b.id, 'CS101', p);
    }
    for (final p in [true, false, false, true]) {
      recordAttendance(c.id, 'MA201', p);
    }
    addSkill(a.id, 'Dart');
    addSkill(a.id, 'Flutter');
    addSkill(b.id, 'Python');
    addSkill(c.id, 'SQL');
  }
}
