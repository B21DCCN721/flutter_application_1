import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/args/UserArg.dart';

class ProfileScreen extends StatelessWidget {
  final UserArg args;
  const ProfileScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Text('Username: ${args.username}'),
      ),
    );
  }
}
