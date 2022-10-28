import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firmus/state.dart';

import 'item.dart';
import 'search.bar.dart';

class AppsPage extends StatefulWidget {
  const AppsPage({Key? key}) : super(key: key);

  @override
  AppsPageState createState() => AppsPageState();
}

class AppsPageState extends State<AppsPage> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer(
      builder: (context, WidgetRef ref, _) {
        ref.watch(appsProvider);
        ref.watch(contactsProvider);
        final itemListProv = ref.watch(itemListProvider);
        final mode = ref.watch(modeProvider);
        return Scaffold(
            extendBodyBehindAppBar: false,
            appBar: null,
            body: Column(children: [
              Expanded(
                  child: itemListProv.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Container(),
                      data: (List<ItemView> itemViews) => GestureDetector(
                            onTap: () {
                              if (ref.read(viewMode.notifier).state !=
                                  ViewMode.showingNone) {
                                ref.read(viewMode.notifier).state =
                                    ViewMode.showingNone;
                              } else {
                                ref.read(viewMode.notifier).state =
                                    ViewMode.showingHistory;
                              }
                            },
                            child: mode.name == ItemDisplayMode.list.name
                                ? ListView.builder(
                                    reverse: true,
                                    itemCount: itemViews.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return itemViews[index];
                                    },
                                  )
                                : GridView.builder(
                                    reverse: true,
                                    padding: const EdgeInsets.fromLTRB(16.0,
                                        kToolbarHeight + 16.0, 16.0, 16.0),
                                    itemCount: itemViews.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8.0,
                                      mainAxisSpacing: 8.0,
                                    ),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return itemViews[index];
                                    }),
                          ))),
              const SearchBar()
            ]));
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
