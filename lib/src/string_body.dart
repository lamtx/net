import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import 'body.dart';
import 'json_object.dart';

class StringBody implements Body {
  StringBody(String content, this.contentType)
      : assert(content != null && content.isNotEmpty),
        assert(contentType != null),
        _data = getEncoding(contentType).encode(content);

  factory StringBody.json(Map<String, Object> object) {
    return StringBody(object.serializeAsJson(), ContentType.json);
  }

  factory StringBody.jsonList(List<Object> object) {
    return StringBody(object.serializeAsJson(), ContentType.json);
  }

  factory StringBody.urlEncoded(Map<String, Object> params) {
    return StringBody(
      serializeUrlEncoded(params),
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

  static Encoding getEncoding(ContentType contentType) {
    String charset;
    if (contentType != null && contentType.charset != null) {
      charset = contentType.charset;
    } else {
      charset = "iso-8859-1";
    }
    return Encoding.getByName(charset);
  }
}

String serializeUrlEncoded(Map<String, Object> params) {
  final s = StringBuffer();
  params.forEach((key, value) {
    if (value == null) {
      return;
    }
    String sValue;
    if (value is String) {
      if (value.isEmpty) {
        return;
      }
      sValue = value;
    } else if (value is num) {
      sValue = value.toString();
    } else if (value is bool) {
      sValue = value.toString();
    } else if (value is DateTime) {
      sValue = value.toUtc().toIso8601String();
    } else {
      throw UnsupportedError("Unsupport parameter type ${value.runtimeType}");
    }

    if (s.isNotEmpty) {
      s.write("&");
    }
    s
      ..write(Uri.encodeComponent(key))
      ..write("=")
      ..write(Uri.encodeComponent(sValue));
  });
  return s.toString();
}
