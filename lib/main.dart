import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:firmus/views/apps.dart';
import 'package:firmus/views/settings.dart';
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
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          backgroundColor: Colors.transparent,
          scaffoldBackgroundColor: Colors.transparent,
        ),
        routes: {
          '/': (context) => const AppsPage(),
          '/settings': (context) => const Settings(),
        });
  }
}
