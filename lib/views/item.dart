import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

enum ItemViewType { app, contact }

class ItemView extends StatelessWidget {
  final ItemViewType type;
  final String label;
  final String packageName;
  final Image icon;

  const ItemView({
    required this.label,
    required this.type,
    required this.icon,
    required this.packageName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        DeviceApps.openApp(packageName);
      },
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
  }
}

class Label extends StatelessWidget {
  final String label;
  const Label({required this.label, Key? key}) : super(key: key);
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
