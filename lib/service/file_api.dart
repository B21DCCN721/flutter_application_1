import 'dart:convert';
import 'dart:io';

import 'package:flutter_application_1/utils/logger.dart';
import 'package:flutter_application_1/constants/env.dart';
import 'package:http/http.dart' as http;

class FileApi {
  static Future uploadFile(
      {required String token,
      required String filePath,
      String itemid = ''}) async {
    logger(filePath);
    String url = "${Env.domain}/webservice/upload.php";
    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.headers.addAll(
        {HttpHeaders.contentTypeHeader: 'application/json', 'token': token});
    request.fields['token'] = token;
    request.fields['filearea'] = 'draft';
    request.fields['filepath'] = '/';
    request.fields['component'] = 'user';
    request.fields['itemid'] = itemid;
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      filePath,
    ));
    http.Response response =
        await http.Response.fromStream(await request.send());
    logger("Call api upload image $url");
    return jsonDecode(response.body);
  }
}
