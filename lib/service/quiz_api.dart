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
}
