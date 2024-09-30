import 'package:butter/models/catalog.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'constants.dart';
import 'models/movie.dart';
import 'models/movie_format.dart';
import 'models/three_d_type.dart';
import 'token_utils.dart';

class EditMovieScreen extends StatefulWidget {
  final Catalog catalog;
  final Box settingsBox;
  final Movie movie;
  final int movieIndex;

  const EditMovieScreen(
      {super.key,
      required this.catalog,
      required this.movie,
      required this.movieIndex,
      required this.settingsBox});

  @override
  EditMovieScreenState createState() => EditMovieScreenState();
}

class EditMovieScreenState extends State<EditMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late List<MovieFormat> _formats = [];
  late bool _is3D;
  late List<ThreeDType> _devicesRequiredFor3D;
  List<String> _selectedTags = [];
  List<String> _availableTags = [];
  String? _notes;

  @override
  void initState() {
    super.initState();
    _name = widget.movie.name;
    _formats = widget.movie.formats;
    _is3D = widget.movie.is3D;
    _devicesRequiredFor3D = widget.movie.devicesRequiredFor3D;
    _availableTags =
        List<String>.from(widget.settingsBox.get('tags', defaultValue: []));
    _selectedTags = widget.movie.tags!;
    _notes = widget.movie.notes;
  }

  @override
  Widget build(BuildContext context) {
    const List<String> predefinedTags = Constants.predefinedTags;
    final List<String> userTags =
        _availableTags.where((tag) => !predefinedTags.contains(tag)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Movie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Movie Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a movie name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              Wrap(
                spacing: 8.0,
                children: [
                  _formatChip(MovieFormat.VHS),
                  _formatChip(MovieFormat.BETAMAX),
                  _formatChip(MovieFormat.DVD),
                  _formatChip(MovieFormat.HD_DVD),
                  _formatChip(MovieFormat.BLU_RAY),
                  _formatChip(MovieFormat.BLU_RAY_4K),
                  _formatChip(MovieFormat.GOOGLE_PLAY),
                  _formatChip(MovieFormat.AMAZON),
                  _formatChip(MovieFormat.APPLE_TV),
                  _formatChip(MovieFormat.FANDANGO),
                  _formatChip(MovieFormat.MICROSOFT),
                  _formatChip(MovieFormat.DIGITAL),
                  _formatChip(MovieFormat.OTHER),
                ],
              ),
              CheckboxListTile(
                title: const Text('Is 3D'),
                value: _is3D,
                onChanged: (value) {
                  setState(() {
                    _is3D = value!;
                  });
                },
              ),
              if (_is3D)
                Wrap(
                  spacing: 8.0,
                  children: [
                    threeDGlassesChip(ThreeDType.ANAGLYPHIC),
                    threeDGlassesChip(ThreeDType.POLARIZED),
                    threeDGlassesChip(ThreeDType.ACTIVE_SHUTTER),
                  ],
                ),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(labelText: 'Notes'),
                onSaved: (value) => _notes = value,
              ),
              Wrap(children: [
                ...predefinedTags.map((tag) {
                  return FilterChip(
                    label: Text(tag),
                    selected: _selectedTags.contains(tag),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }),
                ...userTags.map((tag) {
                  return FilterChip(
                    label: Text(tag),
                    selected: _selectedTags.contains(tag),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }),
              ]),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final updatedMovie = widget.movie
                      ..name = _name
                      ..formats = _formats
                      ..is3D = _is3D
                      ..devicesRequiredFor3D = _devicesRequiredFor3D
                      ..tags = _selectedTags
                      ..notes = _notes;
                    widget.catalog.movies[widget.movieIndex] = updatedMovie;

                    bool isOffline = widget.settingsBox.get('offline');
                    if (isOffline) {
                      Navigator.pop(context, true);
                      return;
                    }

                    String hostUrl = widget.settingsBox.get('hostUrl');
                    if (hostUrl.isEmpty) {
                      Navigator.pop(context, true);
                      return;
                    }

                    String token = widget.settingsBox.get('authToken') ?? '';
                    String refreshToken = widget.settingsBox.get('refreshToken') ?? '';
                    if (token.isEmpty) {
                      const errorMessage = 'No token!!';
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(errorMessage)),
                      );
                    }

                    final String movieId = updatedMovie.id;
                    final Uri movieUri = Uri.http(hostUrl.replaceAll(RegExp(r'^https?://'), ''), 'movies/$movieId');

                    final moviePostResponse = await TokenUtils.makeAuthenticatedRequest(
                      requestUri: movieUri,
                      token: token,
                      refreshToken: refreshToken,
                      hostUrl: hostUrl,
                      headers: {
                        'Authorization': 'Bearer $token',
                        'Content-Type': 'application/json',
                      },
                      body: {
                        'name': _name,
                        'formats':
                            _formats.map((format) => format.toJson()).toList(),
                        'is3D': _is3D,
                        'devicesRequiredFor3D': _devicesRequiredFor3D
                            .map((format) => format.toJson())
                            .toList(),
                        'tags': _selectedTags,
                        'notes': _notes,
                      },
                      saveNewToken: (newToken){
                        widget.settingsBox.put('authToken', newToken);
                      },
                      requestType: RequestType.PUT,
                    );

                    if (moviePostResponse== null || moviePostResponse.statusCode != 200) {
                      final reason = moviePostResponse?.reasonPhrase;
                      final errorMessage = 'Failed to edit movie. Reason: $reason';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMessage)),
                      );
                      return;
                    }

                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formatChip(MovieFormat format) {
    return FilterChip(
      label: Text(format.toString().split('.').last.replaceAll('_', ' ')),
      selected: _formats.contains(format),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _formats.add(format);
          } else {
            _formats.remove(format);
          }
        });
      },
    );
  }

  Widget threeDGlassesChip(ThreeDType threedtype) {
    return FilterChip(
      label: Text(threedtype.toString().split('.').last.replaceAll('_', ' ')),
      selected: _devicesRequiredFor3D.contains(threedtype),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _devicesRequiredFor3D.add(threedtype);
          } else {
            _devicesRequiredFor3D.remove(threedtype);
          }
        });
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
              'Are you sure you want to remove this item from your library?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      Movie? m = widget.catalog.movies.firstWhere((t) => widget.movie.id == t.id);
      widget.catalog.movies.remove(m);
      
      bool isOffline = widget.settingsBox.get('offline');
      if (isOffline) {
        Navigator.pop(context, true);
        return;
      }

      String hostUrl = widget.settingsBox.get('hostUrl');
      if (hostUrl.isEmpty) {
        Navigator.pop(context, true);
        return;
      }

      String token = widget.settingsBox.get('authToken') ?? '';
      String refreshToken = widget.settingsBox.get('refreshToken') ?? '';
      if (token.isEmpty) {
        const errorMessage = 'No token!!';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(errorMessage)),
        );
      }
      
      final String movieId = widget.movie.id;
      final Uri movieUri = Uri.http(hostUrl.replaceAll(RegExp(r'^https?://'), ''), 'movies/$movieId');

      final movieDeleteResponse = await TokenUtils.makeAuthenticatedRequest(
        requestUri: movieUri,
        token: token,
        refreshToken: refreshToken,
        hostUrl: hostUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: {},
        saveNewToken: (newToken){
          widget.settingsBox.put('authToken', newToken);
        },
        requestType: RequestType.DELETE,
      );

      if (movieDeleteResponse == null || movieDeleteResponse.statusCode != 204) {
        final reason = movieDeleteResponse?.reasonPhrase;
        final errorMessage = 'Failed to delete movie. Reason: $reason';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    }
  }
}
