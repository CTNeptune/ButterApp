import 'package:butter/models/catalog.dart';
import 'package:butter/token_utils.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'models/movie.dart';
import 'models/movie_format.dart';
import 'models/three_d_type.dart';
import 'constants.dart';

class AddMovieScreen extends StatefulWidget {
  final Catalog catalog;
  final Box settingsBox;

  const AddMovieScreen(
      {super.key, required this.catalog, required this.settingsBox});

  @override
  AddMovieScreenState createState() => AddMovieScreenState();
}

class AddMovieScreenState extends State<AddMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  final List<MovieFormat> _formats = [];
  bool _is3D = false;
  final List<ThreeDType> _devicesRequiredFor3D = [];
  final List<String> _selectedTags = [];
  List<String> _availableTags = [];
  String? _notes;

  @override
  void initState() {
    super.initState();
    _availableTags =
        List<String>.from(widget.settingsBox.get('tags', defaultValue: []));
  }

  @override
  Widget build(BuildContext context) {
    const List<String> predefinedTags = Constants.predefinedTags;
    final List<String> userTags =
        _availableTags.where((tag) => !predefinedTags.contains(tag)).toList();

    return Scaffold(
        appBar: AppBar(title: const Text('Add Movie')),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Movie Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a movie name.';
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
                      decoration: const InputDecoration(labelText: 'Notes'),
                      onSaved: (newValue) => _notes = newValue,
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
                          var uuid = const Uuid();
                          final newMovie = Movie(
                              id: uuid.v4(),
                              name: _name,
                              formats: _formats,
                              is3D: _is3D,
                              devicesRequiredFor3D: _devicesRequiredFor3D)
                            ..tags = _selectedTags
                            ..notes = _notes;
                          widget.catalog.movies.add(newMovie);

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

                          final Uri movieUri = Uri.http(hostUrl.replaceAll(RegExp(r'^https?://'), ''), 'movies');

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
                              'id' : newMovie.id,
                              'name': newMovie.name,
                              'formats': newMovie.formats.map((format) => format.toJson()).toList(),
                              'is3D': newMovie.is3D,
                              'devicesRequiredFor3D': newMovie.devicesRequiredFor3D.map((format) => format.toJson()).toList(),
                              'tags': newMovie.tags,
                              'notes': newMovie.notes,
                              'userId': widget.settingsBox.get('userId'),
                              'catalogId': widget.catalog.id,
                            },
                            saveNewToken: (newToken){
                              widget.settingsBox.put('authToken', newToken);
                            },
                            requestType: RequestType.POST,
                          );

                          if (moviePostResponse == null || moviePostResponse.statusCode != 201) {
                            final reason = moviePostResponse?.reasonPhrase;
                            final errorMessage = 'Failed to add movie. Reason: $reason';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(errorMessage)),
                            );
                            return;
                          }

                          Navigator.pop(context, true);
                        }
                      },
                      child: const Text('Add Movie'),
                    )
                  ],
                ))));
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
}
