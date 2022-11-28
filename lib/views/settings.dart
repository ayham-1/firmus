import "package:flutter/material.dart";
import "package:settings_ui/settings_ui.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:flutter_colorpicker/flutter_colorpicker.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:hive/hive.dart";

import "package:firmus/state.dart";

var pagesList = ["Empty", "History", "All Apps"];

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Color pickerColor = const Color(0xff443a49);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("firmus Settings")),
        body: Consumer(builder: (context, WidgetRef ref, _) {
          return SettingsList(sections: [
            SettingsSection(
              title: const Text("Behaviour"),
              tiles: <SettingsTile>[
                SettingsTile(
                  title: const Text("Startup Page"),
                  leading: const Icon(Icons.home),
                  trailing: DropdownButton<String>(
                    value: pagesList[prefs.getInt("startupPage") ?? 0],
                    onChanged: (String? toValue) => prefs
                        .setInt("startupPage", pagesList.indexOf(toValue!))
                        .then((value) => setState(() => {})),
                    items:
                        pagesList.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                SettingsTile.switchTile(
                  onToggle: (value) {
                    prefs
                        .setBool("disableHistory", value)
                        .then((value) => setState(() => {}));

                    if (!Hive.isBoxOpen("history")) {
                      Hive.openBox("history")
                          .then((_) => Hive.deleteBoxFromDisk("history"));
                    } else {
                      Hive.deleteBoxFromDisk("history");
                    }
                    ref.read(viewMode.notifier).state = ViewMode.showingNone;
                  },
                  initialValue: prefs.getBool("disableHistory") ?? false,
                  title: const Text("Disable History (clears it)"),
                  leading: const Icon(Icons.history),
                ),
                SettingsTile.switchTile(
                  onToggle: (value) => prefs
                      .setBool("preferAppsOverContacts", value)
                      .then((value) => setState(() => {})),
                  initialValue:
                      prefs.getBool("preferAppsOverContacts") ?? false,
                  title: const Text(
                      "Prefer Applications over contacts when searching"),
                  leading: const Icon(Icons.adb),
                ),
              ],
            ),
            SettingsSection(
              title: const Text("Appearance"),
              tiles: <SettingsTile>[
                SettingsTile.switchTile(
                  onToggle: (value) => prefs
                      .setBool("leftHandLayout", value)
                      .then((value) => setState(() => {})),
                  initialValue: prefs.getBool("leftHandLayout") ?? true,
                  leading: const Icon(Icons.language),
                  title: const Text("Left Hand User layout"),
                ),
                SettingsTile.switchTile(
                  onToggle: (value) {
                    prefs
                        .setBool("useGrid", value)
                        .then((value) => setState(() => {}));

                    ref.read(itemDisplayProvider.notifier).state =
                        (prefs.getBool("useGrid") ?? true)
                            ? ItemDisplayMode.grid
                            : ItemDisplayMode.list;
                  },
                  initialValue: prefs.getBool("useGrid") ?? true,
                  leading: const Icon(Icons.grid_3x3),
                  title: const Text("Use Grid Layout"),
                ),
                SettingsTile.switchTile(
                  onToggle: (value) {
                    prefs.setInt("bgColor", Colors.transparent.value);
                    prefs.setInt("barColor", Colors.grey.shade800.value);
                    prefs.setInt("borderColor", Colors.yellow.shade800.value);

                    prefs
                        .setBool("useCustomTheme", value)
                        .then((value) => setState(() => {}));
                  },
                  initialValue: prefs.getBool("useCustomTheme") ?? false,
                  leading: const Icon(Icons.format_paint),
                  title: const Text("Enable custom theme"),
                ),
              ],
            ),
            SettingsSection(
              title: const Text("Custom Theme"),
              tiles: <SettingsTile>[
                SettingsTile.switchTile(
                  onToggle: (value) => prefs
                      .setBool("useDeviceBg", value)
                      .then((value) => setState(() => {})),
                  initialValue: prefs.getBool("useDeviceBg") ?? true,
                  leading: const Icon(Icons.device_hub),
                  title: const Text("Use device background"),
                  enabled: (prefs.getBool("useCustomTheme") ?? false),
                ),
                SettingsTile(
                  title: const Text("Background Color"),
                  leading: const Icon(Icons.format_color_fill),
                  trailing:
                      _makeColorPicker("bgColor", prefs, Colors.transparent),
                  enabled: (prefs.getBool("useCustomTheme") ?? false) &&
                      !(prefs.getBool("useDeviceBg") ?? true),
                ),
                SettingsTile(
                  title: const Text("Border Color"),
                  leading: const Icon(Icons.format_color_fill),
                  trailing: _makeColorPicker(
                      "borderColor", prefs, Colors.yellow.shade800),
                  enabled: (prefs.getBool("useCustomTheme") ?? false),
                ),
                SettingsTile(
                  title: const Text("Search Bar Color"),
                  leading: const Icon(Icons.format_color_fill),
                  trailing:
                      _makeColorPicker("barColor", prefs, Colors.grey.shade800),
                  enabled: (prefs.getBool("useCustomTheme") ?? false),
                ),
              ],
            ),
            SettingsSection(
              title: const Text("About"),
              tiles: <SettingsTile>[
                SettingsTile(
                  title: const Text("Created by ayham"),
                  leading: const Icon(Icons.account_tree),
                  enabled: false,
                ),
                SettingsTile(
                  title: const Text("Website: ayham.xyz"),
                  leading: const Icon(Icons.leaderboard),
                  enabled: false,
                ),
                SettingsTile(
                  title: const Text("Enjoy!"),
                  leading: const Icon(Icons.label),
                  enabled: false,
                ),
              ],
            ),
          ]);
        }));
  }

  Widget _makeColorPicker(
      String prefColorName, SharedPreferences prefs, Color defaultColor) {
    return InkWell(
      child: CircleAvatar(
        backgroundColor:
            Color(prefs.getInt(prefColorName) ?? defaultColor.value),
      ),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text("Pick a color"),
                  content: SingleChildScrollView(
                    child: BlockPicker(
                      pickerColor: Color(
                          prefs.getInt(prefColorName) ?? defaultColor.value),
                      onColorChanged: (color) => pickerColor = color,
                    ),
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                      child: const Text("Pick"),
                      onPressed: () {
                        setState(() {
                          prefs.setInt(prefColorName, pickerColor.value);
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ));
      },
    );
  }
}
