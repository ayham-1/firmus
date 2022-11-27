import "package:flutter/material.dart";

import "package:device_apps/device_apps.dart";
import "package:flutter_contacts/flutter_contacts.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:fuzzywuzzy/fuzzywuzzy.dart";
import "package:hive/hive.dart";
import "package:shared_preferences/shared_preferences.dart";

import "views/item.dart";

late SharedPreferences prefs;

enum ViewMode {
  showingNone,
  showingHistory,
  showingAllApps,
}

enum ItemDisplayMode { grid, list }

final viewMode = StateProvider<ViewMode>(
  (ref) => ViewMode.values[prefs.getInt("startupPage") ?? 0],
);

final itemDisplayProvider = StateProvider<ItemDisplayMode>((ref) =>
    (prefs.getBool("useGrid") ?? true)
        ? ItemDisplayMode.grid
        : ItemDisplayMode.list);

final searchTerms = StateProvider<String>((ref) => "");

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
    var result = List<ItemView>.empty(growable: true);
    var history = Hive.box("history").values.toList();
    history.sort((a, b) => b.openCount.compareTo(a.openCount));
    var historyIterator = history.iterator;

    while (historyIterator.moveNext()) {
      Item historyItem = historyIterator.current;

      if (!(await DeviceApps.isAppInstalled(historyItem.packageName))) {
        historyItem.delete();
        continue;
      }

      final app = (await DeviceApps.getApp(historyItem.packageName, true))
          as ApplicationWithIcon;

      result.add(ItemView(
        label: historyItem.label,
        packageName: historyItem.packageName,
        type: ItemViewType.app,
        contact: Contact(),
        openCount: historyItem.openCount,
        icon: Image.memory(app.icon, width: 60),
      ));
    }
    return result;
  } else if (view == ViewMode.showingAllApps) {
    List<ItemView> result = List<ItemView>.empty(growable: true);

    filterContacts() => ref.watch(filteredContacts).when(
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
                openCount: 0,
                contact: contact,
                icon: contact.photo != null
                    ? Image.memory(
                        contact.photo!,
                        width: 60,
                      )
                    : const Image(
                        image: AssetImage("images/avatar.png"),
                        width: 45,
                        fit: BoxFit.cover,
                      )));
          }
        });

    filterApps() => ref.watch(filteredApps).when(
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
                openCount: 0,
                contact: Contact(),
                icon: Image.memory(
                  app.icon,
                  width: 60,
                )));
          }
        });

    if ((prefs.getBool("preferAppsOverContacts") ?? false)) {
      filterApps();
      filterContacts();
    } else {
      filterContacts();
      filterApps();
    }

    return result;
  } else {
    return List<ItemView>.empty();
  }
});
