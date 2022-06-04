import 'dart:convert';
import 'dart:io';

import 'package:mysql_client/mysql_client.dart';

final Config config = Config();

class Config {
  String host = "";
  String userName = "";
  int port = 0;
  String password = "";
  String databaseName = "";
  String jwtSecret = "";
  String jwtIssuer = "";
  String jwtAudience = "";
  String prefix = "";

  load() async {
    var contents = await File("secrets.json").readAsString();

    var settings = jsonDecode(contents);
    host = settings["host"];
    port = settings["port"];
    userName = settings["userName"];
    password = settings["password"];
    databaseName = settings["databaseName"];
    jwtSecret = settings["jwt_secret"];
    jwtIssuer = settings["jwt_issuer"];
    jwtAudience = settings["jwp_audience"];
    if(settings["prefix"] != null) {
      prefix = settings["prefix"];
    }
  }

  Future<MySQLConnection> connectToDatabase() async {
    final conn = await MySQLConnection.createConnection(
      host: host,
      port: port,
      userName: userName,
      password: password,
      databaseName: databaseName,
      // https://github.com/zim32/mysql.dart/issues/16
      secure: false,
    );

    await conn.connect();

    return conn;
  }
}