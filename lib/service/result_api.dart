import 'dart:convert';

import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/utils/http_client.dart';
import 'package:flutter_application_1/utils/logger.dart';

class ResultApi {
  static Future resultCourse(
      {String status = "", String condition = ""}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=local_core_get_user_grade_overview";
    url = "$url&moodlewsrestformat=json";
    if (status.isNotEmpty) {
      url = "$url&status=$status";
    }
    if (condition.isNotEmpty) {
      url = "$url&condition=$condition";
    }
    final response = await ApiClient.get(url);
    logger("ResultAPI:resultCourse $url");
    return jsonDecode(response.body);
  }
}
