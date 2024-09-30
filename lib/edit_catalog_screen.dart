import 'package:butter/token_utils.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'models/catalog.dart';

class EditCatalogScreen extends StatefulWidget {
  final Box<Catalog> catalogBox;
  final Catalog catalog;
  final int catalogIndex;
  final Box settingsBox;

  const EditCatalogScreen({
    super.key,
    required this.catalog,
    required this.catalogIndex,
    required this.catalogBox,
    required this.settingsBox,
  });

  @override
  EditCatalogScreenState createState() => EditCatalogScreenState();
}

class EditCatalogScreenState extends State<EditCatalogScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String? _notes;
  late List<String> _selectedTags;
  late List<String> _availableTags;

  @override
  void initState() {
    super.initState();
    _name = widget.catalog.name;
    _notes = widget.catalog.notes;
    _availableTags =
        List<String>.from(widget.settingsBox.get('tags', defaultValue: []));
    _selectedTags = widget.catalog.tags!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Catalog'),
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
                decoration: const InputDecoration(labelText: 'Catalog Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a catalog name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(labelText: 'Notes'),
                onSaved: (value) => _notes = value,
              ),
              Wrap(children: [
                ..._availableTags.map((tag) {
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
                    final updatedCatalog = widget.catalog
                      ..id = widget.catalog.id
                      ..name = _name
                      ..notes = _notes
                      ..tags = _selectedTags
                      ..movies = widget.catalog.movies;

                    widget.catalogBox.put(widget.catalog.id, updatedCatalog);

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

                    final String catalogId = widget.catalog.id;

                    final Uri catalogUri = Uri.http(hostUrl.replaceAll(RegExp(r'^https?://'), ''), 'catalogs/$catalogId');

                    final catalogPostResponse = await TokenUtils.makeAuthenticatedRequest(
                      requestUri: catalogUri,
                      token: token,
                      refreshToken: refreshToken,
                      hostUrl: hostUrl,
                      headers: {
                        'Authorization': 'Bearer $token',
                        'Content-Type': 'application/json',
                      },
                      body: {
                        'name': updatedCatalog.name,
                        'notes': updatedCatalog.notes,
                        'tags': updatedCatalog.tags,
                      },
                      saveNewToken: (newToken){
                        widget.settingsBox.put('authToken', newToken);
                      },
                      requestType: RequestType.PUT,
                    );

                    if (catalogPostResponse == null || catalogPostResponse.statusCode != 200) {
                      final reason = catalogPostResponse?.reasonPhrase;
                      final errorMessage =
                          'Failed to update catalog. Reason: $reason';
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

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this catalog?'),
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
      
      setState(() {
        widget.catalogBox.delete(widget.catalog.id);
      });

      bool isOffline = widget.settingsBox.get('offline');
      if (isOffline) {
        if (context.mounted) {
          Navigator.pushNamed(context, '/catalogs');
        }
        return;
      }

      String hostUrl = widget.settingsBox.get('hostUrl');
      if (hostUrl.isEmpty) {
        if (context.mounted) {
          Navigator.pushNamed(context, '/catalogs');
        }
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
      
      final String catalogId = widget.catalog.id;
      final Uri deleteUri = Uri.http(hostUrl.replaceAll(RegExp(r'^https?://'), ''), 'catalogs/$catalogId');

      final deleteCatalogResponse = await TokenUtils.makeAuthenticatedRequest(
        requestUri: deleteUri,
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

      if (deleteCatalogResponse == null || deleteCatalogResponse.statusCode != 204) {
        final reason = deleteCatalogResponse?.reasonPhrase;
        final errorMessage = 'Failed to delete catalog. Reason: $reason';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        return;
      }

      if (context.mounted) {
        Navigator.pushNamed(context, '/catalogs');
      }
    }
  }
}
