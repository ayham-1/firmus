import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app.state.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  SearchBarState createState() => SearchBarState();
}

class SearchBarState extends State<SearchBar> {
  FocusNode keepFocus = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      keepFocus.requestFocus();
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
                          onPressed: () {},
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
                          controller: _controller,
                          onSubmitted: (val) {
                            //keepFocus.requestFocus();
                            ref.read(searchTerms.notifier).state =
                                _controller.text;
                          },
                          onChanged: (val) {
                            ref.read(searchTerms.notifier).state =
                                _controller.text;
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
                              borderSide: const BorderSide(width: 0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: const BorderSide(width: 0),
                            ),
                          ))),
                ])),
          ));
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final String text = _controller.text;
      _controller.value = _controller.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    keepFocus.dispose();

    super.dispose();
  }
}
