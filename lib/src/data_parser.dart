import "dart:convert";

import "json_reader.dart";

typedef DataParser<T> = T Function(JsonReader jsonReader);

extension ParseData<T> on DataParser<T> {
  T parseJson(Map<dynamic, dynamic> json) {
    return this(JsonReader(json));
  }

  T parseObject(String s) {
    final dynamic map = json.decode(s);
    if (map is Map) {
      return this(JsonReader(map));
    } else {
      throw Exception("The provided json is not a map.");
    }
  }

  T? tryParseObject(String s) {
    try {
      return parseObject(s);
    } on Exception {
      return null;
    }
  }

  List<T> parseList(String s) {
    final dynamic array = json.decode(s);
    if (array is List) {
      return parseJsonList(array);
    } else {
      throw Exception("The provided json is not a list.");
    }
  }

  List<T> parseJsonList(List<Object?> array) {
    return array
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => this(JsonReader(e)))
        .toList();
  }
}
