import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

import 'body.dart';

class Multipart implements Body {
  factory Multipart(List<Part> children, {ContentType? contentType}) {
    final boundary = "--${const Uuid().v4()}";
    return Multipart._(
      children,
      contentType: _mergeContentType(contentType ?? related, {
        "boundary": boundary,
      }),
      boundary: ascii.encode("\r\n--$boundary\r\n"),
      boundaryEnd: ascii.encode("\r\n--$boundary--"),
    );
  }

  Multipart._(
    this.children, {
    required this.contentType,
    required Uint8List boundary,
    required Uint8List boundaryEnd,
  })  : _boundary = boundary,
        _boundaryEnd = boundaryEnd;

  final Uint8List _boundary;
  final Uint8List _boundaryEnd;

  @override
  final ContentType contentType;

  final List<Part> children;

  @override
  Stream<List<int>> get content {
    final group = StreamGroup<List<int>>();
    for (final part in children) {
      group.add(ByteStream.fromBytes(_boundary));
      group.add(ByteStream.fromBytes(part.headers));
      group.add(part.body.content);
    }
    group.add(ByteStream.fromBytes(_boundaryEnd));
    group.close();
    return group.stream;
  }

  @override
  int get length {
    var size = 0;
    for (final part in children) {
      size += _boundary.length;
      size += part.headers.length;
      size += part.body.length;
    }
    return size += _boundaryEnd.length;
  }

  @override
  String toString() {
    final sb = StringBuffer();
    for (final part in children) {
      sb.write(ascii.decode(_boundary));
      sb.write(ascii.decode(part.headers));
      sb.write(part.body);
    }
    sb.write(ascii.decode(_boundaryEnd));
    return sb.toString();
  }

  static final ContentType alternative =
      ContentType("multipart", "alternative");

  static ContentType get byteranges => ContentType("multipart", "byteranges");

  static ContentType get digest => ContentType("multipart", "digest");

  static ContentType get formData => ContentType("multipart", "form-data");

  static ContentType get mixed => ContentType("multipart", "mixed");

  static ContentType get parallel => ContentType("multipart", "parallel");

  static ContentType get related => ContentType("multipart", "related");

  static ContentType _mergeContentType(
      ContentType base, Map<String, String> params) {
    return ContentType(
      base.primaryType,
      base.subType,
      charset: base.charset,
      parameters: params,
    );
  }
}

class Part {
  Part(
    this.body, {
    Map<String, String> headers = const {},
  }) : headers = _encodeHeaders(body, headers);

  final Body body;

  final Uint8List headers;

  static Uint8List _encodeHeaders(Body body, Map<String, String> headers) {
    final sb = StringBuffer();
    for (final s in headers.entries) {
      sb.writeHeader(s.key, s.value);
    }
    sb
      ..writeHeader(HttpHeaders.contentTypeHeader, body.contentType)
      ..write("\r\n");
    return ascii.encode(sb.toString());
  }

  @override
  String toString() => "${ascii.decode(headers)}$body";
}

extension on StringBuffer {
  void writeHeader(String header, Object value) {
    this
      ..write(header)
      ..write(": ")
      ..write(value)
      ..write("\r\n");
  }
}
