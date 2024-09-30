// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieAdapter extends TypeAdapter<Movie> {
  @override
  final int typeId = 0;

  @override
  Movie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Movie(
      id: fields[0] as String,
      name: fields[1] as String,
      formats: (fields[2] as List).cast<MovieFormat>(),
      is3D: fields[3] as bool,
      devicesRequiredFor3D: (fields[4] as List).cast<ThreeDType>(),
      tags: (fields[5] as List?)?.cast<String>(),
      notes: fields[6] as String?,
      userId: fields[7] as String?,
      catalogId: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.formats)
      ..writeByte(3)
      ..write(obj.is3D)
      ..writeByte(4)
      ..write(obj.devicesRequiredFor3D)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.userId)
      ..writeByte(8)
      ..write(obj.catalogId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
