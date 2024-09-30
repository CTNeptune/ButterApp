import 'package:butter/catalog_list_screen.dart';
import 'package:butter/models/catalog.dart';
import 'package:butter/models/movie_format_adapter.dart';
import 'package:butter/models/threed_type_adapter.dart';
import 'package:butter/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'about_screen.dart';
import 'models/movie.dart';
import 'settings_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(CatalogAdapter());
  Hive.registerAdapter(MovieFormatAdapter());
  Hive.registerAdapter(ThreeDTypeAdapter());
  Hive.registerAdapter(MovieAdapter());

  var catalogBox = await Hive.openBox<Catalog>('catalogs');
  var settingsBox = await Hive.openBox('settings');
  
  runApp(MyApp(catalogBox: catalogBox, settingsBox: settingsBox));
}

class MyApp extends StatefulWidget {
  final Box<Catalog> catalogBox;
  final Box settingsBox;

  const MyApp({super.key, required this.catalogBox, required this.settingsBox});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late ValueNotifier<ThemeData> _themeNotifier;

  @override
  void initState() {
    super.initState();
    _themeNotifier = ValueNotifier(AppTheme.getThemeData(_getTheme()));
  }

  String _getTheme() {
    return widget.settingsBox.get('theme', defaultValue: 'Tinseltown');
  }

  void _updateTheme(String theme) {
    widget.settingsBox.put('theme', theme);
    _themeNotifier.value = AppTheme.getThemeData(theme);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: _themeNotifier,
      builder: (context, theme, child) {
        return MaterialApp(
          title: 'Butter',
          theme: theme,
          home: SignInScreen(
            catalogBox: widget.catalogBox,
            settingsBox: widget.settingsBox,
          ),
          routes: {
            '/catalogs' : (context) => CatalogListScreen(
              catalogBox: widget.catalogBox,
              settingsBox: widget.settingsBox,
              ),
            '/settings': (context) => SettingsScreen(
                  onThemeChanged: _updateTheme,
                ),
            '/about': (context) => const AboutScreen(),
          },
        );
      },
    );
  }
}
