import 'dart:math';
import 'package:butter/models/three_d_type.dart';
import 'package:uuid/uuid.dart';

import 'models/movie.dart';
import 'models/movie_format.dart';

class TestDataGenerator {
  static const List<MovieFormat> _allFormats = MovieFormat.values;
  static const List<ThreeDType> _all3DTypes = ThreeDType.values;
  static final List<String> _predefinedTags = ['Favorites', 'Unwatched', 'Watching', 'Watched', 'Watch List'];
  static final Random _random = Random();

  static List<Movie> generateTestMovies(int count) {
    return List.generate(count, (index) {
      bool is3D = _random.nextBool();
      var uuid = const Uuid();
      return Movie(
        id: uuid.v4(),
        name: 'Movie $index',
        formats: _generateRandomFormats(),
        is3D: is3D,
        devicesRequiredFor3D: is3D ? _generateRandom3DType() : List.empty(),
        tags: _generateRandomTags(),
        notes: 'This is a test note for movie $index.',
      );
    });
  }

  static List<MovieFormat> _generateRandomFormats() {
    final numberOfFormats = _random.nextInt(MovieFormat.values.length) + 1; // At least one format
    final formats = <MovieFormat>[];
    while (formats.length < numberOfFormats) {
      final format = _allFormats[_random.nextInt(_allFormats.length)];
      if (!formats.contains(format)) {
        formats.add(format);
      }
    }
    return formats;
  }

  static List<ThreeDType> _generateRandom3DType() {
    final numberOf3DTypes = _random.nextInt(ThreeDType.values.length) + 1; // At least one format
    final threeDTypes = <ThreeDType>[];
    while (threeDTypes.length < numberOf3DTypes) {
      final threeDType = _all3DTypes[_random.nextInt(_all3DTypes.length)];
      if (!threeDTypes.contains(threeDType)) {
        threeDTypes.add(threeDType);
      }
    }
    return threeDTypes;
  }

  static List<String> _generateRandomTags() {
    final numberOfTags = _random.nextInt(_predefinedTags.length) + 1; // At least one tag
    final tags = <String>[];
    while (tags.length < numberOfTags) {
      final tag = _predefinedTags[_random.nextInt(_predefinedTags.length)];
      if (!tags.contains(tag)) {
        tags.add(tag);
      }
    }
    return tags;
  }
}
