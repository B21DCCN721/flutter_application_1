import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/local_storage.dart';

class AppConfig {
  static final ValueNotifier<double> fontSizeFactor = 
      ValueNotifier<double>(LocalStorage.getDouble('font_size', defaultValue: 1.0));

  static void updateFontSize(double factor) {
    fontSizeFactor.value = factor;
    LocalStorage.putDouble('font_size', factor);
  }
}
