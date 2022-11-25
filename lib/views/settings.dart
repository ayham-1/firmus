import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

var pagesList = ['Empty', 'History', 'All Apps'];

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String startupPage = pagesList.first;
  Color pickerColor = const Color(0xff443a49);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("firmus Settings")),
        body: FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, prefs) {
              if (prefs.hasData) {
                return SettingsList(sections: [
                  SettingsSection(
                    title: const Text("Behaviour"),
                    tiles: <SettingsTile>[
                      SettingsTile(
                        title: const Text("Startup Page"),
                        leading: const Icon(Icons.home),
                        trailing: DropdownButton<String>(
                          value: startupPage,
                          onChanged: (String? toValue) =>
                              setState(() => startupPage = toValue!),
                          items: pagesList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      SettingsTile.switchTile(
                        onToggle: (value) => prefs.data
                            ?.setBool('disableHistory', value)
                            .then((value) => setState(() => {})),
                        initialValue:
                            prefs.data?.getBool('disableHistory') ?? false,
                        title: const Text("Disable History"),
                        leading: const Icon(Icons.history),
                      ),
                      SettingsTile.switchTile(
                        onToggle: (value) => prefs.data
                            ?.setBool('useSmartOrder', value)
                            .then((value) => setState(() => {})),
                        title: const Text("Use Smart Contacts/Apps Order"),
                        leading: const Icon(Icons.smart_button),
                        initialValue: prefs.data?.getBool('useSmartOrder'),
                      ),
                      SettingsTile.switchTile(
                        onToggle: (value) => prefs.data
                            ?.setBool('preferAppsOverContacts', value)
                            .then((value) => setState(() => {})),
                        initialValue:
                            prefs.data?.getBool('preferAppsOverContacts'),
                        title: const Text(
                            "Prefer Applications over contacts when searching"),
                        leading: const Icon(Icons.adb),
                        enabled: false,
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: const Text('Appearance'),
                    tiles: <SettingsTile>[
                      SettingsTile.switchTile(
                        onToggle: (value) => prefs.data
                            ?.setBool('leftHandLayout', value)
                            .then((value) => setState(() => {})),
                        initialValue: prefs.data?.getBool('leftHandLayout'),
                        leading: const Icon(Icons.language),
                        title: const Text('Left Hand User layout'),
                      ),
                      SettingsTile.switchTile(
                        onToggle: (value) {
                          prefs.data?.setBool('useGrid', value);
                        },
                        initialValue: prefs.data?.getBool('useGrid'),
                        leading: const Icon(Icons.grid_3x3),
                        title: const Text('Use Grid Layout'),
                      ),
                      SettingsTile.switchTile(
                        onToggle: (value) => prefs.data
                            ?.setBool('useCustomtheme', value)
                            .then((value) => setState(() => {})),
                        initialValue: prefs.data?.getBool('useCustomTheme'),
                        leading: const Icon(Icons.format_paint),
                        title: const Text('Enable custom theme'),
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: const Text('Custom Theme'),
                    tiles: <SettingsTile>[
                      SettingsTile.switchTile(
                        onToggle: (value) => prefs.data
                            ?.setBool('useDeviceBg', value)
                            .then((value) => setState(() => {})),
                        initialValue: prefs.data?.getBool('useDeviceBg'),
                        leading: const Icon(Icons.device_hub),
                        title: const Text('Use device background'),
                        enabled: false,
                      ),
                      SettingsTile(
                        title: const Text('Background Color'),
                        leading: const Icon(Icons.format_color_fill),
                        trailing: _makeColorPicker("bgColor", prefs.data!),
                        enabled: false,
                      ),
                      SettingsTile(
                        title: const Text('Border Color'),
                        leading: const Icon(Icons.format_color_fill),
                        trailing: _makeColorPicker("borderColor", prefs.data!),
                        enabled: false,
                      ),
                      SettingsTile(
                        title: const Text('Search Bar Color'),
                        leading: const Icon(Icons.format_color_fill),
                        trailing: _makeColorPicker("barColor", prefs.data!),
                        enabled: false,
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: const Text('About'),
                    tiles: <SettingsTile>[
                      SettingsTile(
                        title: const Text('Created by ayham'),
                        leading: const Icon(Icons.account_tree),
                        enabled: false,
                      ),
                      SettingsTile(
                        title: const Text('Website: ayham.xyz'),
                        leading: const Icon(Icons.leaderboard),
                        enabled: false,
                      ),
                      SettingsTile(
                        title: const Text('Enjoy!'),
                        leading: const Icon(Icons.label),
                        enabled: false,
                      ),
                    ],
                  ),
                ]);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }

  Widget _makeColorPicker(String prefColorName, SharedPreferences prefs) {
    return InkWell(
      child: CircleAvatar(
        backgroundColor:
            Color(prefs.getInt(prefColorName) ?? Colors.blue.value),
      ),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Pick a color'),
                  content: SingleChildScrollView(
                    child: BlockPicker(
                      pickerColor: Color(
                          prefs.getInt(prefColorName) ?? Colors.blue.value),
                      onColorChanged: (color) => pickerColor = color,
                    ),
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                      child: const Text('Pick'),
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
