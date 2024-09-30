import 'package:hive/hive.dart';
import 'movie_format.dart';

class MovieFormatAdapter extends TypeAdapter<MovieFormat> {
  @override
  final int typeId = 2;
  
  @override
  MovieFormat read(BinaryReader reader) {
    return MovieFormat.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, MovieFormat obj) {
    writer.writeByte(obj.index);
  }
}
