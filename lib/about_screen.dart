import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Butter is an app that allows you to catalog and search your media collection through a simple interface that\'s smooth... like butter!\n\nLicenses:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16.0),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Material Floating Search Bar\n\n',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _launchURL(
                              'https://github.com/AlwinFassbender/material_floating_search_bar'),
                      ),
                      TextSpan(
                        text: 'MIT License\n\n'
                            'Copyright (c) 2020 bxqm\n\n'
                            'Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\n'
                            'The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\n'
                            'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      TextSpan(
                        text: '\n\nIcons used in this app are from ',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      TextSpan(
                        text: 'Google Fonts',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _launchURL(
                              'https://fonts.google.com/icons'),
                      ),
                      TextSpan(
                        text: ' and are licensed under the Apache License 2.0.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (kDebugMode) {
        print('Could not launch $url');
      }
    }
  }
}
