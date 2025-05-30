import 'package:ext/ext.dart';

class MapToJson implements ToJson {
  MapToJson(this._map);

  final Map<String, Object?> _map;

  @override
  Object? toJson() => _map;
}
