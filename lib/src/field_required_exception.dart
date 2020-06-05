class FieldRequiredException implements Exception {
  FieldRequiredException(this.field);

  final String field;

  @override
  String toString() => "$field is required";
}

T requires<T>(T any, String fieldName) {
  if (any == null) {
    throw FieldRequiredException(fieldName);
  }
  return any;
}

///
/// Short form for [?? (throw FieldRequiredException(fieldName))]
/// Consider remove when [Never] type supported
T required<T>(String fieldName) {
  throw FieldRequiredException(fieldName);
}
