import 'dart:convert';
import 'dart:io';
import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:http/http.dart' as http;

class ReportAPI {
  static Future submitFeedback(
      {required String token,
      required String content,
      required String file1,
      required String file2,
      required String file3}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.headers.addAll(
        {HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'});
    request.fields['wstoken'] = token;
    request.fields['wsfunction'] = "local_report_portal_add_report";
    request.fields['content'] = content;
    request.fields['moodlewsrestformat'] = "json";
    request.fields['origin'] = "app";

    if (file1.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file1,
      ));
    }
    if (file2.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file2,
      ));
    }
    if (file3.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file3,
      ));
    }

    logger(request.fields);
    logger(request.files);
    http.Response response =
        await http.Response.fromStream(await request.send());

    logger("ReportAPI:submitFeedback $url");
    return jsonDecode(response.body);
  }
}
