import 'dart:convert';

import 'package:mysql_client/mysql_client.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:vbs_shared/vbs_shared.dart';

import 'config.dart';

class SetupRoutes {
  /*
     -------------------------------------
       Insert / Update the users
     -------------------------------------
   */
  static addRoutes(Router app) {
    app.post('${config.prefix}/updateUser', (Request request) async {
      final body = await request.readAsString();
      final conn = await config.connectToDatabase();

      var user = User.fromJSONObject(jsonDecode(body));

      var action = await conn.execute(
          "select count(*) count from tblUser where userName = :user",
          {"user": user.userName});
      if (action.rows.first.typedAssoc()["count"] == 0) {
        action = await conn.execute(
            "insert into tblUser (userName, password, leaderID, systemAdmin) values (:user, md5(:password), :leaderID, :systemAdmin)",
            {
              "user": user.userName,
              "password": user.password,
              "leaderID": user.leaderID,
              "systemAdmin": user.systemAdmin
            });
      } else {
        action = await conn.execute(
            "update tblUser set leaderID = :leaderID, systemAdmin = :systemAdmin where userName = :user",
            {
              "user": user.userName,
              "leaderID": user.leaderID,
              "systemAdmin": user.systemAdmin
            });
        if (user.password.isNotEmpty) {
          action = await conn.execute(
              "update tblUser set password = md5(:password) where userName = :user",
              {"user": user.userName, "password": user.password});
        }
      }

      conn.close();
      var data = {
        "userUpdated": user.userName,
      };
      return Response.ok(jsonEncode(data));
    });

    /*
     -------------------------------------
       Insert / Update leaders
     -------------------------------------
     */
    app.post('${config.prefix}/updateLeader', (Request request) async {
      final body = await request.readAsString();
      final conn = await config.connectToDatabase();

      var leader = Leader.fromJSONObject(jsonDecode(body));

      var rowsUpdated = 0;
      var rowsInserted = 0;
      if (leader.leaderID <= 0) {
        IResultSet action = await conn.execute(
            "insert into tblLeader (firstName, lastName, email, phone, groupID) values (:firstName, :lastName, :email, :phone, :groupID)",
            {
              "firstName": leader.firstName,
              "lastName": leader.lastName,
              "email": leader.email,
              "phone": leader.phone,
              "groupID": leader.groupID
            });
        leader.leaderID = action.lastInsertID.toInt();
        rowsInserted = action.affectedRows.toInt();
      } else {
        var action = await conn.execute(
            "update tblLeader set firstName = :firstName, lastName = :lastName, email = :email, phone = :phone, groupID = :groupID where leaderID = :leaderID",
            {
              "leaderID": leader.leaderID,
              "firstName": leader.firstName,
              "lastName": leader.lastName,
              "email": leader.email,
              "phone": leader.phone,
              "groupID": leader.groupID
            });
        rowsUpdated = action.affectedRows.toInt();
      }
      var data = {
        "leaderUpdated": leader.leaderID,
        "rowsUpdated": rowsUpdated,
        "rowsInserted": rowsInserted,
      };
      conn.close();
      return Response.ok(jsonEncode(data));
    });

    /*
     -------------------------------------
       Insert / Update leaders
     -------------------------------------
     */
    app.get('${config.prefix}/getLeaders', (Request request) async {
      final body = await request.readAsString();
      final conn = await config.connectToDatabase();

      Map<int, Leader> leaderMap = {};
      List<Leader> leaders = [];
      IResultSet result = await conn.execute("select * from tblLeader");
      for(var r in result.rows) {
        var row = r.typedAssoc();
        var leader = Leader();
        leader.leaderID = row["leaderID"];
        leader.email = row["email"];
        leader.firstName = row["firstName"];
        leader.lastName = row["lastName"];
        leader.phone = row["phone"];
        leader.groupID = row["groupID"];
        leaderMap[leader.leaderID] = leader;
        leaders.add(leader);
      }

      List<User> users = [];
      result = await conn.execute("select * from tblUser");
      for(var r in result.rows) {
        var row = r.typedAssoc();
        var user = User();
        user.userName = row["userName"];
        user.password = row["password"];
        user.leaderID = row["leaderID"];
        user.systemAdmin = row["systemAdmin"];
        users.add(user);
      }

      List<Map<String, dynamic>> groups = [];
      result = await conn.execute("select * from tblGroup");
      for(var r in result.rows) {
        var row = r.typedAssoc();
        var group = Group();
        group.groupID = row["groupID"];
        group.groupName = row["groupName"];
        group.mainLeaderID = row["mainLeaderID"];
        List<Leader> groupLeaders = [];
        for(var leader in leaders) {
          if(leader.groupID == group.groupID) {
            groupLeaders.add(leader);
          }
        }
        groups.add({
          "id": group.groupID,
          "name": group.groupName,
          "data": group.toJSON(),
          "leaders": groupLeaders.map((e) => e.toJSON()).toList(),
        });
      }
      List<Map<String, dynamic>> combo = [];
      for(var user in users) {
        Leader? leader;
        String name = user.userName;
        if(leaderMap.containsKey(user.leaderID)) {
          leader = leaderMap[user.leaderID];
          name = "${leader!.firstName} ${leader.lastName}";
          leaderMap.remove(user.leaderID);
        }
        combo.add({
          "name": name,
          "user": user.toJSON(),
          "leader": leader == null ? null : leader.toJSON(),
        });
      }
      for(var leader in leaderMap.values) {
        combo.add({
          "name": "${leader.firstName} ${leader.lastName}",
          "user": null,
          "leader": leader,
        });
      }

      var data = {
        "combo": combo,
        "leaders": leaders.map((e) => e.toJSON()).toList(),
        "users": leaders.map((e) => e.toJSON()).toList(),
        "groups": groups,
      };
      conn.close();
      return Response.ok(jsonEncode(data));
    });
  }
}