/*import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

void main() async {
  var handler =
  const Pipeline().addMiddleware(logRequests()).addHandler(_echoRequest);

  var server = await shelf_io.serve(handler, 'localhost', 8080);

  // Enable content compression
  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');
}

Response _echoRequest(Request request) =>
    Response.ok('Request for "${request.url}"');*/

import 'dart:convert';

import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

//import 'package:mysql1/mysql1.dart';
import 'package:mysql_client/mysql_client.dart';
import 'config.dart';
import 'passwordAuthentication.dart';
import 'package:vbs_shared/vbs_shared.dart';

import 'setupRoutes.dart';

void main() async {
  var app = Router();

  Response addHeaders(Response response)  {
    return response.change(headers: {
      "Content-Type": "application/json",
    });
  }

  Middleware _headersMiddleware = createMiddleware(responseHandler: addHeaders);
  await config.load();
  print("Using prefix: ${config.prefix}");
  print("Database: ${config.databaseName}");

  // ---------------------------
  //  /groupNames
  // ---------------------------
  app.get('${config.prefix}/groupNames', (Request request) async {
    final conn = await config.connectToDatabase();
    int organizationID = (request.context["payload"]! as ContextPayload).organizationID;

    var now = DateTime.now();
    var today = "${now.year}-${now.month}-${now.day}";
    var herePart = "(select count(*) from tblAttendance a, tblKid k "
        "where a.today = :today and a.kidID = k.kidID "
        "and k.groupID = g.groupID "
        "and (a.organizationID = :orgID or :orgID = -1) "
        "and (k.organizationID = :orgID or :orgID = -1))";

    var results = await conn.execute('select *, '
        '(select count(*) from tblKid k where k.groupID = g.groupID'
        ' and (k.organizationID = :orgID or :orgID = -1)) cnt, '
        '$herePart here from tblGroup g '
        'where (g.organizationID = :orgID or :orgID = -1)',
        {"today": today, "orgID": organizationID});
    var data = [];
    for (final row in results.rows) {
      // print(row.colAt(0));
      // print(row.colByName("title"));
      var group = Group();
      group.groupID = int.parse(row.colByName("groupID") ?? '0');
      group.groupName = row.colByName("groupName");
      group.mainLeaderID = int.parse(row.colByName('mainLeaderID') ?? '0');
      group.memberCount = row.typedAssoc()["cnt"];
      group.hereCount = row.typedAssoc()["here"];
      // print all rows as Map<String, String>
      //print(row);
      data.add(group.toJSON());
    }
    //print(data);
    conn.close();
    return Response.ok(jsonEncode(data),
        //headers: {"Content-Type": "application/json"}
        );
  });

  // ---------------------------
  //  /kidNames
  // ---------------------------
  app.get('${config.prefix}/kidNames', (Request request) async {
    final conn = await config.connectToDatabase();
    int organizationID = (request.context["payload"]! as ContextPayload).organizationID;

    var results = await conn.execute('select k.*, g.groupName '
        'from tblKid k join tblGroup g on k.groupID = g.groupID '
        'where (k.organizationID = :orgID or :orgID = -1) '
        'and (g.organizationID = :orgID or :orgID = -1)',
    {"orgID": organizationID});
    var data = [];
    for (final row in results.rows) {
      // print(row.colAt(0));
      // print(row.colByName("title"));
      var kid = Kid();
      kid.kidID = int.parse(row.colByName("kidID") ?? '0');
      kid.firstName = row.colByName("firstName");
      kid.lastName = row.colByName("lastName");
      kid.groupID = int.parse(row.colByName("groupID") ?? '0');
      kid.familyID = int.parse(row.colByName("familyID") ?? '0');
      kid.grade = int.parse(row.colByName("grade") ?? '0');
      kid.groupName = row.colByName("groupName");
      kid.age = row.typedAssoc()["age"];
      // print all rows as Map<String, String>
      //print(row);
      data.add(kid.toJSON());
    }
    //print(data);
    conn.close();
    return Response.ok(jsonEncode(data),
        //headers: {"Content-Type": "application/json"}
        );
  });

  // ---------------------------
  //  /kidSearch/<search>
  // ---------------------------
  app.get('${config.prefix}/kidSearch/<search>', (Request request, String search) async {
    final conn = await config.connectToDatabase();
    int organizationID = (request.context["payload"]! as ContextPayload).organizationID;

    var results = await conn.execute('select k.*, g.groupName '
        'from tblKid k join tblGroup g on k.groupID = g.groupID'
        'and (k.organizationID = :orgID or :orgID = -1) '
        'and (g.organizationID = :orgID or :ordID = -1)',
    {"orgID": organizationID});
    var data = [];
    String first = '';
    String last = '';

      for (final row in results.rows) {
        // print(row.colAt(0));
        // print(row.colByName("title"));
        var kid = Kid();
        kid.kidID = int.parse(row.colByName("kidID") ?? '0');
        kid.firstName = row.colByName("firstName");
        kid.lastName = row.colByName("lastName");
        kid.groupID = int.parse(row.colByName("groupID") ?? '0');
        kid.familyID = int.parse(row.colByName("familyID") ?? '0');
        kid.grade = int.parse(row.colByName("grade") ?? '0');
        kid.groupName = row.colByName("groupName");
        kid.age = row.typedAssoc()["age"];

        if(kid.firstName!.length >= search.length) {
          if(kid.firstName!.toLowerCase().substring(0,search.length) == search.toLowerCase().substring(0,search.length)) {
            data.add(kid.toJSON());
          }
        }
        if(kid.lastName!.length >= search.length) {
          if(kid.lastName!.toLowerCase().substring(0,search.length) == search.toLowerCase().substring(0,search.length)) {
            data.add(kid.toJSON());
          }
        }
      }
    //print(data);
    conn.close();
    return Response.ok(jsonEncode(data),
      //headers: {"Content-Type": "application/json"}
    );
  });

  // ---------------------------
  //  /getGroupName/<groupID>
  // ---------------------------
  app.get('${config.prefix}/getGroupName/<groupID>', (Request request, String groupID) async {
    final conn = await config.connectToDatabase();
    int organizationID = (request.context["payload"]! as ContextPayload).organizationID;

    var results = await conn.execute('select * from tblGroup '
        'where groupID = :groupID '
        'and (organizationID = :orgID or :orgID = -1)',
        {'groupID': int.parse(groupID),
        "orgID": organizationID});
    var data = [];
    if(groupID == 0) {
      for (final row in results.rows) {
        // print(row.colAt(0));
        // print(row.colByName("title"));
        var group = Group();
        group.groupID = int.parse(row.colByName("groupID") ?? '0');
        group.groupName = 'No Group';
        group.mainLeaderID = int.parse(row.colByName('mainLeaderID') ?? '0');
        // print all rows as Map<String, String>
        //print(row);
        data.add(group.toJSON());
      }
    } else {
      for (final row in results.rows) {
        // print(row.colAt(0));
        // print(row.colByName("title"));
        var group = Group();
        group.groupID = int.parse(row.colByName("groupID") ?? '0');
        group.groupName = row.colByName("groupName");
        group.mainLeaderID = int.parse(row.colByName('mainLeaderID') ?? '0');
        // print all rows as Map<String, String>
        //print(row);
        data.add(group.toJSON());
      }
    }
    //print(data);
    conn.close();
    return Response.ok(jsonEncode(data),
      //headers: {"Content-Type": "application/json"}
    );
  });

  // ---------------------------
  //  /kidNames/<groupID>
  // ---------------------------
  app.get('${config.prefix}/kidNames/<groupID>', (Request request, String groupID) async {
    final conn = await config.connectToDatabase();
    int organizationID = (request.context["payload"]! as ContextPayload).organizationID;

    var results = await conn.execute(
        'select * from tblKid where groupID = :groupID '
            '(organizationID = :orgID or :orgID = -1)',
        {'groupID': int.parse(groupID),
        'orgID': organizationID});
    var data = [];
    for (final row in results.rows) {
      // print(row.colAt(0));
      // print(row.colByName("title"));
      var kid = Kid();
      kid.kidID = int.parse(row.colByName("kidID") ?? '0');
      kid.firstName = row.colByName("firstName");
      kid.lastName = row.colByName("lastName");
      kid.groupID = int.parse(row.colByName("groupID") ?? '0');
      kid.familyID = int.parse(row.colByName("familyID") ?? '0');
      kid.grade = int.parse(row.colByName("grade") ?? '0');
      // print all rows as Map<String, String>
      //print(row);
      data.add(kid.toJSON());
    }
    //print(data);
    conn.close();
    return Response.ok("$data",
        //headers: {"Content-Type": "application/json"}
        );
  });

  // ---------------------------
  //  /myKids
  // ---------------------------
  app.get('${config.prefix}/myKids', (Request request) async {
    final conn = await config.connectToDatabase();
    int organizationID = (request.context["payload"]! as ContextPayload).organizationID;

    String user = (request.context["payload"]! as ContextPayload).user;
    var results = await conn.execute("select leaderID from tblUser where userName = :user", {"user": user});
    int leaderID = results.rows.first.typedAssoc()["leaderID"];
    results = await conn.execute("select groupID from tblLeader where leaderID = :leader", {"leader": leaderID});
    int groupID = results.rows.first.typedAssoc()["groupID"];

    results = await conn.execute(
        'select * from tblKid where groupID = :groupID '
            'and (organizationID = :orgID or :orgID = -1)',
        {'groupID': groupID, "orgID": organizationID});
    var data = [];
    for (final row in results.rows) {
      // print(row.colAt(0));
      // print(row.colByName("title"));
      var kid = Kid();
      kid.kidID = int.parse(row.colByName("kidID") ?? '0');
      kid.firstName = row.colByName("firstName");
      kid.lastName = row.colByName("lastName");
      kid.groupID = int.parse(row.colByName("groupID") ?? '0');
      kid.familyID = int.parse(row.colByName("familyID") ?? '0');
      kid.grade = int.parse(row.colByName("grade") ?? '0');
      kid.age = row.typedAssoc()["age"];
      // print all rows as Map<String, String>
      //print(row);
      data.add(kid.toJSON());
    }
    //print(data);
    conn.close();
    return Response.ok("$data",
      //headers: {"Content-Type": "application/json"}
    );
  });

  // ---------------------------
  //  /group/<groupID>/<date>
  // ---------------------------
  app.get('${config.prefix}/group/<groupID>/<date>',
      (Request request, String groupID, date) async {
    final conn = await config.connectToDatabase();
    int organizationID = (request.context["payload"]! as ContextPayload).organizationID;

    var results1 = await conn.execute(
        "select * from tblGroup where groupID = :groupID "
            "and (organizationID = :orgID or :orgID = -1)",
        {'groupID': int.parse(groupID), "orgID": organizationID});
    var data = GroupData();
    if (results1.rows.length > 0) {
      var row = results1.rows.elementAt(0);
      data.group = Group();
      data.group!.groupID = int.parse(row.colByName("groupID") ?? '0');
      data.group!.groupName = row.colByName("groupName");
    }

    var results2 = await conn.execute(
        ""
        "select k.kidID, k.familyID, k.grade, k.firstName, k.lastName, k.groupID, k.age, "
        "case when a.today is null then 'N' else "
        "'Y' end as here,a.today,a.verse, a.visitors, a.leaderID, bible "
        "from tblKid k left outer join tblAttendance a on k.kidID = a.kidID "
        "and a.today = :today where k.groupID = :groupID "
            "and (k.organizationID = :orgID or :orgID = -1)",
        {'groupID': int.parse(groupID), 'today': date, 'orgID': organizationID});
    for (final row in results2.rows) {
      var attend = Attendance();
      attend.kid = Kid();

      attend.kid!.kidID = row.typedAssoc()['kidID'];
      attend.kid!.firstName = row.typedAssoc()['firstName'];
      attend.kid!.lastName = row.typedAssoc()['lastName'];
      attend.kid!.grade = row.typedAssoc()['grade'];
      attend.kid!.familyID = row.typedAssoc()['familyID'];
      attend.kid!.groupID = row.typedAssoc()['groupID'];
      attend.kid!.age = row.typedAssoc()['age'];

      //attend.verse = row.colByName["a.verse"];
      //print(row.colByName["a.verse"]);
      if (row.typedAssoc()["verse"] == "Y") {
        attend.verse = true;
      } else {
        attend.verse = false;
      }
      if (row.typedAssoc()["bible"] == "Y") {
        attend.bible = true;
      } else {
        attend.bible = false;
      }
      if (row.typedAssoc()['here'] == 'N') {
        attend.here = false;
        attend.today = null;
      } else {
        attend.today = row.typedAssoc()["today"];
        attend.here = true;
      }
      attend.kidID = row.typedAssoc()["kidID"];
      data.attendance.add(attend);
    }
    conn.close();
    return Response.ok(jsonEncode(data.toJSON()),
        //headers: {"Content-Type": "application/json"}
    );
  });

  // ---------------------------
  //  /updateAttendance
  // ---------------------------
  app.post('${config.prefix}/updateAttendance', (Request request) async {
    final body = await request.readAsString();
    final conn = await config.connectToDatabase();
    int organizationID = (request.context["payload"]! as ContextPayload).organizationID;

    var attendance = Attendance.fromJSONObject(jsonDecode(body));

    if(attendance.here == false) {
      var action = await conn.execute(
        "delete from tblAttendance where kidID = :kidID and today = :today "
            "and (organizationID = :orgID or :orgID = -1)",
          {'kidID': attendance.kidID, 'today': attendance.today, "orgID": organizationID});
    } else {
      String verse;
      String bible;
      if(attendance.verse == true) {
        verse = 'Y';
      } else {
        verse = 'N';
      }
      if(attendance.bible == true) {
        bible = 'Y';
      } else {
        bible = 'N';
      }
      int? visitors;
      if(attendance.visitors == null) {
        visitors = 0;
      } else {
        visitors = attendance.visitors;
      }

      var execution = await conn.execute("select count(*) rowCount from tblAttendance"
          " where kidID = :kidID and today = :today"
          " and (organizationID = :orgID or :orgID = -1)",
          {'kidID': attendance.kidID, 'today': attendance.today, "orgID": organizationID});
      print('DB-response: ${execution.rows.first.typedAssoc()["rowCount"]}');
      if(execution.rows.first.typedAssoc()["rowCount"] == 0) {
        var action = await conn.execute(
            "insert into tblAttendance (today, kidID, verse, visitors, leaderID, organizationID, bible)"
                "values (:today, :kidID, :verse, :visitors, 2, :orgID, :bible);",
            {
              'kidID': attendance.kidID,
              'today': attendance.today,
              'verse': verse,
              'visitors': visitors,
              'orgID': organizationID,
              'bible': bible,
            });
        print("action = $action");
      } else {
        var action1 = await conn.execute("update tblAttendance set verse = :verse"
            " where kidID = :kidID and today = :today "
            " and (organizationID = :orgID or :orgID = -1)",
            {'kidID': attendance.kidID, 'today': attendance.today, 'verse': verse, 'orgID': organizationID});
        var action2 = await conn.execute("update tblAttendance set visitors = :visitors"
            " where kidID = :kidID and today = :today "
            " and (organizationID = :orgID or :orgID = -1)",
            {'kidID': attendance.kidID, 'today': attendance.today, 'visitors': visitors, 'orgID': organizationID});
        var action3 = await conn.execute("update tblAttendance set bible = :bible"
            " where kidID = :kidID and today = :today "
            " and (organizationID = :orgID or :orgID = -1)",
            {'kidID': attendance.kidID, 'today': attendance.today, 'bible': bible, 'orgID': organizationID});
      }
    }
    conn.close();
    return Response.ok('hello-world');
  });

  // ---------------------------
  //  /addUser
  // ---------------------------
  app.post('${config.prefix}/addUser', (Request request) async {
    final body = await request.readAsString();
    final conn = await config.connectToDatabase();
    var user = User.fromJSONObject(jsonDecode(body));
    int orgID = (request.context["payload"]! as ContextPayload).organizationID;
    String username = user.userName;
    String password = user.password;
    String admin = user.systemAdmin;
    int leaderID = -1;
    if(admin == 'N') {
      //var addLeader = await conn.execute('insert into tblLeader');
      //This is where you add the user into the leader table.
    }
    var addUser = await conn.execute(
        "insert into tblUser (userName, password, leaderID, systemAdmin, organizationID)"
            "values (:username, :password, :leaderID, :admin, :orgID);",
        {
          'username': username,
          'password': password,
          'leaderID': null,
          'admin': admin,
          'orgID': orgID
        });

    conn.close();
    return Response.ok('hello-world');
  });

  // ---------------------------
  //  get the score
  // ---------------------------
  app.get('${config.prefix}/score', (Request request) async {
    final conn = await config.connectToDatabase();
    int orgID = (request.context["payload"]! as ContextPayload).organizationID;
    var getScore = await conn.execute(
        "select k.groupID, g.groupName, sum(1 + (case when bible = 'Y' then 1 else 0 end) + "
        "(case when verse = 'Y' then 1 else 0 end) + (case when visitors > 0 then 1 else 0 end)) "
        "total from tblAttendance a, tblKid k, tblGroup g where g.organizationID = :orgID and "
        "k.organizationID = :orgID and a.organizationID = :orgID and a.kidID = k.kidID and k.groupID = g.groupID "
        "group by k.groupID, g.groupName;",
      {'orgID': orgID});
    List<Object> score = [];
    for(var row in getScore.rows) {
      Group group = Group();
      var rowData = row.typedAssoc();
      group.groupID = rowData['groupID'];
      group.groupName = rowData['groupName'];
      group.score = int.parse(rowData['total']);
      score.add(group.toJSON());
    }
    conn.close();
    return Response.ok(jsonEncode(score));
  });

  // ---------------------------
  //  /getFamily/<familyID>
  // ---------------------------
  app.get('${config.prefix}/getFamily/<familyID>', (Request request, String familyIDString) async {
    final body = await request.readAsString();
    final conn = await config.connectToDatabase();
    int organizationID = (request.context["payload"]! as ContextPayload).organizationID;

    int familyID = int.parse(familyIDString);

    IResultSet result = await conn.execute("select * from tblFamily "
        "where familyID = :familyID "
        "and (organiationID = :orgID or :orgID = -1)",
        {"familyID": familyID, 'orgID': organizationID});
    Family family = Family();
    if(result.numOfRows > 0) {
      var row = result.rows.first.typedAssoc();
      family.id = row["familyID"];
      family.familyName = row["familyName"];
      family.parentName = row["parentName"];
      family.phone = row["phone"];
      family.email = row["email"];
      family.address = row["address"];
    }
    result = await conn.execute("select * from tblKid "
        "where familyID = :familyID "
        "and (organizationID = :orgID or :orgID = -1)",
        {"familyID": familyID, 'orgID': organizationID});
    List<Map<String, dynamic>> members = [];
    for(var row in result.rows) {
      Kid kid = Kid();
      kid.kidID = row.typedAssoc()['kidID'];
      kid.firstName = row.typedAssoc()['firstName'];
      kid.lastName = row.typedAssoc()['lastName'];
      kid.grade = row.typedAssoc()['grade'];
      kid.familyID = row.typedAssoc()['familyID'];
      kid.groupID = row.typedAssoc()['groupID'];
      kid.age = row.typedAssoc()['age'];
      members.add(kid.toJSON());
    }

    var data = {
      "family": family.toJSON(),
      "members": members
    };

    conn.close();
    return Response.ok(jsonEncode(data));
  });

  // ---------------------------
  //  /kidCount/<today>
  // ---------------------------
  app.get('${config.prefix}/kidCount/<today>', (Request request, String today) async {
    final conn = await config.connectToDatabase();
    int organizationID = (request.context["payload"]! as ContextPayload).organizationID;

    print('date: $today');
    var getKidCount = await conn.execute('select count(*) from tblKid where (organizationID = :orgID or :orgID = -1)', {'orgID': organizationID});
    int kids = getKidCount.rows.first.typedAssoc()["count(*)"];
    var getAttendanceCount = await conn.execute("select count(*) from tblAttendance "
        "where today = :today "
        "and (organizationID = :orgID or :orgID = -1)", {"today": today, 'orgID': organizationID});
    int here = getAttendanceCount.rows.first.typedAssoc()['count(*)'];

    KidCount kidCount = KidCount();
    kidCount.here = here;
    kidCount.kids = kids;

    conn.close();
    return Response.ok(jsonEncode(kidCount.toJSON()));
  });

  // ---------------------------
  //  /addKid
  // ---------------------------
  app.post('${config.prefix}/addKid', (Request request) async {
    try {
      final body = await request.readAsString();
      final conn = await config.connectToDatabase();
      int organizationID = (request.context["payload"]! as ContextPayload).organizationID;

      var data = jsonDecode(body);
      List<Kid> kids = [];
      for (var kid in data["kids"]) {
        kids.add(Kid.fromJSONObject(kid));
      }
      Family family = Family.fromJSONObect(data["family"]);

      // figure out the family name...
      List<String> lastNames = [];
      for (var kid in kids) {
        if (kid.lastName != null && kid.lastName!.isNotEmpty &&
            !lastNames.contains(kid.lastName)) {
          lastNames.add(kid.lastName!);
        }
      }
      family.familyName = lastNames.join(",");

      // insert / update the family
      if (family.id <= 0) {
        IResultSet result = await conn.execute(
            "insert into tblFamily (familyName, parentName, address, phone, email, organizationID)"
                "values (:familyName, :parentName, :address, :phone, :email, :orgID);",
            {
              'familyName': family.familyName,
              "parentName": family.parentName,
              'address': family.address,
              'phone': family.phone,
              'email': family.email,
              "orgID": organizationID
            }
        );
        family.id = result.lastInsertID.toInt();
      } else {
        IResultSet result = await conn.execute(
            "update tblFamily "
                "set familyName = :familyName, "
                "parentName = :parentName, "
                "address = :address, "
                "phone = :phone, "
                "email = :email "
                "where familyID = :familyID "
                "and (organizationID = :orgID or :orgID = -1)",
            {
              'familyID': family.id,
              'familyName': family.familyName,
              "parentName": family.parentName,
              'address': family.address,
              'phone': family.phone,
              'email': family.email,
              'orgID': organizationID,
            }
        );
      }

      for (var kid in kids) {
        // insert / update
        if (kid.kidID == null || kid.kidID! <= 0) {
          IResultSet result = await conn.execute(
              "insert into tblKid (familyID, grade, firstName, lastName, groupID, age, organizationID)"
                  "values (:familyID, :grade, :firstName, :lastName, :groupID, :age, :orgID);",
              {
                'familyID': family.id,
                'grade': kid.grade,
                'firstName': kid.firstName,
                'lastName': kid.lastName,
                'groupID': kid.groupID,
                'age': kid.age,
                'orgID': organizationID
              }
          );
          kid.kidID = result.lastInsertID.toInt();
        } else {
          IResultSet result = await conn.execute(
              "update tblKid set familyID = :familyID, firstName = :firstName, "
                  "lastName = :lastName, groupID = :groupID, grade = :grade, age = :age "
                  "where kidID = :kidID "
                  "and (organizationID = :orgID or :orgID = -1)",
              {
                'familyID': family.id,
                'grade': kid.grade,
                'firstName': kid.firstName,
                'lastName': kid.lastName,
                'groupID': kid.groupID,
                'age': kid.age,
                'kidID': kid.kidID,
                'orgID': organizationID,
              }
          );
        }
      }

      List<Map<String, dynamic>> returnList = [];
      for (var kid in kids) {
        returnList.add(kid.toJSON());
      }
      var returnData = {
        "kids": returnList,
        "family": family.toJSON(),
      };

      conn.close();
      return Response.ok(jsonEncode(returnData));
    } catch (e, stacktrace) {
      var data = {
        "error": e.toString(),
        "stack": stacktrace.toString(),
      };
      print("Error!! $e");
      print("  Stack: $stacktrace");
      return Response.internalServerError(body: jsonEncode(data));
    }
  });

  // ---------------------------
  //  /userInfo
  // ---------------------------
  app.get('${config.prefix}/userInfo', (Request request) async {
    final conn = await config.connectToDatabase();
    String username = (request.context["payload"]! as ContextPayload).user;
    int organizationID = (request.context["payload"]! as ContextPayload).organizationID;

    var getUserData = await conn.execute("select * from tblUser where username = :userName",
        {'userName': username});

    var data = []; //List of five factors in constant order: String userName, int leaderID, String admin, int groupID, String groupName

    for (final row in getUserData.rows) {
      int leaderID = row.typedAssoc()['leaderID'];
      String admin = row.typedAssoc()['systemAdmin'];
      data.add(username);
      data.add(leaderID);
      data.add(admin);
    }

    print('LeaderID = ${data[1]}');
    int groupID = -1;
    String groupName = '';
    if(data[1] > 0) {
      var getGroupID = await conn.execute(
          "select * from tblLeader where leaderID = :leaderID;",
          {'leaderID': data[1]});
      groupID = getGroupID.rows.first.typedAssoc()['groupID'];
      if(groupID > 0) {
        var getGroupName = await conn.execute(
            "select * from tblGroup where groupID = :groupID",
            {'groupID': groupID});
        if(getGroupName.numOfRows > 0) {
          groupName = getGroupName.rows.first.typedAssoc()['groupName'];
        }
      }
    }
    data.add(groupID);
    data.add(groupName);

    UserInfo userInfo = UserInfo();
    userInfo.userName = data[0];
    userInfo.leaderID = data[1];
    userInfo.admin = data[2];
    userInfo.groupID = data[3];
    userInfo.groupName = data[4];

    print('output: ${userInfo.toJSON()}');
    conn.close();
    return Response.ok(jsonEncode(userInfo.toJSON()));
  });

  // ---------------------------
  //  /addGroup
  // ---------------------------
  app.post('${config.prefix}/addGroup', (Request request) async {
    final body = await request.readAsString();
    final conn = await config.connectToDatabase();
    int organizationID = (request.context["payload"]! as ContextPayload).organizationID;

    var group = Group.fromJSONObject(jsonDecode(body));

      var execution = await conn.execute("insert into tblGroup (groupName, mainLeaderID, organizationID)"
          "values (:groupName, :mainLeaderID, :orgID)",
          {
            'groupName': group.groupName,
            'mainLeaderID': group.mainLeaderID,
            'orgID': organizationID,
          });

    conn.close();
    return Response.ok('hello-world');
  });

  SetupRoutes.addRoutes(app);

  // Configure a pipeline that logs requests.
  final _handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_headersMiddleware)
      .addMiddleware(AuthProvider.createMiddleware(requestHandler: AuthProvider.handle))
      .addHandler(app);

  print("Listening on localhost:8080");
  print("Started at ${DateTime.now()}");
  var server = await io.serve(_handler, 'localhost', 8080);
}