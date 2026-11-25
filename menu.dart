import 'config.dart';
import 'copy_demo.dart';
import 'academic_exception.dart';
import 'academic_system.dart';
import 'input_helper.dart';

void printMenu() {
  print('''

========== STUDENT & ACADEMIC MANAGEMENT ==========
   1. Register student
   2. Register teacher
   3. Create course
   4. Assign teacher to course
   5. Enroll student in course
   6. Record grade
   7. Record attendance (whole class session)
   8. Show course roster
   9. Search students / courses
  10. Update student / teacher / course
  11. Remove student / teacher / course
  12. Student report
  13. Flag low attendance
  14. Manage student skills
  15. List all records
  16. Shallow / Deep copy demo
  17. Load sample data
   0. Exit
===================================================''');
}

void listAll(AcademicSystem sys) {
  print('\n--- Students (${sys.students.length}) ---');
  sys.students.values.forEach(print);
  print('\n--- Teachers (${sys.teachers.length}) ---');
  sys.teachers.values.forEach(print);
  print('\n--- Courses (${sys.courses.length}) ---');
  sys.courses.values.forEach(print);
  print('\n--- examGrades ---\n${sys.examGrades}');
  print('--- studentGrades ---\n${sys.studentGrades}');
  print('--- studentSkills ---\n${sys.studentSkills}');
}

void searchMenu(AcademicSystem sys) {
  final kind = readInt('Search: 1) students  2) courses : ', min: 1, max: 2);
  final q = readString('Keyword (id / name / skill): ');
  if (kind == 1) {
    final r = sys.searchStudents(q);
    print(r.isEmpty ? 'No students found.' : r.join('\n'));
  } else {
    final r = sys.searchCourses(q);
    print(r.isEmpty ? 'No courses found.' : r.join('\n'));
  }
}

void updateMenu(AcademicSystem sys) {
  final kind =
      readInt('Update: 1) student  2) teacher  3) course : ', min: 1, max: 3);
  switch (kind) {
    case 1:
      final id = readString('Student ID: ');
      sys.getStudent(id);
      final n = readString('New name (Enter to keep): ', allowEmpty: true);
      final e = readEmail('New email (Enter to keep): ', allowEmpty: true);
      sys.updateStudent(id, name: n, email: e);
    case 2:
      final id = readString('Teacher ID: ');
      sys.getTeacher(id);
      final n = readString('New name (Enter to keep): ', allowEmpty: true);
      final e = readEmail('New email (Enter to keep): ', allowEmpty: true);
      sys.updateTeacher(id, name: n, email: e);
    case 3:
      final code = readString('Course code: ');
      sys.getCourse(code);
      final n = readString('New name (Enter to keep): ', allowEmpty: true);
      final capStr =
          readString('New capacity (Enter to keep): ', allowEmpty: true);
      int? cap;
      if (capStr.isNotEmpty) {
        cap = int.tryParse(capStr);
        if (cap == null || cap <= 0) {
          throw AcademicException('Capacity must be a positive whole number.');
        }
      }
      sys.updateCourse(code, name: n, capacity: cap);
  }
  print('Updated successfully.');
}

void removeMenu(AcademicSystem sys) {
  final kind =
      readInt('Remove: 1) student  2) teacher  3) course : ', min: 1, max: 3);
  final id = readString(kind == 3 ? 'Course code: ' : 'ID: ');
  if (!readYesNo('Really remove "$id"?')) {
    print('Cancelled.');
    return;
  }
  switch (kind) {
    case 1:
      sys.removeStudent(id);
    case 2:
      sys.removeTeacher(id);
    case 3:
      sys.removeCourse(id);
  }
  print('Removed.');
}

void skillsMenu(AcademicSystem sys) {
  final id = readString('Student ID: ');
  final s = sys.getStudent(id);
  print(
      'Current skills of ${s.name}: ${s.skills.isEmpty ? "none" : s.skills.join(", ")}');
  final a = readInt('1) add  2) rename  3) remove  4) show all skill groups : ',
      min: 1, max: 4);
  switch (a) {
    case 1:
      sys.addSkill(id, readString('Skill: '));
    case 2:
      sys.renameSkill(id, readString('Old skill: '), readString('New skill: '));
    case 3:
      sys.removeSkill(id, readString('Skill: '));
    case 4:
      print(sys.studentSkills);
      return;
  }
  print('Done. Skills now: ${s.skills.join(", ")}');
}

void recordSession(AcademicSystem sys) {
  final c = sys.getCourse(readString('Course code: '));
  if (c.enrolledIds.isEmpty) {
    throw AcademicException('No students enrolled in ${c.code}.');
  }
  print(
      'Mark attendance for ${c.code} (p = present, a = absent, Enter = present):');
  for (final sid in c.enrolledIds) {
    final s = sys.getStudent(sid);
    while (true) {
      final v = readLine('  ${s.name} [$sid]: ').toLowerCase();
      if (v.isEmpty || v == 'p') {
        sys.recordAttendance(sid, c.code, true);
        break;
      } else if (v == 'a') {
        sys.recordAttendance(sid, c.code, false);
        break;
      }
      print('  Enter p or a.');
    }
  }
}

void runMenu() {
  final sys = AcademicSystem();
  print('Welcome to the Student & Academic Management System');

  while (true) {
    printMenu();
    final choice = readInt('Choose an option: ', min: 0, max: 17);
    if (choice == 0) {
      print('Goodbye!');
      break;
    }
    try {
      switch (choice) {
        case 1:
          final s =
              sys.registerStudent(readString('Name: '), readEmail('Email: '));
          print('Registered: $s');
        case 2:
          final t =
              sys.registerTeacher(readString('Name: '), readEmail('Email: '));
          print('Registered: $t');
        case 3:
          final c = sys.createCourse(
            readString('Course code: '),
            readString('Course name: '),
            readInt('Capacity: ', min: 1),
          );
          print('Created: $c');
        case 4:
          sys.assignTeacher(
              readString('Course code: '), readString('Teacher ID: '));
          print('Teacher assigned.');
        case 5:
          sys.enroll(readString('Student ID: '), readString('Course code: '));
          print('Enrolled successfully.');
        case 6:
          sys.recordGrade(
            readString('Student ID: '),
            readString('Course code: '),
            readDouble('Grade (0-100): ', min: 0, max: 100),
          );
          print('Grade recorded.');
        case 7:
          recordSession(sys);
        case 8:
          final c = sys.getCourse(readString('Course code: '));
          print(c);
          for (final sid in c.enrolledIds) {
            print('  ${sys.getStudent(sid)}');
          }
        case 9:
          searchMenu(sys);
        case 10:
          updateMenu(sys);
        case 11:
          removeMenu(sys);
        case 12:
          print(sys.getStudent(readString('Student ID: ')).generateReport());
        case 13:
          final flags = sys.lowAttendanceFlags();
          if (flags.isEmpty) {
            print('No students below $kRequiredAttendance% attendance.');
          } else {
            for (final f in flags) {
              print('FLAG: ${f.key.name} [${f.key.id}] in ${f.value.code}: '
                  '${f.key.attendancePercent(f.value.code)!.toStringAsFixed(1)}%');
            }
          }
        case 14:
          skillsMenu(sys);
        case 15:
          listAll(sys);
        case 16:
          demoCopies();
        case 17:
          sys.loadSample();
          print(
              'Sample data loaded (students S001-S003, teacher T001, courses CS101, MA201).');
      }
    } on AcademicException catch (e) {
      print('Error: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
    }
  }
}
