/// Shallow vs deep copy experiments for the three nested structures.
void demoCopies() {
  print('\n######## SHALLOW vs DEEP COPY DEMO (sample data) ########');
  _demoExamGrades();
  _demoStudentGrades();
  _demoStudentSkills();
  print('''

WHY?
A shallow copy creates a NEW outer collection, but its elements are the SAME
inner objects (lists / maps / sets) as the original - both outer collections
hold references to them. Mutating an inner object through either copy is
visible in both. A deep copy also clones every inner collection, so the copy
owns completely separate objects and changing them cannot touch the original.
''');
}

// ---- 1) examGrades : List<List<double>> ----
void _demoExamGrades() {
  print('\n--- 1) examGrades (List<List<double>>) ---');
  final original = <List<double>>[
    [80.0, 90.0],
    [70.0, 60.0],
  ];
  final shallow = List<List<double>>.of(original); // SAME inner lists
  final deep = original.map((row) => List<double>.of(row)).toList();
  print('Original : $original');
  print('Shallow  : $shallow');
  print('Deep     : $deep');

  shallow[0][0] = 100.0;
  print('\nAfter shallow[0][0] = 100:');
  print('Original : $original   <-- CHANGED');
  print('Shallow  : $shallow');
  print('Deep     : $deep');

  deep[1][0] = 0.0;
  print('\nAfter deep[1][0] = 0:');
  print('Original : $original   <-- unaffected by deep copy');
  print('Shallow  : $shallow');
  print('Deep     : $deep');
}

// ---- 2) studentGrades : Map<String, Map<String, double>> ----
void _demoStudentGrades() {
  print('\n--- 2) studentGrades (Map<String, Map<String, double>>) ---');
  final original = <String, Map<String, double>>{
    'S001': {'CS101': 90.0, 'MA201': 75.0},
    'S002': {'CS101': 85.0},
  };
  final shallow = Map<String, Map<String, double>>.of(original);
  final deep = original
      .map((id, courses) => MapEntry(id, Map<String, double>.of(courses)));
  print('Original : $original');
  print('Shallow  : $shallow');
  print('Deep     : $deep');

  shallow['S001']!['CS101'] = 50.0;
  print('\nAfter shallow["S001"]["CS101"] = 50:');
  print('Original : $original   <-- CHANGED');
  print('Shallow  : $shallow');
  print('Deep     : $deep');

  deep['S002']!['CS101'] = 10.0;
  print('\nAfter deep["S002"]["CS101"] = 10:');
  print('Original : $original   <-- unaffected by deep copy');
  print('Shallow  : $shallow');
  print('Deep     : $deep');
}

// ---- 3) studentSkills : Set<Set<String>> ----
void _demoStudentSkills() {
  print('\n--- 3) studentSkills (Set<Set<String>>) ---');
  final original = <Set<String>>{
    {'Dart', 'Flutter'},
    {'Python'},
  };
  final shallow = Set<Set<String>>.of(original);
  final deep = original.map((s) => Set<String>.of(s)).toSet();
  print('Original : $original');
  print('Shallow  : $shallow');
  print('Deep     : $deep');

  shallow.first.add('Firebase');
  print('\nAfter shallow.first.add("Firebase"):');
  print('Original : $original   <-- CHANGED');
  print('Shallow  : $shallow');
  print('Deep     : $deep');

  deep.last.remove('Python');
  print('\nAfter deep.last.remove("Python"):');
  print('Original : $original   <-- unaffected by deep copy');
  print('Shallow  : $shallow');
  print('Deep     : $deep');
}
