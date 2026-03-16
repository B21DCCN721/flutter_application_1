import 'dart:convert';
import 'dart:io';

import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/utils/http_client.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:http/http.dart' as http;

class ForumApi {
  static Future detailForum(
      {required String id,
      String name = "",
      int page = 1,
      int limit = 10,
      int perPage = 10,
      int sortOrder = 0,
      String userId = "",
      String classification = "",
      int groupId = 0}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=mod_forum_get_discussions_by_forum";
    url = "$url&moodlewsrestformat=json";
    url = "$url&forumid=$id";
    url = "$url&counttop=3";
    if (userId.isNotEmpty) {
      url = "$url&userid=$userId";
    }
    if (classification.isNotEmpty) {
      url = "$url&classification=$classification";
    }
    final response = await ApiClient.get(url);
    logger("ForumAPI:detailForum $url");
    return jsonDecode(response.body);
  }

  static Future listPopular({forumid = ""}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=mod_forum_get_outstands";
    url = "$url&counttop=3";
    url = "$url&moodlewsrestformat=json";
    if (forumid != "") {
      url = "$url&forumid=${forumid.toString()}";
    }
    final response = await ApiClient.get(url);
    logger("ForumAPI:listPopular $url");
    return jsonDecode(response.body);
  }

  static Future listFollow() async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=mod_forum_get_followings";
    url = "$url&moodlewsrestformat=json";
    final response = await ApiClient.get(url);
    logger("ForumAPI:listFollow $url");
    return jsonDecode(response.body);
  }

  static Future updateFollow(
      {required String token,
      required int discusId,
      required int forumId,
      required int isFollow}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    // url = "$url?wstoken=$token";
    // url = "$url&wsfunction=mod_forum_set_subscription_state";
    // url = "$url&targetstate=$isFollow";
    // url = "$url&forumid=$forumId";
    // url = "$url&discussionid=$discusId";
    // url = "$url&moodlewsrestformat=json";

    Map body = {
      "wstoken": token,
      "wsfunction": "mod_forum_set_subscription_state",
      "targetstate": "$isFollow",
      "forumid": "$forumId",
      "discussionid": "$discusId",
      "moodlewsrestformat": "json",
    };
    logger(body);
    final response = await http.post(Uri.parse(url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
        },
        body: body,
        encoding: Encoding.getByName('utf-8'));
    logger("ForumAPI:updateFollow $url");
    return jsonDecode(response.body);
  }

  static Future discussDetail({required int discussionId}) async {
    String url = "${Env.domain}/webservice/rest/server.php";

    url = "$url?wsfunction=mod_forum_get_forum_discussion_post";
    url = "$url&discussionid=$discussionId";
    url = "$url&counttop=3";
    url = "$url&moodlewsrestformat=json";
    final response = await ApiClient.get(url);
    logger("ForumAPI:discussDetail $url");
    return jsonDecode(response.body);
  }

  static Future listReply({required int discussionId}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=mod_forum_get_discussions_reply";
    url = "$url&discussionid=$discussionId";
    url = "$url&moodlewsrestformat=json";
    final response = await ApiClient.get(url);
    logger("ForumAPI:listReply $url");
    return jsonDecode(response.body);
  }

  static Future likePost({required int postId, required int isLike}) async {
    String url = "${Env.domain}/webservice/rest/server.php";
    url = "$url?wsfunction=mod_forum_like_discussion_post";
    url = "$url&postid=$postId";
    url = "$url&like=$isLike";
    url = "$url&moodlewsrestformat=json";
    final response = await ApiClient.get(url);
    logger("ForumAPI:like $url");
    return jsonDecode(response.body);
  }

  static Future replyDiscuss(
      {required int postId,
      required String subject,
      required String message}) async {
    String encodeMessage =
        const HtmlEscape(HtmlEscapeMode.element).convert(message);
    String url = "${Env.domain}/webservice/rest/server.php";

    final Map<String, String> body = {
      "wsfunction": "mod_forum_add_discussion_post",
      "postid": "$postId",
      "subject": subject,
      "message": encodeMessage,
      "moodlewsrestformat": "json",
    };

    final response = await ApiClient.post(url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
        },
        body: body,
        encoding: Encoding.getByName('utf-8'));
    logger("ForumAPI:replyDiscuss $url");
    return jsonDecode(response.body);
  }
}
