import 'package:hive/hive.dart';
import 'package:xinlake_tunnel/shadowsocks.dart';

// type id can not greater than 300
/// typeId: 31
class ShadowsocksAdapter extends TypeAdapter<Shadowsocks> {
  @override
  int get typeId => 31;

  @override
  Shadowsocks read(BinaryReader reader) {
    final map = reader.readMap();
    return Shadowsocks.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, Shadowsocks obj) {
    writer.writeMap(obj.toMap());
  }
}
