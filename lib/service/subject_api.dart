import 'dart:convert';

import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/utils/http_client.dart';
import 'package:flutter_application_1/utils/logger.dart';

class SubjectAPI {
  static Future list() async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=local_core_get_list_course_options";
    url = "$url&moodlewsrestformat=json";
    url = "$url&classification=all";
    final response = await ApiClient.get(url);
    logger("SubjectAPI:list $url");
    return jsonDecode(response.body);
  }
}
