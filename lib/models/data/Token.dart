class Token {
  String token;
  String privateToken;

  Token({this.token = "", this.privateToken = ""});

  factory Token.fromJson(json) => Token(
        token: json['token'] ?? "",
        privateToken: json['privatetoken'] ?? "",
      );

  bool isEmpty() {
    return token.isEmpty;
  }
}
