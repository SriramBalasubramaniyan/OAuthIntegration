import 'package:json_annotation/json_annotation.dart';

class Auth0IdToken {

  Auth0IdToken({
    required this.nickname,
    required this.name,
    required this.picture,
    required this.update_at,
    required this.email,
    required this.iss,
    required this.aud,
    required this.iat,
    required this.exp,
    required this.sub,
    this.authTime,
  });

  final String nickname;
  final String name;
  final String picture;
  final String update_at;
  final String email;
  final String iss;
  final String aud;
  final int iat;
  final int exp;
  final String sub;
  final int? authTime;

  factory Auth0IdToken.fromJson(Map<String, dynamic> json) {
    return Auth0IdToken(
      nickname: json['nickname'],
      name: json['name'],
      picture: json['picture'],
      update_at: json['updated_at'],
      email: json['email'],
      iss: json['iss'],
      aud: json['aud'],
      iat: json['iat'],
      exp: json['exp'],
      sub: json['sub'],
      authTime: json['auth_time'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nickname'] = this.nickname;
    data['name'] = this.name;
    data['picture'] = this.picture;
    data['updated_at'] = this.update_at;
    data['email'] = this.email;
    data['iss'] = this.iss;
    data['aud'] = this.aud;
    data['iat'] = this.iat;
    data['exp'] = this.exp;
    data['sub'] = this.sub;
    data['auth_time'] = this.authTime;
    return data;
  }

  @override
  String toString() {
    return {
    'nickname' : nickname,
    'name' : name,
    'picture' : picture,
    'updated_at' : update_at,
    'email' : email,
    'iss' : iss,
    'aud' : aud,
    'iat' : iat,
    'exp' : exp,
    'sub' : sub,
    'auth_time' : authTime,
    }.toString();
  }
}