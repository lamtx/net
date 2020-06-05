import "dart:convert";

import "json_reader.dart";

typedef DataParser<T> = T Function(JsonReader jsonReader);

extension ParseData<T> on DataParser<T> {
  T parseJson(Map<dynamic, dynamic> json) {
    return this(JsonReader(json));
  }

  T parseObject(String s) {
    return this(JsonReader.decode(s));
  }
  
  T tryParseObject(String s) {
    try {
      return parseObject(s);
    } on Exception {
      return null;
    }
  }

  List<T> parseList(String s) {
    final array = json.decode(s) as List;
    final result = List<T>(array.length);

    var i = 0;
    for (final e in array) {
      result[i++] = this(JsonReader(e as Map));
    }

    return result;
  }
}
