import 'dart:convert';

import 'package:mysql_client/mysql_client.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:vbs_shared/vbs_shared.dart';

import 'config.dart';

class SetupRoutes {
  static addRoutes(Router app) {
    app.post('${config.prefix}/updateUser', (Request request) async {
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
            "insert into tblUser (userName, password, leaderID, systemAdmin) values (:user, md5(:password), :leaderID, :systemAdmin)",
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
              "update tblUser set password = md5(:password) where userName = :user",
              {"user": user.userName, "password": user.password});
        }
      }

      var data = {
      "userUpdated": user.userName,
      };
      return Response.ok(jsonEncode(data));

    });

    app.post('${config.prefix}/updateLeader', (Request request) async {
      final body = await request.readAsString();
      final conn = await config.connectToDatabase();
      
      var leader = Leader.fromJSONObject(jsonDecode(body));

      var rowsUpdated = 0;
      var rowsInserted = 0;
      if(leader.leaderID <= 0) {
        IResultSet action = await conn.execute("insert into tblLeader (firstName, lastName, email, phone, groupID) values (:firstName, :lastName, :email, :phone, :groupID)",
        {"firstName": leader.firstName, "lastName": leader.lastName, "email": leader.email, "phone": leader.phone, "groupID": leader.groupID});
        leader.leaderID = action.lastInsertID.toInt();
        rowsInserted = action.affectedRows.toInt();
      } else {
        var action = await conn.execute("update tblLeader set firstName = :firstName, lastName = :lastName, email = :email, phone = :phone, groupID = :groupID where leaderID = :leaderID",
            {"leaderID": leader.leaderID, "firstName": leader.firstName, "lastName": leader.lastName, "email": leader.email, "phone": leader.phone, "groupID": leader.groupID});
        rowsUpdated = action.affectedRows.toInt();
      }
      var data = {
        "leaderUpdated": leader.leaderID,
        "rowsUpdated": rowsUpdated,
        "rowsInserted": rowsInserted,
      };
      return Response.ok(jsonEncode(data));
    });

  }
}