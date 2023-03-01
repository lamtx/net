class FieldRequiredException implements Exception {
  const FieldRequiredException(this.field);

  final String field;

  @override
  String toString() => "$field is required";
}

Never requiredField(String name) => throw FieldRequiredException(name);
