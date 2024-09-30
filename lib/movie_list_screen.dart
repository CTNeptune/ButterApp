import 'package:butter/edit_catalog_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';

import 'edit_movie_screen.dart';
import 'add_movie_screen.dart';
import 'models/catalog.dart';
import 'models/movie.dart';
import 'models/movie_format.dart';
import 'search.dart';

class MovieListScreen extends StatefulWidget {
  final Box<Catalog> catalogBox;
  final Catalog catalog;
  final int catalogIndex;
  final Box settingsBox;

  const MovieListScreen(
      {super.key,
      required this.catalog,
      required this.catalogIndex,
      required this.catalogBox,
      required this.settingsBox});

  @override
  MovieListScreenState createState() => MovieListScreenState();
}

class MovieListScreenState extends State<MovieListScreen> {
  String _sortBy = 'Name - Ascending';
  final FloatingSearchBarController _searchBarController =
      FloatingSearchBarController();

  @override
  void dispose() {
    _searchBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.catalog.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditCatalogScreen(
                    catalog: widget.catalog,
                    catalogIndex: widget.catalogIndex,
                    catalogBox: widget.catalogBox,
                    settingsBox: Hive.box('settings'),
                  ),
                ),
              );

              if (result == true) {
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: _buildMovieList(),
          ),
          MovieSearch(
            movies: widget.catalog.movies,
            controller: _searchBarController,
            onMovieSelected: (movie, index) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditMovieScreen(
                    catalog: widget.catalog,
                    movie: movie,
                    movieIndex: index,
                    settingsBox: Hive.box('settings'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Wrap(
        direction: Axis.horizontal,
        spacing: 10,
        children: [
          FloatingActionButton(
            heroTag: 'sortButton',
            onPressed: _showSortOptions,
            child: const Icon(Icons.sort),
          ),
          FloatingActionButton(
            heroTag: 'addButton',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMovieScreen(
                    catalog: widget.catalog,
                    settingsBox: Hive.box('settings'),
                  ),
                ),
              );

              if (result == true) {
                setState(() {});
              }
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  ValueListenableBuilder<List<Movie>> _buildMovieList() {
    return ValueListenableBuilder(
      valueListenable: widget.catalog.listenable(),
      builder: (context, List<Movie> movies, _) {
        if (movies.isEmpty) {
          return const Center(
              child: Text(
                  'This collection is empty! Try adding something using the + button.'));
        }
        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return ListTile(
              title: Text(movie.name),
              subtitle: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (movie.is3D) const Icon(Icons.threed_rotation),
                  ...getDigitalPlatformIcons(movie.formats),
                  if (movie.tags != null && movie.tags!.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.label, color: Colors.blue),
                    ),
                ],
              ),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditMovieScreen(
                      catalog: widget.catalog,
                      movie: movie,
                      movieIndex: index,
                      settingsBox: Hive.box('settings'),
                    ),
                  ),
                );
                if (result == true) {
                  setState(() {});
                }
              },
            );
          },
        );
      },
    );
  }

  void _showSortOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sort Movies'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSortOption('Name - Ascending'),
              _buildSortOption('Name - Descending'),
              _buildSortOption('Format - Ascending'),
              _buildSortOption('Format - Descending'),
              _buildSortOption('Is 3D - Ascending'),
              _buildSortOption('Is 3D - Descending'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String sortOption) {
    return ListTile(
      title: Text(sortOption),
      trailing: _sortBy == sortOption ? const Icon(Icons.check) : null,
      onTap: () {
        setState(() {
          _sortBy = sortOption;
        });
        Navigator.of(context).pop();
      },
    );
  }

  List<Widget> getDigitalPlatformIcons(List<MovieFormat> formats) {
    List<Widget> icons = [];
    formats.sort((a, b) => a.index.compareTo(b.index));
    for (MovieFormat format in formats) {
      icons.add(getDigitalPlatformIcon(format));
    }
    return icons;
  }

  Widget getDigitalPlatformIcon(MovieFormat platform) {
    switch (platform) {
      case MovieFormat.VHS:
        return const Icon(Icons.web_asset, color: Colors.black26);
      case MovieFormat.BETAMAX:
        return const Icon(Icons.format_bold, color: Colors.blueGrey);
      case MovieFormat.DVD:
        return const Icon(Icons.album, color: Colors.grey);
      case MovieFormat.HD_DVD:
        return const Icon(Icons.album, color: Colors.red);
      case MovieFormat.BLU_RAY:
        return const Icon(Icons.album, color: Colors.blue);
      case MovieFormat.BLU_RAY_4K:
        return const Icon(Icons.album, color: Colors.blueGrey);
      case MovieFormat.GOOGLE_PLAY:
        return const Icon(Icons.android, color: Colors.green);
      case MovieFormat.AMAZON:
        return const Icon(Icons.shopping_bag, color: Colors.orange);
      case MovieFormat.APPLE_TV:
        return const Icon(Icons.apple, color: Colors.black);
      case MovieFormat.FANDANGO:
        return const Icon(Icons.confirmation_num, color: Colors.orange);
      case MovieFormat.MICROSOFT:
        return const Icon(Icons.window, color: Colors.blue);
      case MovieFormat.OTHER:
        return const Icon(Icons.device_unknown, color: Colors.grey);
      default:
        return const SizedBox.shrink();
    }
  }
}
