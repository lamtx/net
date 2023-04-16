import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../net.dart';

class Multipart implements Body {
  factory Multipart(List<Part> children, {ContentType? contentType}) {
    if (contentType != null && contentType.primaryType != "multipart") {
      throw ArgumentError("ContentType has to be `multipart`");
    }
    if (contentType?.subType == formData.subType) {
      if (!children.every((e) => e.field != null)) {
        throw ArgumentError(
            "`multipart/form-data` requires all parts containing `field`.");
      }
    } else {
      if (children.any((e) => e.field != null)) {
        throw ArgumentError(
            "`Part.field` is only used for `multipart/form-data`.");
      }
    }
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

  const Multipart._(this.children, {
    required this.contentType,
    required Uint8List separator,
    required Uint8List terminator,
  })
      : _separator = separator,
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
      sb..write(ascii.decode(_separator))..write(
          ascii.decode(part.headers))..write(part.body)..write("\r\n");
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

  static ContentType _mergeContentType(ContentType base,
      Map<String, String> params) {
    return ContentType(
      base.primaryType,
      base.subType,
      charset: base.charset,
      parameters: params,
    );
  }
}

class Part {
  Part(this.body, {
    Map<String, String> headers = const {},
    this.field,
  }) : headers = _encodeHeaders(body, field, headers);

  final Body body;

  final Uint8List headers;
  final String? field;

  @override
  String toString() => "${ascii.decode(headers)}$body";

  static Uint8List _encodeHeaders(Body body,
      String? field,
      Map<String, String> headers,) {
    final sb = StringBuffer();
    for (final s in headers.entries) {
      sb.writeHeader(s.key, s.value);
    }
    sb.writeHeader(HttpHeaders.contentTypeHeader, body.contentType);
    if (field != null) {
      final filename = body is FileBody ? body.filename : "";
      sb.writeHeader(
        "content-disposition",
        filename.isEmpty
            ? 'form-data; name="${_browserEncode(field)}"'
            : 'form-data; name="${_browserEncode(
            field)}"; filename="${_browserEncode(filename)}"',
      );
    }
    sb.write("\r\n");
    return ascii.encode(sb.toString());
  }

  static final _newlineRegExp = RegExp(r'\r\n|\r|\n');

  /// Encode [value] in the same way browsers do.
  static String _browserEncode(String value) =>
      // http://tools.ietf.org/html/rfc2388 mandates some complex encodings for
  // field names and file names, but in practice user agents seem not to
  // follow this at all. Instead, they URL-encode `\r`, `\n`, and `\r\n` as
  // `\r\n`; URL-encode `"`; and do nothing else (even for `%` or non-ASCII
  // characters). We follow their behavior.
  value.replaceAll(_newlineRegExp, '%0D%0A').replaceAll('"', '%22');
}

extension on StringBuffer {
  void writeHeader(String header, Object value) {
    this
      ..write(header)..write(": ")..write(value)..write("\r\n");
  }
}
