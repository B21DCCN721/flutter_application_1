import 'dart:convert';

import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/utils/http_client.dart';
import 'package:flutter_application_1/utils/logger.dart';

class QuizApi {
  static Future historyQuiz(
      {required String quizId, String status = "all"}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=mod_quiz_get_user_attempts";
    url = "$url&moodlewsrestformat=json";
    url = "$url&includepreviews=1";
    url = "$url&quizid=$quizId";
    url = "$url&status=$status";
    final response = await ApiClient.get(url);
    logger("QuizAPI:historyQuiz $url");
    return jsonDecode(response.body);
  }

  static Future quizContent(
      {required int attemptId,
      int page = 0,
      String password = "",
      required bool requireCamera}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=mod_quiz_get_attempt_data";
    url = "$url&moodlewsrestformat=json";
    if (password.isNotEmpty) {
      url = "$url&preflightdata[0][name]=quizpassword";
      url = "$url&preflightdata[0][value]=$password";
    }
    if (requireCamera) {
      url = "$url&preflightdata[1][name]=proctoring";
      url = "$url&preflightdata[1][value]=true";
    }
    url = "$url&attemptid=$attemptId";
    url = "$url&page=$page";
    final response = await ApiClient.get(url);
    logger("QuizAPI:quizContent $url");
    return jsonDecode(response.body);
  }

  static Future startQuiz(
      {required int quizId,
      String password = "",
      required bool requireCamera}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=mod_quiz_start_attempt";
    url = "$url&moodlewsrestformat=json";
    url = "$url&quizid=$quizId";
    if (password.isNotEmpty) {
      url = "$url&preflightdata[0][name]=quizpassword";
      url = "$url&preflightdata[0][value]=$password";
    }
    if (requireCamera) {
      url = "$url&preflightdata[1][name]=proctoring";
      url = "$url&preflightdata[1][value]=true";
    }
    final response = await ApiClient.get(url);
    logger("QuizAPI:startQuiz $url");
    return jsonDecode(response.body);
  }
}
