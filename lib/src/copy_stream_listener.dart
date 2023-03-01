typedef CopyStreamListener = void Function(
  int current,
  int total,
  // ignore: avoid_positional_boolean_parameters
  bool finished,
);
