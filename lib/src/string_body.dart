import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' show ByteStream;

import 'body.dart';
import 'json_object.dart';
import 'utilities.dart';

class StringBody implements Body {
  StringBody(String content, this.contentType)
      : assert(content.isNotEmpty),
        _data = getEncoding(contentType).encode(content);

  factory StringBody.json(Map<String, Object?> object) {
    return StringBody(object.serializeAsJson(), ContentType.json);
  }

  factory StringBody.jsonList(List<Object?> object) {
    return StringBody(object.serializeAsJson(), ContentType.json);
  }

  factory StringBody.urlEncoded(Map<String, Object?> params) {
    return StringBody(
      toUrlEncoded(params),
      ContentType.parse("application/x-www-form-urlencoded"),
    );
  }

  final List<int> _data;
  @override
  final ContentType contentType;

  @override
  Stream<List<int>> get content {
    return ByteStream.fromBytes(_data);
  }

  @override
  int get length => _data.length;

  @override
  String toString() => utf8.decode(_data);

  static Encoding getEncoding(ContentType? contentType) {
    String? charset;
    if (contentType != null && contentType.charset != null) {
      charset = contentType.charset;
    } else {
      charset = "iso-8859-1";
    }
    return Encoding.getByName(charset) ??
        (throw Exception("Unknown charset $charset"));
  }
}
