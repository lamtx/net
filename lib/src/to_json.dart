import "dart:convert" as convert;

import "utilities.dart";

/// Marker for classes that are annotated by JsonDecodable
abstract interface class ToJson {
  Object? toJson();
}

extension SerializableJsonObject on ToJson {
  String serializeAsJson() {
    return convert.json.encode(toJson());
  }

  String serializeAsUrlEncoded() {
    final json = toJson();
    if (json is Map<String, Object?>) {
      return toUrlEncoded(json);
    } else {
      throw ArgumentError(
        "The `toJson` method of $runtimeType has to return to `Map<String, Object?>`",
      );
    }
  }
}
