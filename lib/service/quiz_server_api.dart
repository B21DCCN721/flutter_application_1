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

  static Future saveAttempt({
    required String attemptid,
    required String slot,
    required String value,
  }) async {
    String url =
        "https://quiz-server-dev.onschool.edu.vn/$schoolname/attempt/$attemptid/answer";

    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'slot': slot,
        'position': -1,
        'answer': value,
      }),
    );

    logger("QuizServerAPI:saveAttempt $url");
    logger(response.body);

    return jsonDecode(response.body);
  }

  static Future flagQuestion({
    required String attemptid,
    required String slot,
  }) async {
    String url =
        "https://quiz-server-dev.onschool.edu.vn/$schoolname/attempt/$attemptid/$slot/flag";
    final response = await http.post(Uri.parse(url));
    logger("QuizServerAPI:saveAttempt $url");
    return jsonDecode(response.body);
  }

  static Future submitAttempt({required String attemptid}) async {
    String url =
        "https://quiz-server-dev.onschool.edu.vn/$schoolname/attempt/$attemptid/submit";
    final response = await http.post(Uri.parse(url));
    logger("QuizServerAPI:submitAttempt $url");
    return jsonDecode(response.body);
  }
}
