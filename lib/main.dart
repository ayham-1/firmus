import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:firmus/views/apps.dart';
import 'package:firmus/views/item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await [
    Permission.contacts,
  ].request();

  await Hive.initFlutter();
  Hive.registerAdapter(ItemViewTypeAdapter());
  Hive.registerAdapter(ItemAdapter());
  await Hive.openBox("history");

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
        routes: {
          '/': (context) => const AppsPage(),
          '/settings': (context) => const HomePage(),
        });
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
