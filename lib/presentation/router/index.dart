import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/args/do_file.dart';
import 'package:flutter_application_1/models/args/do_test.dart';
import 'package:flutter_application_1/models/args/forum_detail.dart';
import 'package:flutter_application_1/models/args/hd72_list.dart';
import 'package:flutter_application_1/models/args/hd72_question_detail.dart';
import 'package:flutter_application_1/models/args/quiz_detail.dart';
import 'package:flutter_application_1/presentation/screen/course_detail_screen.dart';
import 'package:flutter_application_1/presentation/screen/course_screen.dart';
import 'package:flutter_application_1/presentation/screen/do_file_screen.dart';
import 'package:flutter_application_1/presentation/screen/do_quiz_screen.dart';
import 'package:flutter_application_1/presentation/screen/do_test_screen.dart';
import 'package:flutter_application_1/presentation/screen/error_screen.dart';
import 'package:flutter_application_1/presentation/screen/hd72_question_detail_screen.dart';
import 'package:flutter_application_1/presentation/screen/pdf_viewer_screen.dart';
import 'package:flutter_application_1/presentation/screen/webview_screen.dart';
import 'package:flutter_application_1/models/args/media_viewer.dart';
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
import 'package:flutter_application_1/presentation/screen/change_password_in_app_screen.dart';
import 'package:flutter_application_1/presentation/screen/forum_detail_screen.dart';
import 'package:flutter_application_1/presentation/screen/forum_detail_post_screen.dart';
import 'package:flutter_application_1/models/args/forum_detail_post.dart';
import 'package:flutter_application_1/presentation/screen/result_detail_screen.dart';
import 'package:flutter_application_1/presentation/screen/hd72_list_screen.dart';
import 'package:flutter_application_1/models/args/result_detail.dart';
import 'package:flutter_application_1/models/args/hd72_create_question.dart';
import 'package:flutter_application_1/presentation/screen/hd72_create_question_screen.dart';
import 'package:flutter_application_1/presentation/screen/hd72_add_question_screen.dart';
import 'package:flutter_application_1/models/args/search.dart';

import 'package:flutter_application_1/presentation/screen/search_screen.dart';


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
  static const String changePassword = '/change-password-in-app';
  static const String forumDetail = '/forum-detail';
  static const String hd72List = '/hd72-list';
  static const String forumDetailPost = '/forum-detail-post';
  static const String resultDetail = '/result-detail';
  static const String hd72QuestionDetail = '/hd72-question-detail';
  static const String doFile = '/do-file';
  static const String doTest = '/do-test';
  static const String webview = '/webview';
  static const String videoPlayer = '/video-player';
  static const String pdfViewer = '/pdf-viewer';
  static const String hd72CreateQuestion = '/hd72-create-question';
  static const String hd72AddQuestion = '/hd72-add-question';
  static const String search = '/search';


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
      case changePassword:
        return MaterialPageRoute(
            builder: (_) => const ChangePasswordInAppScreen());

      case forumDetail:
        final arg = settings.arguments as ForumDetailArg;
        return MaterialPageRoute(builder: (_) => ForumDetailScreen(arg: arg));

      case forumDetailPost:
        final arg = settings.arguments as ForumDetailPostArg;
        return MaterialPageRoute(
            builder: (_) => ForumDetailPostScreen(arg: arg));

      case resultDetail:
        final arg = settings.arguments as ResultDetailArg;
        return MaterialPageRoute(builder: (_) => ResultDetailScreen(arg: arg));

      case hd72List:
        final arg = settings.arguments as Hd72ListArg;
        return MaterialPageRoute(builder: (_) => Hd72ListScreen(arg: arg));

      case hd72QuestionDetail:
        final arg = settings.arguments as Hd72QuestionDetailArg;
        return MaterialPageRoute(
            builder: (_) => Hd72QuestionDetailScreen(arg: arg));
      case doFile:
        final arg = settings.arguments as DoFileArg;
        return MaterialPageRoute(builder: (_) => DoFileScreen(arg: arg));
      case doTest:
        final arg = settings.arguments as DoTestArg;
        return MaterialPageRoute(builder: (_) => DoTestScreen(arg: arg));
      case webview:
        final arg = settings.arguments as MediaViewerArg;
        return MaterialPageRoute(builder: (_) => WebviewScreen(arg: arg));
      case pdfViewer:
        final arg = settings.arguments as MediaViewerArg;
        return MaterialPageRoute(builder: (_) => PdfViewerScreen(arg: arg));
      case hd72CreateQuestion:
        final arg = settings.arguments as Hd72CreateQuestionArg?;
        return MaterialPageRoute(
            builder: (_) => Hd72CreateQuestionScreen(arg: arg));
      case hd72AddQuestion:
        final arg = settings.arguments as Hd72CreateQuestionArg;
        return MaterialPageRoute(builder: (_) => Hd72AddQuestionScreen(arg: arg));
      case search:

        final arg = settings.arguments as SearchArg;
        return MaterialPageRoute(builder: (_) => SearchScreen(arg: arg));
      default:

        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
