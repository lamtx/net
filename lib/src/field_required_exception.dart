class FieldRequiredException implements Exception {
  FieldRequiredException(this.field);

  final String field;

  @override
  String toString() => "$field is required";
}