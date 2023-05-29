import 'dart:io';

base class HttpStatusException implements Exception {
  const HttpStatusException(this.statusCode, this.content);

  final int statusCode;
  final String content;

  @override
  String toString() => "HTTP status $statusCode: $content";

  bool get isOk => statusCode == HttpStatus.ok;

  bool get isUnauthorized => statusCode == HttpStatus.unauthorized;

  bool get isClientError => 400 <= statusCode && statusCode < 500;
}
