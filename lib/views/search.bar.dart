import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  SearchBarState createState() => SearchBarState();
}

class SearchBarState extends State<SearchBar> {
  FocusNode keepFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      searchCircleBtn() => Expanded(
            flex: 2,
            child: MaterialButton(
                onPressed: () {
                  if (ref.read(viewMode.notifier).state ==
                      ViewMode.showingAllApps) {
                    ref.read(viewMode.notifier).state = ViewMode.showingNone;
                  } else {
                    ref.read(viewMode.notifier).state = ViewMode.showingAllApps;
                  }
                },
                color: Color(
                    prefs.getInt("barColor") ?? Colors.grey.shade800.value),
                shape: const CircleBorder(),
                child: const Image(
                    image: AssetImage('images/spear.png'),
                    fit: BoxFit.contain)),
          );
      searchBar() => Expanded(
          flex: 8,
          child: TextField(
              autofocus: true,
              focusNode: keepFocus,
              onSubmitted: (val) {
                keepFocus.requestFocus();
                ref.read(searchTerms.notifier).state = val;
                if (val != "") {
                  ref.read(viewMode.notifier).state = ViewMode.showingAllApps;
                }
              },
              onChanged: (val) {
                keepFocus.requestFocus();
                ref.read(searchTerms.notifier).state = val;
                if (val != "") {
                  ref.read(viewMode.notifier).state = ViewMode.showingAllApps;
                }
              },
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                filled: true,
                isDense: true,
                fillColor: Color(
                    prefs.getInt("barColor") ?? Colors.grey.shade800.value),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide(
                      color: Color(prefs.getInt("borderColor") ??
                          Colors.yellow.shade800.value)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide(
                      color: Color(prefs.getInt("borderColor") ??
                          Colors.yellow.shade800.value)),
                ),
              )));

      return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.black45,
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                    children: (prefs.getBool("leftHandLayout") ?? true)
                        ? [searchCircleBtn(), searchBar()]
                        : [searchBar(), searchCircleBtn()])),
          ));
    });
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    keepFocus.dispose();

    super.dispose();
  }
}
