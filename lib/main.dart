import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/router/index.dart';

import 'package:get_storage/get_storage.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_application_1/utils/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  runApp(
    const OKToast(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: AppConfig.fontSizeFactor,
      builder: (context, fontSize, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(fontSize),
              ),
              child: child!,
            );
          },
          initialRoute: AppRouter.splash,
          navigatorKey: AppRouter.navigatorKey,
          onGenerateRoute: AppRouter.generateRoute,
        );
      },
    );
  }
}
