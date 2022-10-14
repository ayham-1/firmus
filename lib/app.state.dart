import 'package:device_apps/device_apps.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appsProvider = FutureProvider<List<Application>>((ref) =>
    DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: true,
        onlyAppsWithLaunchIntent: true));

final filteredApps = FutureProvider<List<Application>>((ref) {
  final apps = ref.watch(appsProvider).value;
  final tag = ref.watch(searchTerms);

  return apps!.where((map) => map.appName.contains(tag)).toList();
});

final searchTerms = StateProvider<String>((ref) => "");
