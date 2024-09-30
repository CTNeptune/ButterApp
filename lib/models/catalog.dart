import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'movie.dart';

part 'catalog.g.dart';

@HiveType(typeId: 1)
class Catalog {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? notes;

  @HiveField(3)
  List<String>? tags;

  @HiveField(4)
  List<Movie> movies;

  Catalog({
    required this.id,
    required this.name,
    this.notes,
    this.tags,
    required this.movies,
  });

  factory Catalog.fromJson(Map<String, dynamic> json) {
    return Catalog(
      id: json['id'],
      name: json['name'],
      notes: json['notes'],
      tags: json['tags'] != null ? List<String>.from(jsonDecode(json['tags'])) : null,
      movies: List.empty(growable: true),
    );
  }

  ValueListenable<List<Movie>> listenable() {
    return ValueNotifier(movies);
  }
}
