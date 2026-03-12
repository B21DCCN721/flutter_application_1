import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/args/quiz_detail.dart';
import 'package:flutter_application_1/presentation/screen/course_detail_screen.dart';
import 'package:flutter_application_1/presentation/screen/course_screen.dart';
import 'package:flutter_application_1/presentation/screen/do_quiz_screen.dart';
import 'package:flutter_application_1/presentation/screen/error_screen.dart';
import 'package:flutter_application_1/presentation/screen/learning_task_screen.dart';
import 'package:flutter_application_1/presentation/screen/main_screen.dart';
import 'package:flutter_application_1/presentation/screen/login_screen.dart';
import 'package:flutter_application_1/presentation/screen/overview_screen.dart';
import 'package:flutter_application_1/presentation/screen/pokemon_screen.dart';
import 'package:flutter_application_1/presentation/screen/profile_screen.dart';
import 'package:flutter_application_1/presentation/screen/quiz_detail_screen.dart';
import 'package:flutter_application_1/presentation/screen/result_screen.dart';
import 'package:flutter_application_1/presentation/screen/settings_screen.dart';
import 'package:flutter_application_1/presentation/screen/forgot_password_screen.dart';
import 'package:flutter_application_1/presentation/screen/splash_screen.dart';
import 'package:flutter_application_1/presentation/screen/report_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static const String splash = '/';
  static const String login = '/login';
  static const String main = '/main';
  static const String profile = '/profile';
  static const String pokemon = '/pokemon';
  static const String settings = '/settings';
  static const String forgotPassword = '/forgot-password';
  static const String overview = '/overview';
  static const String report = '/report';
  static const String course = '/course';
  static const String courseDetail = '/course-detail';
  static const String result = '/result';
  static const String error = '/error';
  static const String learningTask = '/learning-task';
  static const String quizDetail = '/quiz-detail';
  static const String doQuiz = '/do-quiz';

  static MaterialPageRoute generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case pokemon:
        return MaterialPageRoute(builder: (_) => const PokemonScreen());
      case AppRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRouter.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case overview:
        return MaterialPageRoute(builder: (_) => const OverviewScreen());
      case report:
        return MaterialPageRoute(builder: (_) => const ReportScreen());
      case course:
        return MaterialPageRoute(builder: (_) => const CourseScreen());
      case courseDetail:
        final id = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => CourseDetailScreen(id: id));
      case result:
        return MaterialPageRoute(builder: (_) => const ResultScreen());
      case error:
        return MaterialPageRoute(builder: (_) => const ErrorScreen());
      case learningTask:
        return MaterialPageRoute(builder: (_) => const LearningTaskScreen());
      case quizDetail:
        final arg = settings.arguments as QuizDetailArg;
        return MaterialPageRoute(builder: (_) => QuizDetailScreen(arg: arg));
      case doQuiz:
        return MaterialPageRoute(builder: (_) => const DoQuizScreen());
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
