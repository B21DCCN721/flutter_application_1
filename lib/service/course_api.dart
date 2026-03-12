import 'dart:convert';

import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/utils/http_client.dart';
import 'package:flutter_application_1/utils/logger.dart';

class CourseApi {
  static Future listCourses(
      {String classification = "all", String search = ""}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url =
        "$url?wsfunction=core_course_get_enrolled_courses_by_timeline_classification";
    url = "$url&moodlewsrestformat=json";
    url = "$url&classification=$classification";
    url = "$url&search=$search";
    final response = await ApiClient.get(url);
    logger("CourseAPI:listCourses $url");
    return jsonDecode(response.body);
  }

  static Future detailCourse({required String courseId}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=core_course_get_contents";
    url = "$url&moodlewsrestformat=json";
    url = "$url&courseid=$courseId";
    final response = await ApiClient.get(url);
    logger("CourseAPI:detailCourse $url");
    return jsonDecode(response.body);
  }

  static Future detailCourseModule({required String cmid}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=local_core_get_info_module";
    url = "$url&cmid=$cmid";
    url = "$url&moodlewsrestformat=json";
    final response = await ApiClient.get(url);
    logger("CourseAPI:detailCourseModule $url");
    return jsonDecode(response.body);
  }
}
