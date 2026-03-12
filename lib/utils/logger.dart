import 'package:flutter/foundation.dart';

void logger(obj) {
  if (kDebugMode) {
    print('\x1B[33m$obj\x1B[0m');
  }
}
