import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/screen/course_screen.dart';
import 'package:flutter_application_1/presentation/screen/home_screen.dart';
import 'package:flutter_application_1/presentation/screen/learning_task_screen.dart';
import 'package:flutter_application_1/presentation/screen/notification_screen.dart';
import 'package:flutter_application_1/presentation/screen/result_screen.dart';
import 'package:flutter_application_1/theme/colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Stack lưu lịch sử tab
  final List<int> _tabHistory = [0];

  List<Widget> get _screens => [
        HomeScreen(onTabChange: _onItemTapped),
        const CourseScreen(),
        const LearningTaskScreen(),
        const ResultScreen(),
        const NotificationScreen(),
      ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _tabHistory.add(index); // lưu history
      _selectedIndex = index;
    });

    _pageController.jumpToPage(index);
  }

  Future<bool> _onWillPop() async {
    // Nếu có history → back về tab trước
    if (_tabHistory.length > 1) {
      _tabHistory.removeLast();
      int previousIndex = _tabHistory.last;

      setState(() {
        _selectedIndex = previousIndex;
      });

      _pageController.jumpToPage(previousIndex);
      return false; // không thoát app
    }

    return true; // thoát app
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              activeIcon: Icon(Icons.book),
              label: 'Khóa học',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task_outlined),
              activeIcon: Icon(Icons.task),
              label: 'Nhiệm vụ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment_outlined),
              activeIcon: Icon(Icons.assessment),
              label: 'Kết quả',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Thông báo',
            ),
          ],
        ),
      ),
    );
  }
}
