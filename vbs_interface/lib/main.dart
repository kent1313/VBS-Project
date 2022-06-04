import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'kids.dart';
import 'groups.dart';
import 'kidData.dart';
import 'login.dart';
import 'homePage.dart';
import 'kidConfiguration.dart';
import 'addKid.dart';
import 'addGroup.dart';
import 'users.dart';
import 'authorizationData.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VBS Admin',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      //home: const Groups(title: 'Groups'),

      initialRoute: "/homePage",
        routes: {
          "/homePage": (context) => const homePage(title: 'VBS'),
          "/kids": (context) => const Kids(title: 'Kids'),
          "/users": (context) => const userConfiguration(title: 'Users'),
          "/addGroup": (context) => const AddGroup(title: 'New Group'),
          "/kidData": (context) => const KidData(title: 'Check in'),
          "/groups": (context) => const Groups(title: 'Groups'),
          "/login": (context) => const Login(title: 'Login'),
          "/kidConfiguration": (context) => const kidConfiguration(title: 'Kids'),
          "/addKid": (context) => const AddKid(title: 'New Kid'),
        }
    );
  }
}