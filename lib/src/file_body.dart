import 'dart:io';

import 'body.dart';

class FileBody implements Body {
  FileBody(File file) : _file = file;

  final File _file;

  @override
  ContentType get contentType => ContentType.binary;

  @override
  Stream<List<int>> get content => _file.openRead();

  @override
  int get length => _file.lengthSync();

  @override
  String toString() => "File ${_file.path}";
}
