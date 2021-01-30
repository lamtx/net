import "dart:convert";
import "dart:typed_data";

import "data_parser.dart";

class JsonReader {
  const JsonReader(Map json) : _json = json;

  factory JsonReader.decode(String s) {
    final dynamic map = json.decode(s);
    if (map is Map) {
      return JsonReader(map);
    } else {
      throw Exception("The provided json is not a map");
    }
  }

  final Map _json;

  bool hasField(String name) => _json.containsKey(name);

  Object? _get(String name) => _json[name];

  String readString(String name) => _parseString(_get(name));

  int readInt(String name) => _parseInt(_get(name)) ?? 0;

  int? readNullableInt(String name) => _parseInt(_get(name));

  double readDouble(String name) => _parseDouble(_get(name)) ?? 0;

  double? readNullableDouble(String name) => _parseDouble(_get(name));

  bool get isEmpty => _json.isEmpty;

  int get length => _json.length;

  String _parseString(Object? obj) {
    if (obj == null) {
      return "";
    }
    if (obj is String) {
      return obj;
    }
    return obj.toString();
  }

  int? _parseInt(Object? obj) {
    if (obj == null) {
      // ignore: avoid_returning_null
      return null;
    }
    if (obj is num) {
      return obj.toInt();
    }
    return int.tryParse(obj.toString());
  }

  double? _parseDouble(Object? obj) {
    if (obj == null) {
      // ignore: avoid_returning_null
      return null;
    }
    if (obj is num) {
      return obj.toDouble();
    }
    return double.tryParse(obj.toString());
  }

  bool readBool(String name) {
    final obj = _get(name);
    if (obj == null) {
      return false;
    }
    if (obj is bool) {
      return obj;
    }
    return false;
  }

  DateTime? readDate(String name) {
    final s = readString(name);
    if (s.isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(s);
    } on FormatException {
      return null;
    }
  }

  List<E> readList<E>(DataParser<E> parser, String name) {
    final array = _get(name);
    if (array is List) {
      if (array.isEmpty) {
        return const [];
      }

      return array.map((dynamic e) {
        if (e is Map) {
          return parser(JsonReader(e));
        } else {
          throw Exception("Element of list is not an object");
        }
      }).toList(growable: false);
    }
    return const [];
  }

  List<double> readDoubleList(String name) {
    final array = _get(name);
    if (array is List) {
      return array
          .map((dynamic e) => _parseDouble(e) ?? 0)
          .toList(growable: false);
    }

    return const [];
  }

  List<int> readIntList(String name) {
    final array = _get(name);
    if (array is List) {
      return array
          .map((dynamic e) => _parseInt(e) ?? 0)
          .toList(growable: false);
    }

    return const [];
  }

  List<String> readStringList(String name) {
    final array = _get(name);
    if (array is List) {
      return array.map(_parseString).toList(growable: false);
    }

    return const [];
  }

  List<Object?> readListAny(String name) {
    final array = _get(name);

    if (array is List) {
      return array.cast();
    }
    return const [];
  }

  T? readObject<T>(DataParser<T> parser, String name) {
    final data = _get(name);
    if (data is Map) {
      return parser(JsonReader(data));
    }
    return null;
  }

  JsonReader? readAny(String name) {
    final data = _get(name);
    if (data is Map) {
      return JsonReader(data);
    }
    return null;
  }

  List<JsonReader> readArray(String name) {
    final array = _get(name);

    if (array is List) {
      return array
          .map((dynamic e) => e is Map
              ? JsonReader(e)
              : (throw Exception("$name is not a list of dictionary")))
          .toList(growable: false);
    }
    return const [];
  }

  Map? readMap(String name) {
    final data = _get(name);
    if (data is Map<dynamic, dynamic>) {
      return data;
    }
    return null;
  }
}

extension JsonReaderExt on JsonReader {
  Uint8List? readBase64(String name) {
    final v = readString(name);
    if (v.isEmpty) {
      return null;
    }
    return base64.decode(v);
  }
}
