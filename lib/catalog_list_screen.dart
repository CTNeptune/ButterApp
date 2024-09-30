import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/catalog.dart';
import 'movie_list_screen.dart';
import 'add_catalog_screen.dart';

class CatalogListScreen extends StatefulWidget {
  final Box<Catalog> catalogBox;
  final Box settingsBox;

  const CatalogListScreen({super.key, required this.catalogBox, required this.settingsBox});

  @override
  CatalogListScreenState createState() => CatalogListScreenState();
}

class CatalogListScreenState extends State<CatalogListScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Your catalogs')),
      drawer: Drawer(
        child: Container(
          color: theme.drawerTheme.backgroundColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: theme.appBarTheme.backgroundColor ?? Colors.blue,
                ),
                child: Text(
                  'Butter: Your Media Collection',
                  style: theme.textTheme.titleLarge ??
                      const TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                leading: Icon(Icons.settings, color: theme.iconTheme.color),
                title: Text('Settings', style: theme.textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              ListTile(
                leading: Icon(Icons.help, color: theme.iconTheme.color),
                title: Text('About', style: theme.textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/about');
                },
              ),
            ],
          ),
        ),
      ),
      body: ValueListenableBuilder<Box<Catalog>>(
        valueListenable: widget.catalogBox.listenable(),
        builder: (context, box, _) {
          if (box.values.isEmpty) {
            return const Center(
              child: Text(
                  'You have no catalogs! Try adding a catalog using the + button.'),
            );
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final catalog = box.getAt(index);
              return ListTile(
                title: Text(catalog!.name),
                subtitle: catalog.notes != null ? Text(catalog.notes!) : null,
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieListScreen(
                          catalog: catalog,
                          catalogIndex: index,
                          catalogBox: widget.catalogBox,
                          settingsBox: Hive.box('settings')),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addCatalogButton',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCatalogScreen(box: widget.catalogBox, settingsBox: widget.settingsBox,),
            ),
          );

          if (result == true) {
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
