import 'dart:convert';

import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/utils/http_client.dart';
import 'package:flutter_application_1/utils/logger.dart';

class AssignApi {
  static Future getGrade({required String assignId}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=report_finalgrade_get_assign_final_grade";
    url = "$url&moodlewsrestformat=json";
    url = "$url&assignid=$assignId";
    final response = await ApiClient.get(url);
    logger("AssignAPI:getGrade $url");
    return jsonDecode(response.body);
  }

  static Future submit({required int assignId, required fileItemId}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=mod_assign_save_submission";
    url = "$url&moodlewsrestformat=json";
    url = "$url&assignmentid=$assignId";
    url = "$url&plugindata[files_filemanager]=$fileItemId";
    final response = await ApiClient.get(url);
    logger("AssignAPI:submit $url");
    return jsonDecode(response.body);
  }

  static Future deleteFile({required int fileId, required int confirm}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=report_finalgrade_delete_file";
    url = "$url&moodlewsrestformat=json";
    url = "$url&fileid=$fileId";
    url = "$url&confirm=$confirm";
    final response = await ApiClient.get(url);
    logger("AssignAPI:delete $url");
    return jsonDecode(response.body);
  }
}
