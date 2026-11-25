import 'dart:io';

/// Reads one trimmed line. Exits cleanly if the input stream is closed.
String readLine(String prompt) {
  stdout.write(prompt);
  final line = stdin.readLineSync();
  if (line == null) {
    print('\nInput closed. Goodbye!');
    exit(0);
  }
  return line.trim();
}

String readString(String prompt, {bool allowEmpty = false}) {
  while (true) {
    final v = readLine(prompt);
    if (v.isNotEmpty || allowEmpty) return v;
    print('  Value cannot be empty.');
  }
}

int readInt(String prompt, {int? min, int? max}) {
  while (true) {
    final v = int.tryParse(readLine(prompt));
    if (v == null) {
      print('  Please enter a whole number.');
    } else if ((min != null && v < min) || (max != null && v > max)) {
      print('  Enter a number between ${min ?? "-inf"} and ${max ?? "inf"}.');
    } else {
      return v;
    }
  }
}

double readDouble(String prompt, {double? min, double? max}) {
  while (true) {
    final v = double.tryParse(readLine(prompt));
    if (v == null || v.isNaN) {
      print('  Please enter a valid number.');
    } else if ((min != null && v < min) || (max != null && v > max)) {
      print('  Enter a value between ${min ?? "-inf"} and ${max ?? "inf"}.');
    } else {
      return v;
    }
  }
}

String readEmail(String prompt, {bool allowEmpty = false}) {
  final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  while (true) {
    final v = readLine(prompt);
    if (v.isEmpty && allowEmpty) return v;
    if (re.hasMatch(v)) return v;
    print('  Invalid email format.');
  }
}

bool readYesNo(String prompt) {
  while (true) {
    final v = readLine('$prompt (y/n): ').toLowerCase();
    if (v == 'y' || v == 'yes') return true;
    if (v == 'n' || v == 'no') return false;
    print('  Please answer y or n.');
  }
}
