import "dart:convert" as convert;

import "utilities.dart";

/// Marker for classes that are annotated by JsonDecodable
abstract interface class ToJson {
  Map<String, Object?> toJson();
}

extension SerializableJsonObject on ToJson {
  String serializeAsJson() {
    return convert.json.encode(toJson());
  }

  String serializeAsUrlEncoded() {
    return toUrlEncoded(toJson());
  }
}
