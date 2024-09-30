import 'dart:math';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'models/movie.dart';
import 'models/movie_format.dart';

class MovieSearch extends StatelessWidget {
  final List<Movie> movies;
  final FloatingSearchBarController controller;
  final Function(Movie, int) onMovieSelected;

  const MovieSearch({
    super.key,
    required this.movies,
    required this.controller,
    required this.onMovieSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingSearchBar(
      automaticallyImplyBackButton: false,
      controller: controller,
      hint: 'Search this collection...',
      transitionDuration: const Duration(milliseconds: 300),
      transitionCurve: Curves.easeInOutCubic,
      physics: const BouncingScrollPhysics(),
      debounceDelay: const Duration(milliseconds: 100),
      onQueryChanged: (query) {
        controller.query = query;
        (context as Element).markNeedsBuild();
      },
      actions: [
        FloatingSearchBarAction.searchToClear(showIfClosed: false),
      ],
      builder: (context, _) {
        final filteredMovies = _filterMovies(movies);
        return SizedBox(
          height: controller.query.isEmpty
              ? min(filteredMovies.length * 64.0, 200)
              : min(
                  filteredMovies.length * 64.0,
                  MediaQuery.of(context).size.height -
                      MediaQuery.of(context).viewInsets.bottom -
                      kToolbarHeight -
                      64),
          child: Material(
            color: theme.dialogBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: filteredMovies.length,
              itemBuilder: (context, index) {
                final movie = filteredMovies[index];
                return ListTile(
                  title: Text(
                    movie.name,
                    style: theme.textTheme.bodyMedium,
                  ),
                  subtitle: Text(_buildSubtitle(movie)),
                  onTap: () {
                    controller.close();
                    onMovieSelected(movie, index);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<Movie> _filterMovies(List<Movie> movies) {
    final query = controller.query.toLowerCase();
    if (query.isEmpty) return List.empty();

    return movies.where((movie) {
      return movie.name.toLowerCase().contains(query) ||
          movie.formats.any(
              (format) => format.toString().toLowerCase().contains(query)) ||
          (movie.notes != null && movie.notes!.toLowerCase().contains(query)) ||
          movie.tags!.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  String _buildSubtitle(Movie movie) {
    final query = controller.query.toLowerCase();
    String subtitle = '';

    if (movie.formats
        .any((format) => format.toString().toLowerCase().contains(query))) {
      final matchingFormat = movie.formats.firstWhere(
        (format) => format.toString().toLowerCase().contains(query),
        orElse: () => MovieFormat.OTHER,
      );
      subtitle +=
          ' (Format: ${matchingFormat.toString().split('.').last.replaceAll('_', ' ')})';
    }

    if (movie.tags!.any((tag) => tag.toLowerCase().contains(query))) {
      final matchingTag = movie.tags!.firstWhere(
        (tag) => tag.toLowerCase().contains(query),
        orElse: () => 'Unknown',
      );
      subtitle += ' (Tag: $matchingTag)';
    }

    return subtitle;
  }
}
