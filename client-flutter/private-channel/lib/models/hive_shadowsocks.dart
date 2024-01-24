import 'package:hive/hive.dart';
import 'package:xinlake_tunnel/xinlake_tunnel.dart' as xt;

// type id can not greater than 300
/// typeId: 31
class ShadowsocksAdapter extends TypeAdapter<xt.Shadowsocks> {
  @override
  int get typeId => 31;

  @override
  xt.Shadowsocks read(BinaryReader reader) {
    final map = reader.readMap();
    return xt.Shadowsocks.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, xt.Shadowsocks obj) {
    writer.writeMap(obj.toMap());
  }
}
