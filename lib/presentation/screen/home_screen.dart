import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go To Profile'),
          onPressed: () {
            Navigator.pushNamed(context, '/profile', arguments: username);
          },
        ),
      ),
    );
  }
}
