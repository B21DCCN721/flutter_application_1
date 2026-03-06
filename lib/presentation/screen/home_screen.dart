import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/args/UserArg.dart';

class HomeScreen extends StatefulWidget {
  final UserArg args;
  const HomeScreen({super.key, required this.args});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, '/profile',
                    arguments: widget.args);
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              Image.asset('assets/imgs/poke_ball.png'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/pokemon');
                },
                child: const Text('Xem Pokemon'),
              ),
            ],
          ),
        ));
  }
}
