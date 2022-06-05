import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vbs_interface/addKid.dart';
import 'package:vbs_shared/vbs_shared.dart';
import 'package:http/http.dart' as http;
//https://stackoverflow.com/questions/57937280/how-can-i-detect-if-my-flutter-app-is-running-in-the-web
import 'package:flutter/foundation.dart' show kIsWeb;

final api = API();

class API {
  final ValueNotifier<String> _token = ValueNotifier<String>("");
  String admin = 'none';
  String hostName = "digitaleagle.net";
  String port = "443";
  String prefix = "lbcvbs";

  config() async {
    if (kIsWeb) {
      // running on the web! -- don't want to look for a host file!
    } else {
      var hostJsonFile = File("host.json");
      if(hostJsonFile.existsSync()) {
        var hostJson = jsonDecode(await hostJsonFile.readAsString());
        if(hostJson["host"] != null) {
          hostName = hostJson["host"];
        }
        if(hostJson["port"] != null) {
          port = hostJson["port"];
        }
        if(hostJson["prefix"] != null) {
          prefix = hostJson["prefix"];
        }
      }
    }
    if(prefix.isNotEmpty && !prefix.endsWith("/")) {
      prefix += "/";
    }

    // load the token from memory
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      api.token = "";
    } else {
      api.token = token;
    }
  }

  // ------------------------------------
  //    This is the main send message routine that everything goes through
  //     Note: login doesn't go through here yet, but it should
  // ------------------------------------
  Future <String> sendMessage({required BuildContext context,
    required String path,
    String method = 'get',
    String body  = ''}
    ) async {

    // load the token
    if(token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        api.token = "";
      } else {
        api.token = token;
      }
    }

    // make sure we don't get a double slash
    if(path.startsWith("/")) {
      path = path.substring(1);
    }

    late Uri url;
    if(hostName == "localhost") {
      url = Uri.http('$hostName:$port', "$prefix$path");
    } else {
      url = Uri.https('$hostName:$port', "$prefix$path");
    }
    print("Getting: $url");
    var response;
    if(method == 'get') {
      response = await http.get(url, headers: {'authorization': token});
    } else {
      response = await http.post(url, headers: {'authorization': token}, body: body);
    }
    print("  Returned: ${response.statusCode}");
    if(response.statusCode == 403) {
      // The await makes it hold until the login is complete,
      // then return the response
      await Navigator.pushNamed(context, '/login');
      return sendMessage(context: context, path: path, method: method, body: body);
    }
    if(response.statusCode == 500) {
      var errorMessage = "Unknown 500 Server Error";
      try {
        var json = jsonDecode(response.body);
        errorMessage = json["error"];
      } catch(e) {
        print("Server Error: ${response.body}");
      }
      throw Exception("Server Error: $errorMessage");
    }
    return response.body;
  }

  Future <List<Group>> loadGroups(context) async {
    var response = await sendMessage(context: context, path: '/groupNames');
    var groups = Group.fromJSONList(response);
    return groups;
  }

  Future <List<Group>> getGroupName(context, int groupID) async {
    var response = await sendMessage(context: context, path: '/getGroupName/$groupID');
    var groups = Group.fromJSONList(response);
    return groups;
  }

  Future<GroupData> loadKids(int groupID, context, Date today) async {
    var response = await sendMessage(context: context, path: '/group/$groupID/${today.makeString()}');
    var kids = GroupData.fromJSONObject(jsonDecode(response));
    return kids;
  }

  Future<List<Kid>> loadAllKids(context) async {
    var response = await sendMessage(context: context, path: '/kidNames');
    List<dynamic> jsonList = jsonDecode(response);
    List<Kid> list = [];
    for(var jsonKid in jsonList) {
      list.add(Kid.fromJSONObject(jsonKid));
    }
    return list;
  }

  Future<List<Kid>> loadSearchKids(context, String search) async {
    var response = await sendMessage(context: context, path: '/kidSearch/$search');
    List<dynamic> jsonList = jsonDecode(response);
    List<Kid> list = [];
    for(var jsonKid in jsonList) {
      list.add(Kid.fromJSONObject(jsonKid));
    }
    return list;
  }

  Future updateAttendance(context, Attendance attendance) async {
    var response = await sendMessage(
        context: context,
        method: 'post',
        path: 'updateAttendance',
        body: jsonEncode(attendance.toJSON())
    );
  }

  Future addGroup(context, Group group) async {
    var response = await sendMessage(
        context: context,
        method: 'post',
        path: 'addGroup',
        body: jsonEncode(group.toJSON())
    );
  }
  Future<FamilyResult> loadFamily(context, int familyID) async {
    var response = await sendMessage(context: context, path: "getFamily/$familyID");
    var data = jsonDecode(response);
    FamilyResult result = FamilyResult();
    result.family = Family.fromJSONObect(data["family"]);
    result.members = [];
    for(var kid in data["members"]) {
      result.members!.add(Kid.fromJSONObject(kid));
    }
    return result;
  }
  Future saveKid(context, Family family, List<Kid> familyMembers) async {
    List<Map<String, dynamic>> list = [];
    for(var member in familyMembers) {
      list.add(member.toJSON());
    }
    var data = {
      "kids": list,
      "family": family.toJSON(),
    };
    var response = await sendMessage(
        context: context,
        method: 'post',
        path: 'addKid',
        body: jsonEncode(data),
    );
  }

  // ------------------------------------
  //  Token-related functions
  // ------------------------------------

  String get token {
    return _token.value;
  }

  set token(String newValue) {
    _token.value = newValue;
  }

  addTokenListener(newListener) {
    _token.addListener(newListener);
  }

  removeTokenListener(listener) {
    _token.removeListener(listener);
  }

  get isLoggedIn {
    if(_token.value.isEmpty) {
      return false;
    } else {
      return true;
    }
  }
}

class Date {
  late int year;
  late int month;
  late int day;

  Date({required this.year, required this.month, required this.day});

  String makeString() {
    return '${year.toString()}-${month.toString()}-${day.toString()}';
  }

  Date.today() {
    var now = DateTime.now();
    year = now.year;
    month = now.month;
    day = now.day;
  }
}