import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:device_apps/device_apps.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import 'package:firmus/state.dart';

enum ItemViewType { app, contact }

class ItemView extends StatelessWidget {
  final ItemViewType type;
  final String label;
  final String packageName;
  final Contact contact;
  final Image icon;

  const ItemView({
    required this.label,
    required this.type,
    required this.icon,
    required this.packageName,
    required this.contact,
    super.key,
  });

  void onTap() {
    if (type == ItemViewType.app) {
      DeviceApps.openApp(packageName);
    } else if (type == ItemViewType.contact) {
      FlutterContacts.openExternalView(contact.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      if (ref.watch(modeProvider) == ItemDisplayMode.grid) {
        return InkWell(
          onTap: () => onTap(),
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
      } else if (ref.watch(modeProvider) == ItemDisplayMode.list) {
        return ListTile(
          leading: icon,
          title: Label(label: label),
          onTap: () => onTap(),
        );
      } else {
        return Container();
      }
    });
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
