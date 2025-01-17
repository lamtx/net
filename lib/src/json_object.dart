import "dart:convert" as convert;

import '../net.dart';
import 'utilities.dart';

abstract interface class JsonObject {
  ///
  /// JsonObject accepts [String], [num], [bool], [DateTime], [Enum], [Null], [List] or [Map] of primitive type
  Object? describeContent();
}

Object? _normalize(Object? value) {
  assert(
      value == null ||
          value is num ||
          value is String ||
          value is bool ||
          value is DateTime ||
          value is JsonObject ||
          value is List<dynamic> ||
          value is Map<dynamic, dynamic> ||
          value is Enum,
      "Type ${value.runtimeType} is not supported to convert to json");

  if (value == null || value is num || value is String || value is bool) {
    return value;
  }
  if (value is DateTime) {
    return value.toUtc().toIso8601String();
  }

  if (value is JsonObject) {
    return value.toJson();
  }
  if (value is ToJson) {
    return value.toJson();
  }

  if (value is Enum) {
    return value.index;
  }

  if (value is List<JsonObject>) {
    return value.toJson();
  }

  if (value is Map) {
    final dest = <String, Object>{};
    value.forEach((k, v) {
      if (k is String) {
        final normalized = _normalize(v);
        if (normalized != null) {
          // reject null
          dest[k] = normalized;
        }
      } else {
        throw StateError("The key $k is not a string");
      }
    });
    return dest;
  }

  if (value is List) {
    final dest = <Object>[];
    for (final e in value) {
      final normalized = _normalize(e);
      if (normalized != null) {
        // reject null
        dest.add(normalized);
      }
    }
    return dest;
  }
  throw UnsupportedError("Unsupported json type ${value.runtimeType}");
}

extension SerializableObject on JsonObject {
  Object? toJson() {
    return _normalize(describeContent());
  }

  String serializeAsJson() {
    return convert.json.encode(toJson());
  }

  String serializeAsUrlEncoded() {
    final json = toJson();
    if (json is Map<String, Object?>) {
      return toUrlEncoded(json);
    } else {
      throw UnsupportedError("Not is a map");
    }
  }
}

extension SerializableListObject on List<JsonObject?> {
  List<Object?> toJson() {
    return map((e) => e?.toJson()).toList(growable: false);
  }

  String serializeAsJson() {
    return convert.json.encode(toJson());
  }
}

extension SerializableJson on Map<String, Object?> {
  Object? toJson() {
    return _normalize(this);
  }

  String serializeAsJson() {
    final dest = _normalize(this);
    return convert.json.encode(dest);
  }
}

extension SerializableJsonList on List<Object?> {
  Object? toJson() {
    return _normalize(this);
  }

  String serializeAsJson() {
    final dest = _normalize(this);
    return convert.json.encode(dest);
  }
}
