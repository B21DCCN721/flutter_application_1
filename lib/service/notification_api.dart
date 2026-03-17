import 'dart:convert';

import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/utils/http_client.dart';
import 'package:flutter_application_1/utils/logger.dart';

class NotificationApi {
  static Future listNotifications({int limit = 10}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=local_message_get_user_notification_preferences";
    url = "$url&moodlewsrestformat=json";
    url = "$url&limit=$limit";
    final response = await ApiClient.get(url);
    logger("NotificationAPI:listNotifications $url");
    return jsonDecode(response.body);
  }
}
