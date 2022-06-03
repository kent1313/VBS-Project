import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:vbs_shared/vbs_shared.dart';

import 'config.dart';

class SetupRoutes {
  static addRoutes(Router app) {
    app.post('/updateUser', (Request request) async {
      final body = await request.readAsString();
      final conn = await config.connectToDatabase();

      var user = User.fromJSONObject(jsonDecode(body));

      var action = await conn.execute(
          "select count(*) count from tblUser where userName = :user",
          {"user": user.userName});
      var systemAdmin = "N";
      if (user.systemAdmin) {
        systemAdmin = "Y";
      }
      if (action.rows.first.typedAssoc()["count"] == 0) {
        action = await conn.execute(
            "insert into tblUser (userName, password, leaderID, systemAdmin) values (:user, md(:password), :leaderID, :systemAdmin)",
            {
              "user": user.userName,
              "password": user.password,
              "leaderID": user.leaderID,
              "systemAdmin": systemAdmin
            });
      } else {
        action = await conn.execute(
            "update tblUser set leaderID = :leaderID, systemAdmin = :systemAdmin where userName = :user",
            {
              "user": user.userName,
              "leaderID": user.leaderID,
              "systemAdmin": systemAdmin
            });
        if (user.password.isNotEmpty) {
          action = await conn.execute(
              "user tblUser set password = md5(:password) where userName = :user",
              {"user": user.userName, "password": user.password});
        }
      }

      var data = {
      "userUpdated": user.userName,
      };
      return Response.ok(jsonEncode(data));

    });

  }
}