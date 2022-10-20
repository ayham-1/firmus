import 'package:flutter/material.dart';

import 'package:device_apps/device_apps.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

import 'views/item.dart';

enum ViewMode {
  showingNone,
  showingHistory,
  showingAllApps,
}

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
    (ref) => ContactsService.getContacts(withThumbnails: true));

final filteredContacts = FutureProvider<List<Contact>>((ref) {
  final tag = ref.watch(searchTerms);
  return ContactsService.getContacts(query: tag);
});

final itemListProvider = FutureProvider<List<ItemView>>((ref) async {
  List<ItemView> result = List<ItemView>.empty(growable: true);

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
              icon: Image.memory(
                app.icon,
                width: 60,
              )));
        }
      });

  ref.watch(filteredContacts).when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Container(),
      data: (contacts) {
        var contactIterator = contacts.iterator;
        while (contactIterator.moveNext()) {
          var contact = contactIterator.current;
          result.add(ItemView(
            label: contact.displayName!,
            packageName: "",
            type: ItemViewType.contact,
            icon: const Image(
              image: AssetImage('images/avatar.png'),
              width: 45,
              fit: BoxFit.cover,
            ),
          ));
        }
      });

  return result;
});
