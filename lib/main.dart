import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uk_power/app/app.dart';
import 'package:menubar/menubar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setApplicationMenu(
      [
        NativeSubmenu(
          label: "UK - Power",
          children: [],
        )
      ],
    );
  }

  runApp(const App());
}
