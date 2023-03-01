import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';

abstract class Body {
  factory Body(Uint8List content, ContentType contentType) = _Body;

  ContentType get contentType;

  Stream<List<int>> get content;

  int get length;
}

class _Body implements Body {
  const _Body(this.data, this.contentType);

  final Uint8List data;

  @override
  Stream<List<int>> get content => ByteStream.fromBytes(data);

  @override
  final ContentType contentType;

  @override
  int get length => data.length;
}
