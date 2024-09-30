import 'dart:convert';

import 'package:butter/models/catalog.dart';
import 'package:butter/models/movie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'catalog_list_screen.dart';

class SignInScreen extends StatefulWidget {
  final Box<Catalog> catalogBox;
  final Box settingsBox;

  const SignInScreen(
      {super.key, required this.catalogBox, required this.settingsBox});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  String baseUrl = 'http://10.0.2.2:3000';

  @override
  void initState() {
    super.initState();
    _hostController.text = baseUrl;
    WidgetsBinding.instance.addPostFrameCallback((_) {
    String? token = widget.settingsBox.get('authToken');
    bool isOffline = widget.settingsBox.get('offline', defaultValue: false);

    if (token != null && token.isNotEmpty || isOffline) {
      _skipLogin();
    }
  });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      baseUrl = _hostController.text;
      String endpoint = _isLogin ? '/login' : '/signup';
      String url = '$baseUrl/users$endpoint';

      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      if (response.statusCode != 200) {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? 'An error occurred';
        _showError(errorMessage);
        return;
      }

      final responseData = jsonDecode(response.body);
      String token = responseData['token'];
      widget.settingsBox.put('authToken', token);
      widget.settingsBox.put('userId', _emailController.text.trim());

      final String radixUrl = _hostController.text.replaceAll(RegExp(r'^https?://'), '');
      final String userId = _emailController.text.trim();
      final Uri catalogUri =
          Uri.http(radixUrl, 'catalogs/users', {'userId': userId});

      final catalogResponse = await http.get(
        catalogUri,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (catalogResponse.statusCode != 200) {
        final reason = catalogResponse.reasonPhrase;
        final errorMessage = 'Failed to fetch catalogs. Reason: $reason';
        _showError(errorMessage);
        return;
      }

      final List<dynamic> catalogsData = jsonDecode(catalogResponse.body);
      await widget.catalogBox.clear();
      for (var catalog in catalogsData) {
        widget.catalogBox.add(Catalog.fromJson(catalog));
      }

      final moviesResponse = await http.get(
        Uri.parse('$baseUrl/movies?userId=$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (moviesResponse.statusCode != 200) {
        final reason = moviesResponse.reasonPhrase;
        final errorMessage = 'Failed to fetch movies. Reason: $reason';
        _showError(errorMessage);
        return;
      }

      final List<dynamic> moviesData = jsonDecode(moviesResponse.body);
      if(widget.catalogBox.isNotEmpty){
        for (var movie in moviesData) {
          Movie m = Movie.fromJson(movie);
          Catalog? c =
              widget.catalogBox.values.firstWhere((t) => m.catalogId == t.id);
          c.movies.add(m);
        }
      }

      widget.settingsBox.put('hostUrl', _hostController.text.trim());
      widget.settingsBox.put('offline', false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => CatalogListScreen(
                catalogBox: widget.catalogBox,
                settingsBox: widget.settingsBox)),
      );
    } catch (e) {
      String message = e.toString();
      _showError('An error occurred: $message');
    }
  }

  void _showError(String message) {
    if(context.mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _skipLogin() {
    widget.settingsBox.put('offline', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => CatalogListScreen(
              catalogBox: widget.catalogBox, settingsBox: widget.settingsBox)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _hostController,
                decoration: const InputDecoration(labelText: 'Host'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an IP address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Please enter a password at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isLogin ? 'Login' : 'Sign Up'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(_isLogin
                    ? 'Create a new account'
                    : 'Already have an account? Login'),
              ),
              TextButton(
                onPressed: _skipLogin,
                child: const Text('Use App Offline'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
