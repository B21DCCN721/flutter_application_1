import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/args/UserArg.dart';
import 'package:flutter_application_1/presentation/screen/home_screen.dart';
import 'package:flutter_application_1/presentation/screen/login_screen.dart';
import 'package:flutter_application_1/presentation/screen/pokemon_screen.dart';
import 'package:flutter_application_1/presentation/screen/profille_screen.dart';

class AppRouter {
  static const String login = '/';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String pokemon = '/pokemon';

  static MaterialPageRoute generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        final args = settings.arguments as UserArg;
        return MaterialPageRoute(builder: (_) => HomeScreen(args: args));
      case profile:
        final args = settings.arguments as UserArg;
        return MaterialPageRoute(builder: (_) => ProfileScreen(args: args));
      case pokemon:
        return MaterialPageRoute(builder: (_) => const PokemonScreen());
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
