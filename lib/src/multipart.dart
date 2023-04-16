import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../net.dart';
import 'body.dart';

class Multipart implements Body {
  factory Multipart(List<Part> children, {ContentType? contentType}) {
    final boundary = "--dart-http-boundary-${const Uuid().v4()}";
    return Multipart._(
      children,
      contentType: _mergeContentType(contentType ?? related, {
        "boundary": boundary,
      }),
      separator: ascii.encode("--$boundary\r\n"),
      terminator: ascii.encode("--$boundary--\r\n"),
    );
  }

  const Multipart._(
    this.children, {
    required this.contentType,
    required Uint8List separator,
    required Uint8List terminator,
  })  : _separator = separator,
        _terminator = terminator;

  final Uint8List _separator; // --$boundary\r\n
  final Uint8List _terminator; // --$boundary--\r\n

  @override
  final ContentType contentType;

  final List<Part> children;

  @override
  Stream<List<int>> get content async* {
    const line = [13, 10]; // \r\n
    for (final part in children) {
      yield _separator;
      yield part.headers;
      yield* part.body.content;
      yield line;
    }
    yield _terminator;
  }

  @override
  int get length {
    var size = 0;
    for (final part in children) {
      size += _separator.length;
      size += part.headers.length;
      size += part.body.length;
      size += 2; // \r\n
    }
    return size + _terminator.length;
  }

  @override
  String toString() {
    final sb = StringBuffer();
    for (final part in children) {
      sb
        ..write(ascii.decode(_separator))
        ..write(ascii.decode(part.headers))
        ..write(part.body);
    }
    sb.write(ascii.decode(_terminator));
    return sb.toString();
  }

  static ContentType get alternative => ContentType("multipart", "alternative");

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
