import 'dart:convert';

import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/models/data/Token.dart';
import 'package:flutter_application_1/utils/local_storage.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:flutter_application_1/utils/toast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/presentation/router/index.dart';
import 'package:flutter_application_1/service/auth_api.dart';

void goToLogin() {
  AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil(
    AppRouter.login,
    (route) => false,
  );
}

String buildAuthUrl(String url, String token) {
  if (url.contains("?")) {
    url = "$url&wstoken=$token";
  } else {
    url = "$url?wstoken=$token";
  }
  return url;
}

class ApiClient {
  static Future get(String url,
      {Map<String, String>? headers, bool requiredAuth = true}) async {
    try {
      headers = headers ?? <String, String>{};
      if (requiredAuth) {
        String token = await LocalStorage.getString(Env.token) ?? "";
        String authUrl = buildAuthUrl(url, token);
        var response = await http
            .get(Uri.parse(authUrl), headers: headers)
            .timeout(const Duration(seconds: 60));
        final responseJson = jsonDecode(response.body);
        if (responseJson is! List &&
            responseJson['errorcode'] == 'invalidtoken') {
          String username = await LocalStorage.getString(Env.username);
          String password = await LocalStorage.getString(Env.password);

          if (username.isNotEmpty && password.isNotEmpty) {
            logger("OnsClient re-login");
            final newAuthResponse =
                await AuthApi.login(username: username, password: password);
            Token newToken = Token.fromJson(newAuthResponse);
            if (newToken.isEmpty()) {
              await LocalStorage.remove(Env.username);
              await LocalStorage.remove(Env.password);
              await LocalStorage.remove(Env.token);
              goToLogin();
            } else {
              await LocalStorage.putString(Env.token, newToken.token);
              String newAuthUrl = buildAuthUrl(url, newToken.token);
              response = await http
                  .get(Uri.parse(newAuthUrl), headers: headers)
                  .timeout(const Duration(seconds: 60));
            }
          } else {
            goToLogin();
          }
        }
        return response;
      }
      var response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 60));
      return response;
    } catch (e) {
      if (e.toString().contains("host lookup")) {
        Toast.show("Vui lòng kiểm tra lại kết nối mạng");
      }
      AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRouter.error,
        (route) => false,
      );
      rethrow;
    }
  }

  static Future post(String url,
      {Map<String, String>? headers,
      dynamic body,
      dynamic encoding,
      bool requiredAuth = true}) async {
    headers = headers ?? <String, String>{};
    try {
      if (requiredAuth) {
        String token = await LocalStorage.getString(Env.token) ?? "";
        String authUrl = buildAuthUrl(url, token);
        var response = await http
            .post(Uri.parse(authUrl),
                headers: headers, body: body, encoding: encoding)
            .timeout(const Duration(seconds: 60));

        final responseJson = jsonDecode(response.body);
        if (responseJson['errorcode'] == 'invalidtoken') {
          logger("Hết phiên đăng nhập, đăng nhập lại tự động!");
          String username = await LocalStorage.getString(Env.username);
          String password = await LocalStorage.getString(Env.password);

          if (username.isNotEmpty && password.isNotEmpty) {
            logger("OnsClient re-login");
            final newAuthResponse =
                await AuthApi.login(username: username, password: password);
            Token newToken = Token.fromJson(newAuthResponse);
            if (newToken.isEmpty()) {
              await LocalStorage.remove(Env.username);
              await LocalStorage.remove(Env.password);
              await LocalStorage.remove(Env.token);
              goToLogin();
            } else {
              await LocalStorage.putString(Env.token, newToken.token);
              String newAuthUrl = buildAuthUrl(url, newToken.token);
              response = await http
                  .post(Uri.parse(newAuthUrl),
                      headers: headers, body: body, encoding: encoding)
                  .timeout(const Duration(seconds: 60));
            }
          } else {
            goToLogin();
          }
        }

        return response;
      }

      var response = await http
          .post(Uri.parse(url),
              headers: headers, body: body, encoding: encoding)
          .timeout(const Duration(seconds: 60));
      return response;
    } catch (e) {
      if (e.toString().contains("host lookup")) {
        Toast.show("Vui lòng kiểm tra lại kết nối mạng");
      }
      AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRouter.error,
        (route) => false,
      );
      rethrow;
    }
  }
}
