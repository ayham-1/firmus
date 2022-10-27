import 'package:flutter/material.dart';

import 'package:device_apps/device_apps.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

import 'views/item.dart';
import 'database.dart';

enum ViewMode {
  showingNone,
  showingHistory,
  showingAllApps,
}

enum ItemDisplayMode { grid, list }

final viewMode = StateProvider<ViewMode>((ref) => ViewMode.showingNone);

final modeProvider =
    StateProvider<ItemDisplayMode>((ref) => ItemDisplayMode.grid);

final searchTerms = StateProvider<String>((ref) => "");

final databaseProvider = FutureProvider<FirmDB>((ref) => FirmDB.load());
final historyAppProvider = FutureProvider<List<String>>((ref) => ref
    .watch(databaseProvider)
    .when(
        loading: () => List.empty(),
        error: (e, s) => List.empty(),
        data: (db) => db.getHistory()));

final appsProvider = FutureProvider<List<Application>>((ref) =>
    DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: true,
        onlyAppsWithLaunchIntent: true));

final filteredApps = FutureProvider<List<Application>>((ref) {
  final apps = ref.watch(appsProvider).value;
  final tag = ref.watch(searchTerms);

  if (tag != "") {
    return extractAllSorted(
      query: tag,
      choices: apps!,
      getter: (x) => x.appName,
      cutoff: 60,
    ).map((e) => e.choice).toList();
  } else {
    return apps!;
  }
});

final contactsProvider = FutureProvider<List<Contact>>(
    (ref) => FlutterContacts.getContacts(withPhoto: true));

final filteredContacts = FutureProvider<List<Contact>>((ref) {
  final contacts = ref.watch(contactsProvider).value;
  final tag = ref.watch(searchTerms);

  if (tag != "") {
    return extractAllSorted(
      query: tag,
      choices: contacts!,
      getter: (x) => x.displayName,
      cutoff: 60,
    ).map((e) => e.choice).toList();
  } else {
    return List.empty();
  }
});

final itemListProvider = FutureProvider<List<ItemView>>((ref) async {
  final view = ref.watch(viewMode);
  if (view == ViewMode.showingNone) {
    return List<ItemView>.empty();
  } else if (view == ViewMode.showingHistory) {
    List<ItemView> result = List<ItemView>.empty(growable: true);
    ref.watch(historyAppProvider).when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Container(),
        data: (pkg) {
          var pkgIterator = pkg.iterator;
          while (pkgIterator.moveNext()) {
            var app =
                DeviceApps.getApp(pkgIterator.current) as ApplicationWithIcon;
            result.add(ItemView(
                label: app.appName,
                packageName: app.packageName,
                type: ItemViewType.app,
                contact: Contact(),
                icon: Image.memory(
                  app.icon,
                  width: 60,
                )));
          }
        });
    return result;
  } else if (view == ViewMode.showingAllApps) {
    List<ItemView> result = List<ItemView>.empty(growable: true);

    ref.watch(filteredContacts).when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Container(),
        data: (contacts) {
          var contactIterator = contacts.iterator;
          while (contactIterator.moveNext()) {
            var contact = contactIterator.current;
            result.add(ItemView(
                label: contact.displayName,
                packageName: "",
                type: ItemViewType.contact,
                contact: contact,
                icon: contact.photo != null
                    ? Image.memory(
                        contact.photo!,
                        width: 60,
                      )
                    : const Image(
                        image: AssetImage('images/avatar.png'),
                        width: 45,
                        fit: BoxFit.cover,
                      )));
          }
        });

    ref.watch(filteredApps).when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Container(),
        data: (apps) {
          var appIterator = apps.iterator;
          while (appIterator.moveNext()) {
            var app = appIterator.current as ApplicationWithIcon;
            result.add(ItemView(
                label: app.appName,
                packageName: app.packageName,
                type: ItemViewType.app,
                contact: Contact(),
                icon: Image.memory(
                  app.icon,
                  width: 60,
                )));
          }
        });

    return result;
  } else {
    return List<ItemView>.empty();
  }
});
