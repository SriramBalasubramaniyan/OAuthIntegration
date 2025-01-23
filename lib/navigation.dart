import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:oainteg/main.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashBoard extends StatefulWidget {
  String name, agentid;

  DashBoard(this.name,
      this.agentid,);

  @override
  _DashBoardAppState createState() => _DashBoardAppState();
}

class _DashBoardAppState extends State<DashBoard> with WidgetsBindingObserver {
  final appAuth = FlutterAppAuth();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state ' + state.toString());
    switch (state) {
      case AppLifecycleState.resumed:
        print('lifecycle resume');
        break;
      case AppLifecycleState.inactive:
        print('lifecycle inactive');
        break;
      case AppLifecycleState.paused:
        print('lifecycle paused');
        break;
      case AppLifecycleState.detached:
        print('lifecycle detached');
        break;
    }
  }

  Future<bool> _onBackPressed() async {
    return (await Alert(
      context: context,
      type: AlertType.warning,
      title: 'Cancel',
      desc: 'Are you sure you want to cancel',
      buttons: [
        DialogButton(
          child: Text(
            'Yes',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          width: 120,
        ),
        DialogButton(
          child: Text(
            'No',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          width: 120,
        )
      ],
    ).show()) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: SafeArea(
        child: WillPopScope(
          onWillPop: _onBackPressed,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              centerTitle: true,
              leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    _onBackPressed();
                  }),
              title: Text(
                '',
                style: new TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700),
              ),
              iconTheme: IconThemeData(color: Colors.white),
              backgroundColor: Colors.green,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  DialogButton(
                    child: Text('logout',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    onPressed: () {
                      logout();
                    },
                    color: Colors.green,
                  )
                ],
              ),
            ),
          ),
        ),
      ),);
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("REFRESH_TOKEN_KEY");

    /*final request = EndSessionRequest(
      idTokenHint: JsonEncoder(idToken!.toJson()),
      issuer: AUTH0_ISSUER,
      postLogoutRedirectUrl: '$BUNDLER_INDENTIFIER:/'
    );
    appAuth.endSession(request);*/// logout from OAuth server method-2

    _onBackPressed();
  }
}
