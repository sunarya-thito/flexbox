import 'dart:ui';

import 'package:demo/case.dart';
import 'package:demo/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'package:syntax_highlight/syntax_highlight.dart';
import 'package:url_launcher/url_launcher.dart';

class DemoApp extends StatefulWidget {
  final List<TestCase> testCases;
  const DemoApp({super.key, required this.testCases});

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 300,
          child: ListView.builder(
            itemCount: widget.testCases.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(widget.testCases[index].name),
                selected: index == selectedIndex,
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              );
            },
          ),
        ),
        VerticalDivider(),
        Expanded(
          child: ScrollConfiguration(
            behavior: MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: Scaffold(
              appBar: AppBar(
                title: Text(widget.testCases[selectedIndex].name),
                actions: [
                  IconButton(
                    icon: Icon(Icons.code),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ShowCodeDialog(
                            url: widget.testCases[selectedIndex].rawGitPath,
                            openUrl: widget.testCases[selectedIndex].gitPath,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              body: ClipRect(
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    Center(
                      child: widget.testCases[selectedIndex].build(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ShowCodeDialog extends StatefulWidget {
  final String url;
  final String openUrl;

  const ShowCodeDialog({super.key, required this.url, required this.openUrl});

  @override
  State<ShowCodeDialog> createState() => _ShowCodeDialogState();
}

class _ShowCodeDialogState extends State<ShowCodeDialog> {
  Future<String> fetchUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load code from $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Source Code'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: FutureBuilder<String>(
          future: fetchUrl(widget.url),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return DefaultTextStyle(
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                ),
                child: SingleChildScrollView(
                  child: SelectableText.rich(
                    Highlighter(
                      language: 'dart',
                      theme: darkHighlighterTheme,
                    ).highlight(snapshot.data ?? ''),
                  ),
                ),
              );
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            launchUrl(Uri.parse(widget.openUrl));
          },
          child: Text('Open in GitHub'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}
