import 'package:butter/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/catalog.dart';
import 'models/movie.dart';
import 'token_utils.dart';

class SettingsScreen extends StatefulWidget {
  final ValueChanged<String> onThemeChanged;

  const SettingsScreen(
      {super.key, required this.onThemeChanged});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  String? _selectedTheme;
  List<String> _tags = [];
  Box? _settingsBox;

  @override
  void initState() {
    super.initState();
    _openSettingsBox();
  }

  Future<void> _openSettingsBox() async {
    _settingsBox = await Hive.openBox('settings');
    setState(() {
      _selectedTheme = _settingsBox!.get('theme', defaultValue: 'Tinseltown');
      _tags = List<String>.from(_settingsBox!.get('tags', defaultValue: []));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_settingsBox == null) {
      return const Center(child: CircularProgressIndicator());
    }
    bool isOffline = _settingsBox!.get('offline', defaultValue: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Select Theme'),
            trailing: DropdownButton<String>(
              value: _selectedTheme,
              items: ['Tinseltown', 'Blockbusted', 'Light', 'Dark', 'OLED Dark']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedTheme = newValue!;
                  _settingsBox!.put('theme', _selectedTheme);
                  widget.onThemeChanged(_selectedTheme!);
                });
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Manage Personal Tags'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _tags.map((tag) {
                return Row(
                  children: [
                    Expanded(child: Text(tag)),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmTagDelete(context, tag),
                    ),
                  ],
                );
              }).toList(),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final newTag = await _showAddTagDialog(context);
                if (newTag != null && newTag.isNotEmpty) {
                  setState(() {
                    _tags.add(newTag);
                    _settingsBox!.put('tags', _tags);
                  });
                }
              },
            ),
          ),
          const Divider(),
          if (isOffline) ...[
            ListTile(
              title: const Text('Delete All Data'),
              subtitle:
                  const Text('This will remove all app data permanently.'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: () => _deleteAllData(context),
              ),
            ),
          ],
          if(!isOffline)...[
            ListTile(
              title: const Text('Log out'),
              subtitle: const Text('This will log you out.'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: () => _logout(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<String?> _showAddTagDialog(BuildContext context) {
    TextEditingController tagController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Tag'),
          content: TextField(
            controller: tagController,
            decoration: const InputDecoration(hintText: 'Enter new tag'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                Navigator.of(context).pop(tagController.text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmTagDelete(BuildContext context, String inTag) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
              'Are you sure you want to remove this tag? This will also remove this tag from any items that has this tag.'),
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
      _tags.remove(inTag);
      _settingsBox!.put('tags', _tags);
      _removeTagFromMovies(inTag);

      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _removeTagFromMovies(String inTag) {
    final Box<Movie> movieBox =
        Hive.box<Movie>('movies');
    for (int i = 0; i < movieBox.length; i++) {
      final movie = movieBox.getAt(i);
      if (movie != null && movie.tags != null && movie.tags!.contains(inTag)) {
        movie.tags!.remove(inTag);
        movieBox.putAt(i, movie);
      }
    }
  }

  Future<void> _deleteAllData(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete All Data'),
          content: const Text(
              'Are you sure you want to delete all app data? This action is irreversible.'),
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
      await Hive.deleteBoxFromDisk('catalogs');
      await Hive.deleteBoxFromDisk('settings');

      Hive.close();
      
      final catalogBox = await Hive.openBox<Catalog>('catalogs');
      final settingsBox = await Hive.openBox('settings');

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => SignInScreen(
                catalogBox: catalogBox, settingsBox: settingsBox),
          ),
          (route) => false,
        );
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm logout'),
          content: const Text(
              'Are you sure you want to log out? This will delete your local data but won\'t affect your account data.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        String hostUrl = _settingsBox!.get('hostUrl');
        if (hostUrl.isEmpty) {
          if (context.mounted) {
            Navigator.pop(context, true);
            return;
          }
        }

        String token = _settingsBox!.get('authToken') ?? '';
        String refreshToken = _settingsBox!.get('refreshToken') ?? '';
        if (token.isEmpty) {
          const errorMessage = 'No token!!';
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(errorMessage)),
            );
          }
        }

        final Uri logoutUri =
            Uri.http(hostUrl.replaceAll(RegExp(r'^https?://'), ''), '/users/logout');

        final logoutResponse = await TokenUtils.makeAuthenticatedRequest(
          requestUri: logoutUri,
          token: token,
          refreshToken: refreshToken,
          hostUrl: hostUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: {
            'userId': _settingsBox!.get('userId'),
          },
          saveNewToken: (newToken) {
            _settingsBox!.put('authToken', newToken);
          },
          requestType: RequestType.POST,
        );

        if (logoutResponse == null || logoutResponse.statusCode != 200) {
          final reason = logoutResponse?.reasonPhrase;
          final errorMessage = 'Failed to log out. Reason: $reason';
          if(context.mounted){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
          }
          return;
        }

        await Hive.deleteBoxFromDisk('catalogs');
        await Hive.deleteBoxFromDisk('settings');

        Hive.close();

        final catalogBox = await Hive.openBox<Catalog>('catalogs');
        final settingsBox = await Hive.openBox('settings');

        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => SignInScreen(
                  catalogBox: catalogBox, settingsBox: settingsBox),
            ),
            (route) => false,
          );
        }
      } catch (e) {
        debugPrint('Error: $e');
      }
    }
  }
}
