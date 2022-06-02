import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

import 'authorizationData.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:vbs_shared/vbs_shared.dart';

class Login extends StatefulWidget {
  const Login({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController user = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isError = false;
  String message = 'Your user name or password are incorrect';

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            children: [
              Visibility(
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                      child: Text(message, style: const TextStyle(
                          color: Colors.red, fontSize: 14),
                      )
                  ),
                  visible: isError,
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextField(
                  obscureText: false,
                  controller: user,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'User Name',
                  ),
                  onChanged: (newValue) {
                    setState(() {});
                    isError = false;
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextField(
                  obscureText: true,
                  controller: password,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                  onChanged: (newValue) {
                    setState(() {});
                    isError = false;
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
                child: ElevatedButton(
                  child: const Text('Submit'),
                  onPressed: authorization,
                  ),
                ),
            ],
          )
        )
    );
  }

  Future authorization() async {
    var data = {
      "userName": user.text,
      "password": password.text
    };
    String token = '';
    var url =
    Uri.http('localhost:8080', '/login');
    var response = await http.post(url, body: convert.jsonEncode(data));
    if(response.statusCode == 200) {
      token = convert.jsonDecode(response.body)['token'];
      api.token = token;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      Navigator.pop(context);
      (context as Element).reassemble();
    } else {
      isError = true;
      setState(() {});
    }
  }
}