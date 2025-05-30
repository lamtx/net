import 'dart:io' show File;

import 'package:ext/ext.dart';
import 'package:http_parser/http_parser.dart';

import 'internal.dart';

sealed class Body {
  static final json = MediaType("application", "json", {"charset": "utf-8"});

  /// Content type for binary data.
  ///
  ///    application/octet-stream
  static final binary = MediaType("application", "octet-stream");
}

final class StringBody implements Body {
  const StringBody(this.content, this.contentType);

  factory StringBody.json(Map<String, Object?> json) {
    return StringBody(
      MapToJson(json).serializeAsJson(),
      Body.json,
    );
  }

  final String content;
  final MediaType contentType;

  @override
  String toString() => content;
}

final class FileBody implements Body {
  const FileBody(this.file);

  final File file;

  @override
  String toString() => "File `${file.path}`";
}

final class MultipartBody implements Body {
  MultipartBody({
    required this.children,
    MediaType? contentType,
  }) : contentType = contentType ?? related;

  final List<Part> children;
  final MediaType contentType;

  static MediaType get alternative => MediaType("multipart", "alternative");

  static MediaType get byteRanges => MediaType("multipart", "byteranges");

  static MediaType get digest => MediaType("multipart", "digest");

  static MediaType get formData => MediaType("multipart", "form-data");

  static MediaType get mixed => MediaType("multipart", "mixed");

  static MediaType get parallel => MediaType("multipart", "parallel");

  static MediaType get related => MediaType("multipart", "related");

  @override
  String toString() => "Multipart($children)";
}

final class Part {
  const Part(this.name, this.body, [this.headers = const {}]);

  final Body body;
  final String name;
  final Map<String, String> headers;

  @override
  String toString() => "Part($name=$body)";
}
