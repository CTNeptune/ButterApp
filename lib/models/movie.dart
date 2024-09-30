import 'dart:convert';

import 'package:hive/hive.dart';
import 'movie_format.dart';
import 'three_d_type.dart';

part 'movie.g.dart';

@HiveType(typeId: 0)
class Movie extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  List<MovieFormat> formats;

  @HiveField(3)
  late bool is3D;

  @HiveField(4)
  List<ThreeDType> devicesRequiredFor3D;

  @HiveField(5)
  List<String>? tags;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  String? userId;

  @HiveField(8)
  String? catalogId;

  Movie({
    required this.id,
    required this.name,
    required this.formats,
    required this.is3D,
    required this.devicesRequiredFor3D,
    this.tags,
    this.notes,
    this.userId,
    this.catalogId,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      name: json['name'],
      formats: (jsonDecode(json['formats']) as List<dynamic>)
        .map((format) => MovieFormatExtension.fromJson(format))
        .toList(),
      is3D: json['is3D'] == 1,
      devicesRequiredFor3D: (jsonDecode(json['devicesRequiredFor3D']) as List<dynamic>)
        .map((device) => ThreeDTypeExtension.fromJson(device))
        .toList(),
      tags: (jsonDecode(json['tags']) as List<dynamic>?)
        ?.map((tag) => tag as String)
        .toList(),
      notes: json['notes'],
      userId: json['userId'],
      catalogId: json['catalogId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'name': name,
      'formats': formats.map((format) => format.toJson()).toList(),
      'is3D': is3D,
      'devicesRequiredFor3D': devicesRequiredFor3D.map((device) => device.toJson()).toList(),
      'tags': tags,
      'notes': notes,
      'userId': userId,
      'catalogId': catalogId,
    };
  }
}
