// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CatalogAdapter extends TypeAdapter<Catalog> {
  @override
  final int typeId = 1;

  @override
  Catalog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Catalog(
      id: fields[0] as String,
      name: fields[1] as String,
      notes: fields[2] as String?,
      tags: (fields[3] as List?)?.cast<String>(),
      movies: (fields[4] as List).cast<Movie>(),
    );
  }

  @override
  void write(BinaryWriter writer, Catalog obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.tags)
      ..writeByte(4)
      ..write(obj.movies);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
