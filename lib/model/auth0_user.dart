import 'package:json_annotation/json_annotation.dart';

class Auth0User {

  Auth0User({
    required this.sub,
    // required this.given_name,
    // required this.family_name,
    required this.nickname,
    required this.name,
    required this.picture,
    required this.updated_at,
    required this.email,
    required this.email_verified,
  });


  final String sub;
  // final String given_name;
  // final String family_name;
  final String nickname;
  final String name;
  final String picture;
  final String updated_at;
  final String email;
  final bool email_verified;

  factory Auth0User.fromJson(Map<String, dynamic> json) {
    return Auth0User(
      sub: json['sub'],
      // given_name: json['given_name'],
      // family_name: json['family_name'],
      nickname: json['nickname'],
      name: json['name'],
      picture: json['picture'],
      updated_at: json['updated_at'],
      email: json['email'],
      email_verified: json['email_verified'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sub'] = this.sub;
    // data['given_name'] = this.given_name;
    // data['family_name'] = this.family_name;
    data['nickname'] = this.nickname;
    data['name'] = this.name;
    data['picture'] = this.picture;
    data['updated_at'] = this.updated_at;
    data['email'] = this.email;
    data['email_verified'] = this.email_verified;

    return data;
  }

  @override
  String toString() {
    return {
      'sub': sub,
      // 'given_name': given_name,
      // 'family_name': family_name,
      'nickname': nickname,
      'name': name,
      'picture': picture,
      'updated_at': updated_at,
      'email': email,
      'email_verified': email_verified,
    }.toString();
  }

}