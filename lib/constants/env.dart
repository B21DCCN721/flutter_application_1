import 'package:flutter/foundation.dart';

class Env {
  static String pokeUrl = 'https://pokeapi.co/api/v2/pokemon';
  static String domain = kDebugMode
      ? 'https://bavbomstg.onschool.edu.vn'
      : 'https://admin-bav.onschool.edu.vn';
  static String username = "username";
  static String password = "password";
  static String token = "token";
  static String keyword = "keyword";
  static String usernameForGGA = "Chưa đăng nhập";

  static String localQuizzes = "localQuizzes";
}
