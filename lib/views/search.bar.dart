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
      return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.black45,
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(children: [
                  Expanded(
                      flex: 2,
                      child: MaterialButton(
                          onPressed: () {
                            if (ref.read(viewMode.notifier).state ==
                                ViewMode.showingAllApps) {
                              ref.read(viewMode.notifier).state =
                                  ViewMode.showingNone;
                            } else {
                              ref.read(viewMode.notifier).state =
                                  ViewMode.showingAllApps;
                            }
                          },
                          color: const Color.fromRGBO(51, 49, 49, 1),
                          shape: const CircleBorder(),
                          child: const Image(
                              image: AssetImage('images/spear.png'),
                              width: 45,
                              fit: BoxFit.cover))),
                  Expanded(
                      flex: 8,
                      child: TextField(
                          autofocus: true,
                          focusNode: keepFocus,
                          onSubmitted: (val) {
                            keepFocus.requestFocus();
                            ref.read(searchTerms.notifier).state = val;
                            if (val != "") {
                              ref.read(viewMode.notifier).state =
                                  ViewMode.showingAllApps;
                            }
                          },
                          onChanged: (val) {
                            keepFocus.requestFocus();
                            ref.read(searchTerms.notifier).state = val;
                            if (val != "") {
                              ref.read(viewMode.notifier).state =
                                  ViewMode.showingAllApps;
                            }
                          },
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            isDense: true,
                            fillColor: const Color.fromRGBO(51, 49, 49, 1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: const BorderSide(),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: const BorderSide(),
                            ),
                          ))),
                ])),
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
