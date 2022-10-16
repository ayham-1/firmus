import 'package:flutter/material.dart';

import 'package:device_apps/device_apps.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firmus/state.dart';

import 'item.dart';
import 'search.bar.dart';

final modeProvider =
    StateProvider<ItemDisplayMode>((ref) => ItemDisplayMode.grid);

enum ItemDisplayMode {
  grid,
  list,
}

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
        final itemListProv = ref.watch(itemListProvider);
        final mode = ref.watch(modeProvider);
        return Scaffold(
            extendBodyBehindAppBar: false,
            appBar: null,
            body: Column(children: [
              Expanded(
                  child: itemListProv.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Container(),
                data: (List<ItemView> itemViews) =>
                    mode.name == ItemDisplayMode.list.name
                        ? ListView.builder(
                            itemCount: itemViews.length,
                            itemBuilder: (BuildContext context, int index) {
                              var item = itemViews[index];
                              return ListTile(
                                leading: item.icon,
                                title: Label(label: item.label),
                                //onTap: () => DeviceApps.openApp(app.packageName),
                              );
                            },
                          )
                        : GridView.builder(
                            reverse: true,
                            padding: const EdgeInsets.fromLTRB(
                                16.0, kToolbarHeight + 16.0, 16.0, 16.0),
                            itemCount: itemViews.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return itemViews[index];
                            }),
              )),
              const SearchBar()
            ]));
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
