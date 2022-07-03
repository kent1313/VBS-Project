import 'dart:convert';

import 'package:mysql_client/mysql_client.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:vbs_shared/vbs_shared.dart';

import 'config.dart';
import 'passwordAuthentication.dart';

class SetupRoutes {
  static addRoutes(Router app) {

    /*
     -------------------------------------
       Insert / Update the users
     -------------------------------------
   */
    insertUpdateUserRoute (Request request, String origUsername) async {
      final body = await request.readAsString();
      final conn = await config.connectToDatabase();
      final payload = request.context["payload"]! as ContextPayload;

      if(payload.admin != "full") {
        return Response(401, body: "You don't have access to update users");
      }

      var user = User.fromJSONObject(jsonDecode(body));

      if(payload.organizationID != -1) {
        user.organizationID = payload.organizationID;
      }

      int foundCount = 0;
      IResultSet action;
      if(origUsername.isNotEmpty) {
        action = await conn.execute(
            "select count(*) count from tblUser where userName = :user",
            {"user": origUsername});
        foundCount = action.rows.first.typedAssoc()["count"];
      } else {
        // This is a new user (original user is empty)
        action = await conn.execute(
            "select count(*) count from tblUser where userName = :user",
            {"user": user.userName});
        foundCount = action.rows.first.typedAssoc()["count"];
        if(foundCount > 0) {
          // the new user already exists
          var data = {
            "error": true,
            "message": "Username already exists, please pick a different one",
          };
          conn.close();
          return Response.ok(jsonEncode(data));
        }
      }
      if (foundCount == 0) {
        action = await conn.execute(
            "insert into tblUser (userName, password, leaderID, systemAdmin, organizationID) values (:user, md5(:password), :leaderID, :systemAdmin, :orgID)",
            {
              "user": user.userName,
              "password": user.password,
              "leaderID": user.leaderID,
              "systemAdmin": user.systemAdmin,
              "orgID": user.organizationID,
            });
      } else {
        action = await conn.execute(
            "update tblUser set userName = :user, leaderID = :leaderID, systemAdmin = :systemAdmin, organizationID = :orgID where userName = :originalUser",
            {
              "originalUser": origUsername,
              "user": user.userName,
              "leaderID": user.leaderID,
              "systemAdmin": user.systemAdmin,
              "orgID": user.organizationID,
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
    };
    app.post('${config.prefix}/updateUser', (Request request) async {
      return insertUpdateUserRoute(request, "");
    });
    app.post('${config.prefix}/updateUser/', (Request request) async {
      return insertUpdateUserRoute(request, "");
    });
    app.post('${config.prefix}/updateUser/<origUsername>', insertUpdateUserRoute);

    /*
     -------------------------------------
       Insert / Update leaders
     -------------------------------------
     */
    app.post('${config.prefix}/updateLeader', (Request request) async {
      final body = await request.readAsString();
      final conn = await config.connectToDatabase();
      final payload = request.context["payload"]! as ContextPayload;

      if(payload.admin != "full") {
        return Response(401, body: "You don't have access to update users");
      }

      var leader = Leader.fromJSONObject(jsonDecode(body));
      if(payload.organizationID != -1) {
        leader.organizationID = payload.organizationID;
      }

      var rowsUpdated = 0;
      var rowsInserted = 0;
      if (leader.leaderID <= 0) {
        IResultSet action = await conn.execute(
            "insert into tblLeader (firstName, lastName, email, phone, groupID, organizationID) values (:firstName, :lastName, :email, :phone, :groupID, :orgID)",
            {
              "firstName": leader.firstName,
              "lastName": leader.lastName,
              "email": leader.email,
              "phone": leader.phone,
              "groupID": leader.groupID,
              "orgID": leader.organizationID,
            });
        leader.leaderID = action.lastInsertID.toInt();
        rowsInserted = action.affectedRows.toInt();
      } else {
        var action = await conn.execute(
            "update tblLeader set firstName = :firstName, lastName = :lastName, email = :email, phone = :phone, groupID = :groupID, organizationID = :orgID where leaderID = :leaderID",
            {
              "leaderID": leader.leaderID,
              "firstName": leader.firstName,
              "lastName": leader.lastName,
              "email": leader.email,
              "phone": leader.phone,
              "groupID": leader.groupID,
              "orgID": leader.organizationID,
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
       Get Leader
     -------------------------------------
     */
    app.get('${config.prefix}/getLeader/<leaderID>', (Request request, String strLeaderID) async {
      final conn = await config.connectToDatabase();
      final payload = request.context["payload"]! as ContextPayload;

      int leaderID = int.parse(strLeaderID);

      IResultSet result = await conn.execute("select * from tblLeader where leaderID = :leaderID and (organizationID = :orgID or :orgID = -1)",
          {"leaderID": leaderID, "orgID": payload.organizationID});
      var row = result.rows.first.typedAssoc();
      var leader = Leader();
      leader.leaderID = row["leaderID"];
      leader.email = row["email"];
      leader.firstName = row["firstName"];
      leader.lastName = row["lastName"];
      leader.phone = row["phone"];
      leader.groupID = row["groupID"];
      
      result = await conn.execute("select * from tblUser where leaderID = :leaderID", {"leaderID": leader.leaderID});
      if(result.numOfRows > 0) {
        leader.associatedUser = result.rows.first.typedAssoc()["userName"];
      }

      conn.close();
      return Response.ok(jsonEncode(leader.toJSON()));
    });

    /*
     -------------------------------------
       Get User
     -------------------------------------
     */
    app.get('${config.prefix}/getUser/<userName>', (Request request, String userName) async {
      final conn = await config.connectToDatabase();
      final payload = request.context["payload"]! as ContextPayload;

      IResultSet result = await conn.execute("select * from tblUser where userName = :userName and (organizationID = :orgID or :orgID = -1)",
          {"userName": userName, "orgID": payload.organizationID});
      var row = result.rows.first.typedAssoc();
      var user = User();
      user.userName = row["userName"];
      // We only know the password hash, not the actual password, and we don't want to share it
      //user.password = row["password"];
      user.leaderID = row["leaderID"];
      user.systemAdmin = row["systemAdmin"];

      conn.close();
      return Response.ok(jsonEncode(user.toJSON()));
    });

      /*
     -------------------------------------
       List all the leaders
     -------------------------------------
     */
    app.get('${config.prefix}/getLeaders', (Request request) async {
      final conn = await config.connectToDatabase();
      final payload = request.context["payload"]! as ContextPayload;

      Map<int, Leader> leaderMap = {};
      List<Leader> leaders = [];
      IResultSet result = await conn.execute("select * from tblLeader where (organizationID = :orgID or :orgID = -1)", {"orgID": payload.organizationID});

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
      result = await conn.execute("select * from tblUser where (organizationID = :orgID or :orgID = -1)", {"orgID": payload.organizationID});
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
      result = await conn.execute("select * from tblGroup where (organizationID = :orgID or :orgID = -1)", {"orgID": payload.organizationID});
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
          "leader": leader.toJSON(),
        });
      }

      var data = {
        "combo": combo,
        "leaders": leaders.map((e) => e.toJSON()).toList(),
        "users": users.map((e) => e.toJSON()).toList(),
        "groups": groups,
      };
      conn.close();
      return Response.ok(jsonEncode(data));
    });
  }
}