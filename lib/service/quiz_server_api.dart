import 'dart:convert';

import 'package:flutter_application_1/utils/logger.dart';
import 'package:http/http.dart' as http;

String schoolname = 'BAV';

class QuizServerApi {
  static Future getAttempt({required String attemptid}) async {
    String url =
        "https://quiz-server-dev.onschool.edu.vn/$schoolname/attempt/$attemptid";
    final response = await http.get(Uri.parse(url));
    logger("QuizServerAPI:getAttempt $url");
    return jsonDecode(response.body);
  }
}
