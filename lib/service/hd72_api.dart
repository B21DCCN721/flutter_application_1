import 'dart:convert';

import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/utils/http_client.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:mime/mime.dart';

class Hd72Api {
  static Future list({
    int limit = 10,
    int offset = 0,
    String courseId = "",
    String createdBy = "",
  }) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=local_hd72_get_threads";
    if (createdBy.isNotEmpty) {
      url = "$url&created_by=$createdBy";
    }
    if (courseId.isNotEmpty) {
      url = "$url&courseid=$courseId";
    }
    url = "$url&moodlewsrestformat=json";
    final response = await ApiClient.get(url);
    logger("Hd72API:list $url");
    return jsonDecode(response.body);
  }

  static Future countStatus({String courseId = ""}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=local_hd72_count_threads_by_status";
    if (courseId.isNotEmpty) {
      url = "$url&courseid=$courseId";
    }
    url = "$url&moodlewsrestformat=json";
    final response = await ApiClient.get(url);
    logger("Hd72API:countStatus $url");
    return jsonDecode(response.body);
  }

  static Future questionDetail({required int threadId}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=local_hd72_get_thread_detail";
    url = "$url&threadid=$threadId";
    url = "$url&moodlewsrestformat=json";
    final response = await ApiClient.get(url);
    logger("Hd72API:questionDetail $url");
    return jsonDecode(response.body);
  }

  static Future countByCourse() async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=local_hd72_get_count_threads_by_courses";
    url = "$url&moodlewsrestformat=json";
    final response = await ApiClient.get(url);
    logger("Hd72API:countByCourse $url");
    return jsonDecode(response.body);
  }

  static Future addDiscussion(
      {required String token,
      required int courseId,
      required String subject,
      required String message,
      String threadId = "",
      String fileName = "",
      String filePath = ""}) async {
    String encodeMessage =
        const HtmlEscape(HtmlEscapeMode.element).convert(message);
    String url = "${Env.domain}/webservice/rest/server.php";

    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.fields['wstoken'] = token;
    request.fields['wsfunction'] = "local_hd72_create_question";
    request.fields['courseid'] = "$courseId";
    request.fields['moodlewsrestformat'] = "json";
    request.fields['subject'] = subject;
    request.fields['message'] = encodeMessage;
    if (threadId.isNotEmpty) {
      request.fields['threadid'] = threadId;
    }

    if (filePath.isNotEmpty) {
      request.fields['filename'] = fileName;
      String? contentType = lookupMimeType(filePath);
      contentType ??= 'application/octet-stream';
      List contentTypeArr = contentType.split("/");
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType(contentTypeArr[0], contentTypeArr[1]),
      ));
    }
    logger(request.fields);
    logger(filePath);
    http.Response response =
        await http.Response.fromStream(await request.send());
    logger("Hd72API:addDiscussion $url");
    return jsonDecode(response.body);
  }
}
