import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/presentation/router/index.dart';
import 'package:flutter_application_1/service/auth_api.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';
import 'package:flutter_application_1/utils/local_storage.dart';
import 'package:flutter_application_1/utils/logger.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int index)? onTabChange;

  const HomeScreen({super.key, this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String name = "";

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void _getUser() async {
    try {
      final response = await AuthApi.user();
      await LocalStorage.putString(
          Env.userId, response['data']?['userid']?.toString() ?? "");
      if (mounted) {
        setState(() {
          name = response['data']?['fullname'] ?? "";
        });
      }
    } catch (e) {
      logger("HomeScreen Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
            child: SingleChildScrollView(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/imgs/bg1.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/imgs/dnu_logo.png',
                    height: 80,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouter.overview);
                        },
                        icon: const CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                      Gaps.hGap8,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Hi~~~",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            name,
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.9)),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Các chức năng chính",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gaps.vGap12,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            widget.onTabChange?.call(1); // Tab Khóa học
                          },
                          child: const Column(
                            children: [
                              Icon(Icons.book, size: 40),
                              Text("Khóa học")
                            ],
                          ),
                        ),
                        Gaps.hGap12,
                        InkWell(
                          onTap: () {
                            widget.onTabChange?.call(2); // Tab Nhiệm vụ
                          },
                          child: const Column(
                            children: [
                              Icon(Icons.task, size: 40),
                              Text("Nhiệm vụ")
                            ],
                          ),
                        ),
                        Gaps.hGap12,
                        InkWell(
                          onTap: () {
                            widget.onTabChange?.call(3); // Tab Kết quả
                          },
                          child: const Column(
                            children: [
                              Icon(Icons.assessment, size: 40),
                              Text("Kết quả")
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gaps.vGap16,
                  Container(
                    height: 400,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/imgs/banner.png'),
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                  Gaps.vGap16,
                  const Text(
                    "Tin tức",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gaps.vGap8,
                  const Text(
                    "Tiện ích",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ))));
  }
}
