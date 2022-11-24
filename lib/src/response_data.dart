import 'dart:io';
import 'dart:typed_data';

class ResponseData {
  const ResponseData(this.data, this.contentType);

  final Uint8List data;
  final ContentType? contentType;
}
