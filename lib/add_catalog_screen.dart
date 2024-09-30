import 'package:butter/token_utils.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'models/catalog.dart';
import 'package:uuid/uuid.dart';

class AddCatalogScreen extends StatefulWidget {
  final Box<Catalog> box;
  final Box settingsBox;

  const AddCatalogScreen(
      {super.key, required this.box, required this.settingsBox});

  @override
  AddCatalogScreenState createState() => AddCatalogScreenState();
}

class AddCatalogScreenState extends State<AddCatalogScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String? _notes;
  final List<String> _selectedTags = [];
  List<String> _availableTags = [];

  @override
  void initState() {
    super.initState();
    _availableTags =
        List<String>.from(widget.settingsBox.get('tags', defaultValue: []));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Catalog')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Catalog Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a catalog name.';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Notes'),
                onSaved: (newValue) => _notes = newValue,
              ),
              Wrap(
                children: _availableTags.map((tag) {
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
                }).toList(),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    var uuid = const Uuid();
                    final newCatalog = Catalog(
                      id: uuid.v4(),
                      name: _name,
                      notes: _notes,
                      tags: _selectedTags,
                      movies: List.empty(growable: true),
                    );
                    widget.box.put(newCatalog.id, newCatalog);

                    bool isOffline = widget.settingsBox.get('offline');
                    if(isOffline){
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
                    if(token.isEmpty){
                      const errorMessage = 'No token!!';
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(errorMessage)),
                      );
                    }

                    final Uri catalogUri = Uri.http(hostUrl.replaceAll(RegExp(r'^https?://'), ''), 'catalogs');

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
                        'id': newCatalog.id,
                        'name': newCatalog.name,
                        'notes': newCatalog.notes,
                        'tags': newCatalog.tags,
                        'userId': widget.settingsBox.get('userId'),
                      },
                      saveNewToken: (newToken){
                        widget.settingsBox.put('authToken', newToken);
                      },
                      requestType: RequestType.POST,
                    );

                    if (catalogPostResponse == null || catalogPostResponse.statusCode != 201) {
                      final reason = catalogPostResponse?.reasonPhrase;
                      final errorMessage = 'Failed to add catalog. Reason: $reason';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMessage)),
                      );
                      return;
                    }

                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Add Catalog'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
