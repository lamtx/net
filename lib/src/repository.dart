import "copy_stream_listener.dart";
import "data_parser.dart";
import "service_builder.dart";

abstract class Repository {
  const Repository();

  Future<String> getString(Request builder, [CopyStreamListener listener]);

  Future<T> get<T>(Request builder, DataParser<T> parser, [CopyStreamListener listener]) async {
    final response = await getString(builder, listener);
    if (response == null || response.isEmpty) {
      return null;
    }
    return parser.parseObject(response);
  }

  Future<List<T>> getList<T>(Request builder, DataParser<T> parser, [CopyStreamListener listener]) async {
    final response = await getString(builder, listener);
    if (response == null || response.isEmpty) {
      return const [];
    }
    return parser.parseList(response);
  }
}
