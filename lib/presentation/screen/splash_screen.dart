import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/presentation/router/index.dart';
import 'package:flutter_application_1/utils/local_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    String token = await LocalStorage.getString(Env.token);
    String username = await LocalStorage.getString(Env.username);
    String password = await LocalStorage.getString(Env.password);

    if (!mounted) return;

    if (token.isNotEmpty && username.isNotEmpty && password.isNotEmpty) {
      Navigator.pushReplacementNamed(context, AppRouter.main);
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
