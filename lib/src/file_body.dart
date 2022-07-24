import 'dart:io';

import 'package:mime/mime.dart';

import 'body.dart';

class FileBody implements Body {
  FileBody(File file, {ContentType? contentType})
      : _file = file,
        contentType =
            contentType ?? _lookupMimeType(file) ?? ContentType.binary;

  final File _file;

  @override
  final ContentType contentType;

  @override
  Stream<List<int>> get content => _file.openRead();

  @override
  int get length => _file.lengthSync();

  @override
  String toString() => "File ${_file.path}";

  static ContentType? _lookupMimeType(File file) {
    final mimeType = lookupMimeType(file.path);
    return mimeType == null ? null : ContentType.parse(mimeType);
  }
}
