import "dart:convert";
import "dart:typed_data";

import 'package:flutter/foundation.dart';

import "data_parser.dart";

class JsonReader {
  const JsonReader(Map<dynamic, dynamic> json) : _json = json;

  JsonReader.decode(String s) : this(json.decode(s) as Map<dynamic, dynamic>);

  final Map<dynamic, dynamic> _json;

  bool hasField(String name) => _json.containsKey(name);

  Object _get(String name) => _json[name];

  String readString(String name) => _parseString(_get(name));

  int readInt(String name) => _parseInt(_get(name)) ?? 0;

  int readNullableInt(String name) => _parseInt(_get(name));

  double readDouble(String name) => _parseDouble(_get(name)) ?? 0;

  double readNullableDouble(String name) => _parseDouble(_get(name));

  bool get isEmpty => _json.isEmpty;

  int get length => _json.length;

  String _parseString(Object obj) {
    if (obj == null) {
      return "";
    }
    if (obj is String) {
      return obj;
    }
    return obj.toString();
  }

  int _parseInt(Object obj) {
    if (obj == null) {
      // ignore: avoid_returning_null
      return null;
    }
    if (obj is num) {
      return obj.toInt();
    }
    return int.tryParse(obj.toString());
  }

  double _parseDouble(Object obj) {
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

  DateTime readDate(String name) {
    final s = readString(name);
    if (s == null || s.isEmpty) {
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

      final result = List<E>(array.length);
      var i = 0;

      for (final e in array) {
        if (e is Map) {
          result[i++] = parser(JsonReader(e));
        } else {
          assert(false, "Element of list is not an object");
          return const [];
        }
      }
      return result;
    }
    return const [];
  }

  List<double> readDoubleList(String name) {
    final array = _get(name);
    if (array is List) {
      return array.map(_parseDouble).toList(growable: false);
    }

    return const [];
  }

  List<int> readIntList(String name) {
    final array = _get(name);
    if (array is List) {
      return array.map(_parseInt).toList(growable: false);
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

  List<dynamic> readListAny(String name) {
    final array = _get(name);

    if (array is List) {
      return array;
    }
    return const <dynamic>[];
  }

  T readObject<T>(DataParser<T> parser, String name) {
    final data = _get(name);
    if (data is Map<dynamic, dynamic>) {
      return parser(JsonReader(data));
    }
    return null;
  }

  JsonReader readAny(String name) {
    final data = _get(name);
    if (data is Map<dynamic, dynamic>) {
      return JsonReader(data);
    }
    return null;
  }

  List<JsonReader> readArray(String name) {
    return readListAny(name).map((e) {
      return JsonReader(e as Map);
    }).toList(growable: false);
  }

  Map<dynamic, dynamic> readMap(String name) {
    final data = _get(name);
    if (data is Map<dynamic, dynamic>) {
      return data;
    }
    return null;
  }
}

extension JsonReaderExt on JsonReader {
  Uint8List readBase64(String name) {
    final v = readString(name);
    if (v == null) {
      return null;
    }
    return base64.decode(v);
  }

  T readEnum<T>(String name, List<T> enums) {
    final v = readString(name);
    if (v.isEmpty) {
      return null;
    }
    return enums.firstWhere((e) => describeEnum(e) == v, orElse: () => null);
  }
}
