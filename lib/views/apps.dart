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

class AppsPageState extends State<AppsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
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
            body: appsInfo.when(
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
                            title: Text(app.appName),
                            onTap: () => DeviceApps.openApp(app.packageName),
                          );
                        },
                      )
                    : GridView(
                        padding: const EdgeInsets.fromLTRB(
                            16.0, kToolbarHeight + 16.0, 16.0, 16.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        children: [
                          ...apps.map((app) => AppGridItem(
                                application: app as ApplicationWithIcon,
                              ))
                        ],
                      ),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Container()));
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class AppGridItem extends StatelessWidget {
  final ApplicationWithIcon application;
  const AppGridItem({
    required this.application,
    super.key
  });

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
              width: 40,
            ),
          ),
          Text(
            application.appName,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
	    textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
