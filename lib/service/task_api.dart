import 'dart:convert';

import 'package:flutter_application_1/utils/http_client.dart';
import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/utils/logger.dart';

class TaskApi {
  static Future listCompletion(
      {String courseId = "",
      String timeline = "all",
      String status = "",
      String search = "",
      String fromTime = "",
      String toTime = ""}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=core_completion_get_activities_completion_status";
    url = "$url&timeline=$timeline";
    if (courseId.isNotEmpty) {
      url = "$url&courseid=$courseId";
    }
    if (status.isNotEmpty) {
      url = "$url&state=$status";
    }
    if (search.isNotEmpty) {
      url = "$url&search=$search";
    }
    url = "$url&moodlewsrestformat=json";
    if (fromTime.isNotEmpty) {
      url = "$url&timefrom=$fromTime";
    }
    if (toTime.isNotEmpty) {
      url = "$url&timeto=$toTime";
    }
    final response = await ApiClient.get(url);
    logger("ActionAPI:listCompletion $url");
    return jsonDecode(response.body);
  }
}
