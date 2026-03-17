import 'dart:convert';
import 'dart:io';
import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/utils/http_client.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:http/http.dart' as http;

class AuthApi {
  static Future login(
      {required String username, required String password}) async {
    String url = "${Env.domain}/login/token.php";
    Map params = <String, dynamic>{};
    params['username'] = username;
    params['password'] = password;
    params['service'] = 'moodle_mobile_app';
    params['rememberusername'] = "1";
    final response = await http.post(Uri.parse(url), body: params);
    logger("Call api login $url");
    return jsonDecode(response.body);
  }

  static Future sendOtp({required String email}) async {
    String url = "${Env.domain}/lib/ajax/service.php";

    var data = [
      {
        "index": 0,
        "methodname": "core_auth_request_password_reset",
        "args": {"username": "", "email": email, "origin_callapi": "ok"}
      }
    ];

    final response = await http.post(
      Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(data),
    );

    logger("AuthAPI::sendOtp $url");

    return jsonDecode(response.body);
  }

  static Future user() async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=local_core_get_site_info";
    url = "$url&moodlewsrestformat=json";
    final response = await ApiClient.get(url);
    logger("Call api get user $url");
    return jsonDecode(response.body);
  }

  static Future updatePasswordFromOld(
      {required String password,
      required String newPassword,
      required String confirmNewPassword}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    Map params = <String, dynamic>{};
    params['password'] = password;
    params['newpassword'] = newPassword;
    params['confirm_newpassword'] = confirmNewPassword;
    params['moodlewsrestformat'] = 'json';
    params['wsfunction'] = 'local_core_reset_password';
    final response = await ApiClient.post(url, body: params);
    logger("AuthAPI::updatePasswordFromOld $url");
    return jsonDecode(response.body);
  }

  static Future updateAvatar({required String itemId}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=core_user_update_picture";
    url = "$url&draftitemid=$itemId";
    url = "$url&moodlewsrestformat=json";
    final response = await ApiClient.get(url);
    logger("AuthAPI::updateAvatar $url");
    return jsonDecode(response.body);
  }
}
