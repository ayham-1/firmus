import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firmus/app_state.dart';

final modeProvider = StateProvider<DisplayMode>((ref) => DisplayMode.grid);

enum DisplayMode {
  grid,
  list,
}

class AppsPage extends StatefulWidget {
  const AppsPage({Key? key}) : super(key: key);

  @override
  AppsPageState createState() => AppsPageState();
}

class AppsPageState extends State<AppsPage> with AutomaticKeepAliveClientMixin {
  FocusNode keepFocus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    keepFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer(
      builder: (context, WidgetRef ref, _) {
        final appsInfo = ref.watch(appsProvider);
        final mode = ref.watch(modeProvider);
        return Scaffold(
            extendBodyBehindAppBar: false,
            appBar: null,
            body: Stack(children: [
              appsInfo.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Container(),
                data: (List<Application> apps) => mode.name ==
                        DisplayMode.list.name
                    ? ListView.builder(
                        itemCount: apps.length,
                        itemBuilder: (BuildContext context, int index) {
                          var app = apps[index] as ApplicationWithIcon;
                          return ListTile(
                            leading: Image.memory(
                              app.icon,
                              width: 40,
                            ),
                            title: AppLabel(label: app.appName),
                            onTap: () => DeviceApps.openApp(app.packageName),
                          );
                        },
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            16.0, kToolbarHeight + 16.0, 16.0, 16.0),
                        itemCount: apps.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return AppGridItem(
                              application: apps[index] as ApplicationWithIcon);
                        }),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(children: [
                    Expanded(
                        child: TextField(
                            autofocus: true,
                            focusNode: keepFocus,
                            onSubmitted: (val) {
                              keepFocus.requestFocus();
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
                    const Padding(
                        padding: EdgeInsets.all(15),
                        child: Image(
                            image: AssetImage('images/spear.png'),
                            width: 40,
                            fit: BoxFit.cover))
                  ])),
            ]));
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class AppLabel extends StatelessWidget {
  final String label;
  const AppLabel({required this.label, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: TextStyle(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = Colors.black,
          ),
        ),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class AppGridItem extends StatelessWidget {
  final ApplicationWithIcon application;
  const AppGridItem({required this.application, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        DeviceApps.openApp(application.packageName);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Image.memory(
              application.icon,
              fit: BoxFit.contain,
              width: 60,
            ),
          ),
          AppLabel(label: application.appName),
        ],
      ),
    );
  }
}
