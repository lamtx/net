/// Marker for classes that are annotated by JsonDecodable
abstract interface class ToJson {
  Map<String, Object?> toJson();
}
