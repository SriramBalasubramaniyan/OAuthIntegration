import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:oainteg/model/auth0_id_token.dart';
import 'package:oainteg/model/auth0_user.dart';
import 'package:oainteg/navigation.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

const AUTH0_DOMAIN = 'dev-3d2tlytfi6tzefns.us.auth0.com';
const AUTH0_CLIENT_ID = 'QhUvJSIrpbFXG1NcuBk0ME0ZBjTN3utE';
const AUTH0_ISSUER = 'https://$AUTH0_DOMAIN';
const BUNDLER_INDENTIFIER = 'com.sts.datagreen.oainteg';
const AUTH0_REDIRECT_URI = '$BUNDLER_INDENTIFIER://login-callback';
const REFRESH_TOKEN_KEY = 'refresh_token';

typedef AsyncCallBackString = Future<String> Function();

void main() {
  runApp(const MyApp());
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.dualRing
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.green
    ..backgroundColor = Colors.white
    ..indicatorColor = Colors.green
    ..textColor = Colors.green
    ..maskColor = Colors.black.withOpacity(0.5)
    ..userInteractions = true
    ..fontSize = 16
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      builder: EasyLoading.init(),
      home: const MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final appAuth = FlutterAppAuth();

  String? accessToken;
  Auth0IdToken? IdToken;
  Auth0User? profile;

  @override
  void initState() {
    super.initState();
    print('initState');
    initialize();
  }

  Future<String> initialize() async {
    return errorHandler(() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final securedRefreshToken = prefs.getString("REFRESH_TOKEN_KEY");
      print('SecuredRefreshToken: ' + securedRefreshToken!);

      if(securedRefreshToken == null ) {
        return 'Please login';
      }

      final tokenResponse = await appAuth.token(
        TokenRequest(
          AUTH0_CLIENT_ID,
          AUTH0_REDIRECT_URI,
          issuer: AUTH0_ISSUER,
          refreshToken: securedRefreshToken,
        ),
      );

      return setlocalVarirable(tokenResponse);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DialogButton(
              child: Text('SignIn',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              onPressed: () async {
                final result = await loginAuth();
                if(result != "Success") {
                  final snackBar = SnackBar(content: Text(result));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              color: Colors.green,
            )
          ],
        ),
      ),
    );
  }

  bool isAuthResultValid(TokenResponse? response) {
    return response?.accessToken != null && response?.idToken != null;
  }

  Future<String> setlocalVarirable (TokenResponse? result) async {
    if(isAuthResultValid(result)) {
      EasyLoading.show();

      accessToken = result!.accessToken!;
      print('accessToken: ' + result.accessToken!);
      print('accessTokenExpirationDateTime: ' + result.accessTokenExpirationDateTime.toString());

      IdToken = parseIdToken(result.idToken!);
      print('IDToken [] => $IdToken');

      profile = await getUserDetails(accessToken!);
      print('refreshToken: ' + result.refreshToken!);

      if(result.refreshToken!.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("REFRESH_TOKEN_KEY", result.refreshToken!);
      }

      EasyLoading.dismiss();
      loginNav(true);

      return 'Success';
    }
    return 'Passing Token went wrong';
  }

  Future<String> errorHandler(AsyncCallBackString callback) async {
    try {
      return await callback();
    } on TimeoutException catch (e) {
      return e.message ?? "Timeout Error!";
    } on FormatException catch (e) {
      return e.message;
    } on SocketException catch (e) {
      return e.message;
    } on PlatformException catch (e) {
      return e.message ?? 'Something is Wrong! Code: ${e.code}';
    } on UserInfoException catch(e) {
      return e.message;
    } catch (e) {
      return 'Unknown error ${e.runtimeType}';
    }
  }

  Future<String> loginAuth() async {
      return errorHandler(() async {
        final authorizationTokenRequest = AuthorizationTokenRequest(
          AUTH0_CLIENT_ID, AUTH0_REDIRECT_URI,
          issuer: AUTH0_ISSUER,
          scopes: [
            'openid',
            'profile',
            'email',
            'offline_access',
          ],
          promptValues: ['login']
        );

        final result = await appAuth.authorizeAndExchangeCode(
            authorizationTokenRequest);
        return setlocalVarirable(result);
      });
  }

  Auth0IdToken parseIdToken(String idToken) {
    print('IDToken '+ idToken);
    final parts = idToken.split(r'.');

    final Map <String, dynamic> json = jsonDecode(
        utf8.decode(
          base64Url.decode(
            base64Url.normalize(parts[1]), //idToken-body
          ),
        ),
    );
    print('IDToken-body ' + json.toString());
    return Auth0IdToken.fromJson(json);
  }

  loginNav(bool login){
    if(login) {
      Navigator.of(context).push(
          MaterialPageRoute(
              builder: (BuildContext context) => DashBoard('','')));
    }
  }

  Future<Auth0User?> getUserDetails(String accessToken) async {
    final url = Uri.https(AUTH0_DOMAIN, '/userinfo');
    print('userInfoUrl: $url');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('userDetailsInfo: ${response.body}');
    print('statusCode: ${response.statusCode}');

    if(response.statusCode == 200) {
      return Auth0User.fromJson(jsonDecode(response.body));
    } else {
      throw UserInfoException('Failed to get User details');
    }
  }

}

class UserInfoException implements Exception {
  const UserInfoException(this.message);
  final String message;
}