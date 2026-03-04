import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/screen/home_screen.dart';
import 'package:flutter_application_1/presentation/screen/login_screen.dart';
import 'package:flutter_application_1/presentation/screen/profille_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';

  static MaterialPageRoute generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        final username = settings.arguments as String? ?? 'Guest';
        return MaterialPageRoute(
            builder: (_) => HomeScreen(username: username));
      case profile:
        final username = settings.arguments as String? ?? 'Guest';
        return MaterialPageRoute(
            builder: (_) => ProfileScreen(username: username));
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
