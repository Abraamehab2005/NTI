class AcademicException implements Exception {
  final String message;
  AcademicException(this.message);

  @override
  String toString() => message;
}
