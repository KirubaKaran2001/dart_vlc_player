import 'package:dart_vlc_player/screens/dart_vlc.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';

void main() {
  DartVLC.initialize(useFlutterNativeView: true);
  runApp(
    const MaterialApp(
    home: DartVLCExample(),
    debugShowCheckedModeBanner: false,
  ));
}
