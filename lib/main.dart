import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firmus/views/apps.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'firmus',
      theme: ThemeData(
        backgroundColor: Colors.transparent,
        scaffoldBackgroundColor: Colors.transparent,
        primarySwatch: Colors.brown,
      ),
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
            settings: settings,
            builder: (context) {
              switch (settings.name) {
                case 'settings':
                  return const HomePage();
                default:
                  return const AppsPage();
              }
            });
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: SizedBox(
          height: 70,
          child: Center(
            child: IconButton(
              icon: const Icon(Icons.apps),
              onPressed: () => Navigator.pushNamed(context, 'apps'),
            ),
          ),
        ),
      ),
    );
  }
}
