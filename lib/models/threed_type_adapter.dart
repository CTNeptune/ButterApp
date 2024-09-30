import 'package:hive/hive.dart';
import 'three_d_type.dart';

class ThreeDTypeAdapter extends TypeAdapter<ThreeDType> {
  @override
  final int typeId = 3;
  
  @override
  ThreeDType read(BinaryReader reader) {
    return ThreeDType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, ThreeDType obj) {
    writer.writeByte(obj.index);
  }
}
