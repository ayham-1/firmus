import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hive/hive.dart';

import 'package:device_apps/device_apps.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import 'package:firmus/state.dart';

part 'item.g.dart';

@HiveType(typeId: 2)
enum ItemViewType {
  @HiveField(0)
  app,
  @HiveField(1)
  contact,
}

@HiveType(typeId: 1)
class Item extends HiveObject {
  @HiveField(0)
  String packageName = "";

  @HiveField(1)
  ItemViewType type = ItemViewType.app;

  @HiveField(2)
  String label = "";

  @HiveField(3)
  String contactID = "";

  @HiveField(4)
  int openCount = 0;

  Item({
    required this.label,
    required this.type,
    required this.packageName,
    required this.contactID,
    required this.openCount,
  });
}

class ItemView extends StatelessWidget {
  final ItemViewType type;
  final String label;
  final String packageName;
  final Contact contact;
  final Image icon;
  final int openCount;

  const ItemView({
    required this.label,
    required this.type,
    required this.icon,
    required this.packageName,
    required this.contact,
    required this.openCount,
    super.key,
  });
  Item _toHiveItem() {
    return Item(
      type: type,
      label: label,
      packageName: packageName,
      contactID: contact.id,
      openCount: openCount + 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      if (ref.watch(itemDisplayProvider) == ItemDisplayMode.grid) {
        return InkWell(
          onTap: () => _onTap(ref),
          onLongPress: () => _onLongPress(context, ref),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                child: icon,
              ),
              Label(label: label),
            ],
          ),
        );
      } else if (ref.watch(itemDisplayProvider) == ItemDisplayMode.list) {
        return ListTile(
          leading: icon,
          title: Label(label: label),
          onTap: () => _onTap(ref),
          onLongPress: () => _onLongPress(context, ref),
        );
      } else {
        return Container();
      }
    });
  }

  void _onTap(WidgetRef ref) {
    if (type == ItemViewType.app) {
      DeviceApps.openApp(packageName);
      if (!(prefs.getBool("disableHistory") ?? false)) {
        if (!Hive.isBoxOpen("history")) {
          Hive.openBox("history")
              .then((_) => Hive.box("history").put(packageName, _toHiveItem()));
        }
      }
    } else if (type == ItemViewType.contact) {
      FlutterContacts.openExternalView(contact.id);
    }
  }

  void _onLongPress(BuildContext context, WidgetRef ref) {
    if (type == ItemViewType.app) {
      DeviceApps.openAppSettings(packageName);
    } else if (type == ItemViewType.contact) {
      FlutterContacts.openExternalView(contact.id);
    }
  }
}

class Label extends StatelessWidget {
  final String label;
  const Label({required this.label, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      String sourceText = label;
      String targetText = ref.watch(searchTerms);
      List<String> snippets = List.empty(growable: true);

      bool isHighlighting = false;
      String normalText = "", highlightText = "";
      for (int i = 0; i < sourceText.length; i++) {
        var sourceChar = sourceText[i];
        if (targetText.toLowerCase().contains(sourceChar.toLowerCase())) {
          if (!isHighlighting) {
            isHighlighting = true;
            if (normalText != "") {
              snippets.add(normalText);
              normalText = "";
            }
          }
          highlightText += sourceChar;
        } else {
          if (isHighlighting) {
            isHighlighting = false;
            if (highlightText != "") {
              snippets.add(highlightText);
              highlightText = "";
            }
          }
          normalText += sourceChar;
        }
      }
      if (!isHighlighting) {
        if (normalText != "") {
          snippets.add(normalText);
          normalText = "";
        }
        if (highlightText != "") {
          snippets.add(highlightText);
          highlightText = "";
          isHighlighting = !isHighlighting;
        }
      } else {
        if (highlightText != "") {
          snippets.add(highlightText);
          highlightText = "";
        }
        if (normalText != "") {
          snippets.add(normalText);
          normalText = "";
          isHighlighting = !isHighlighting;
        }
      }

      var normalStyleBg = TextStyle(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.black,
      );
      var normalStyleFg = const TextStyle(
        color: Colors.white,
      );
      var highlightStyleFg = const TextStyle(
        color: Colors.green,
      );

      List<TextSpan> spansFg = List.empty(growable: true);
      List<TextSpan> spansBg = List.empty(growable: true);
      isHighlighting =
          (snippets.length % 2) == 0 ? !isHighlighting : isHighlighting;
      for (var snippet in snippets) {
        if (isHighlighting) {
          spansBg.add(TextSpan(text: snippet, style: normalStyleBg));
          spansFg.add(TextSpan(text: snippet, style: highlightStyleFg));
        } else {
          spansBg.add(TextSpan(text: snippet, style: normalStyleBg));
          spansFg.add(TextSpan(text: snippet, style: normalStyleFg));
        }
        isHighlighting = !isHighlighting;
      }

      return Stack(
        children: [
          Text.rich(
            TextSpan(children: spansBg),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
          Text.rich(
            TextSpan(children: spansFg),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ],
      );
    });
  }
}
