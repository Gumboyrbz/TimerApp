import 'package:flutter/material.dart';
import 'TimerData.dart';

class AppState extends ChangeNotifier {
  // AppState(Data value) : super(value);
  Data value = Data();
  increment() {
    notifyListeners();
  }

  AppState(this.value);
}
