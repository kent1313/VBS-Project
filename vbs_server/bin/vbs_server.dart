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

  app.get('${config.prefix}/groupNames', (Request request) async {
    final conn = await config.connectToDatabase();

    var results = await conn.execute('select * from tblGroup;');
    var data = [];
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
    //print(data);
    conn.close();
    return Response.ok(jsonEncode(data),
        //headers: {"Content-Type": "application/json"}
        );
  });

  app.get('${config.prefix}/kidNames', (Request request) async {
    final conn = await config.connectToDatabase();

    var results = await conn.execute('select k.*, g.groupName '
        'from tblKid k join tblGroup g on k.groupID = g.groupID;');
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

  app.get('${config.prefix}/kidSearch/<search>', (Request request, String search) async {
    final conn = await config.connectToDatabase();

    var results = await conn.execute('select k.*, g.groupName '
        'from tblKid k join tblGroup g on k.groupID = g.groupID;');
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

  app.get('${config.prefix}/getGroupName/<groupID>', (Request request, String groupID) async {
    final conn = await config.connectToDatabase();

    var results = await conn.execute('select * from tblGroup where groupID = :groupID;',
        {'groupID': int.parse(groupID)});
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

  app.get('${config.prefix}/kidNames/<groupID>', (Request request, String groupID) async {
    final conn = await config.connectToDatabase();

    var results = await conn.execute(
        'select * from tblKid where groupID = :groupID;',
        {'groupID': int.parse(groupID)});
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

  app.get('${config.prefix}/myKids', (Request request) async {
    final conn = await config.connectToDatabase();

    String user = (request.context["payload"]! as ContextPayload).user;
    var results = await conn.execute("select leaderID from tblUser where userName = :user", {"user": user});
    int leaderID = results.rows.first.typedAssoc()["leaderID"];
    results = await conn.execute("select groupID from tblLeader where leaderID = :leader", {"leader": leaderID});
    int groupID = results.rows.first.typedAssoc()["groupID"];

    results = await conn.execute(
        'select * from tblKid where groupID = :groupID;',
        {'groupID': groupID});
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

  app.get('${config.prefix}/group/<groupID>/<date>',
      (Request request, String groupID, date) async {
    final conn = await config.connectToDatabase();

    var results1 = await conn.execute(
        "select * from tblGroup where groupID = :groupID;",
        {'groupID': int.parse(groupID)});
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
        "'Y' end as here,a.today,a.verse, a.visitors, a.leaderID "
        "from tblKid k left outer join tblAttendance a on k.kidID = a.kidID "
        "and a.today = :today where k.groupID = :groupID",
        {'groupID': int.parse(groupID), 'today': date});
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

  app.post('${config.prefix}/updateAttendance', (Request request) async {
    final body = await request.readAsString();
    final conn = await config.connectToDatabase();

    var attendance = Attendance.fromJSONObject(jsonDecode(body));

    if(attendance.here == false) {
      var action = await conn.execute(
        "delete from tblAttendance where kidID = :kidID and today = :today",
          {'kidID': attendance.kidID, 'today': attendance.today});
    } else {
      String verse;
      if(attendance.verse == true) {
        verse = 'Y';
      } else {
        verse = 'N';
      }
      int? visitors;
      if(attendance.visitors == null) {
        visitors = 0;
      } else {
        visitors = attendance.visitors;
      }

      var execution = await conn.execute("select count(*) rowCount from tblAttendance"
          " where kidID = :kidID and today = :today;",
          {'kidID': attendance.kidID, 'today': attendance.today});
      print('DB-response: ${execution.rows.first.typedAssoc()["rowCount"]}');
      if(execution.rows.first.typedAssoc()["rowCount"] == 0) {
        var action = await conn.execute(
            "insert into tblAttendance (today, kidID, verse, visitors, leaderID)"
                "values (:today, :kidID, :verse, :visitors, 2);",
            {
              'kidID': attendance.kidID,
              'today': attendance.today,
              'verse': verse,
              'visitors': visitors,
            });
        print("action = $action");
      } else {
        var action1 = await conn.execute("update tblAttendance set verse = :verse"
            " where kidID = :kidID and today = :today;",
            {'kidID': attendance.kidID, 'today': attendance.today, 'verse': verse});
        var action2 = await conn.execute("update tblAttendance set visitors = :visitors"
            " where kidID = :kidID and today = :today;",
            {'kidID': attendance.kidID, 'today': attendance.today, 'visitors': visitors});
      }
    }
    conn.close();
    return Response.ok('hello-world');
  });

  app.get('${config.prefix}/getFamily/<familyID>', (Request request, String familyIDString) async {
    final body = await request.readAsString();
    final conn = await config.connectToDatabase();

    int familyID = int.parse(familyIDString);

    IResultSet result = await conn.execute("select * from tblFamily where familyID = :familyID", {"familyID": familyID});
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
    result = await conn.execute("select * from tblKid where familyID = :familyID", {"familyID": familyID});
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
  app.post('${config.prefix}/addKid', (Request request) async {
    final body = await request.readAsString();
    final conn = await config.connectToDatabase();

    var data = jsonDecode(body);
    List<Kid> kids = [];
    for(var kid in data["kids"]) {
      kids.add(Kid.fromJSONObject(kid));
    }
    Family family = Family.fromJSONObect(data["family"]);

    // figure out the family name...
    List<String> lastNames = [];
    for(var kid in kids) {
      if(kid.lastName != null && kid.lastName!.isNotEmpty && !lastNames.contains(kid.lastName)) {
        lastNames.add(kid.lastName!);
      }
    }
    family.familyName = lastNames.join(",");

    // insert / update the family
    if(family.id <= 0) {
      IResultSet result = await conn.execute("insert into tblFamily (familyName, parentName, address, phone, email)"
          "values (:familyName, :parentName, :address, :phone, :email);",
          {
            'familyName': family.familyName,
            "parentName": family.parentName,
            'address': family.address,
            'phone': family.phone,
            'email': family.email,
          }
      );
      family.id = result.lastInsertID.toInt();
    } else {
      IResultSet result = await conn.execute("update tblFamily set familyName = :familyName, parentName = :parentName, address = :address, phone = :phone, email = :email where familyID = :familyID",
          {
            'familyID': family.id,
            'familyName': family.familyName,
            "parentName": family.parentName,
            'address': family.address,
            'phone': family.phone,
            'email': family.email,
          }
      );
    }

    for(var kid in kids) {
      // insert / update
      if(kid.kidID == null || kid.kidID! <= 0) {
        IResultSet result = await conn.execute(
            "insert into tblKid (familyID, grade, firstName, lastName, groupID, age)"
                "values (:familyID, :grade, :firstName, :lastName, :groupID, :age);",
            {
              'familyID': family.id,
              'grade': kid.grade,
              'firstName': kid.firstName,
              'lastName': kid.lastName,
              'groupID': kid.groupID,
              'age': kid.age,
            }
        );
        kid.kidID = result.lastInsertID.toInt();
      } else {
        IResultSet result = await conn.execute("update tblKid set familyID = :familyID, firstName = :firstName, lastName = :lastName, groupID = :groupID, grade = :grade, age = :age where kidID = :kidID",
            {
              'familyID': family.id,
              'grade': kid.grade,
              'firstName': kid.firstName,
              'lastName': kid.lastName,
              'groupID': kid.groupID,
              'age': kid.age,
              'kidID': kid.kidID,
            }
        );
      }
    }
    
    List<Map<String, dynamic>> returnList = [];
    for(var kid in kids) {
      returnList.add(kid.toJSON());
    }
    var returnData = {
      "kids": returnList,
      "family": family.toJSON(),
    };

    conn.close();
    return Response.ok(jsonEncode(returnData));
  });

  app.post('${config.prefix}/addGroup', (Request request) async {
    final body = await request.readAsString();
    final conn = await config.connectToDatabase();

    var group = Group.fromJSONObject(jsonDecode(body));

      var execution = await conn.execute("insert into tblGroup (groupName, mainLeaderID)"
          "values (:groupName, :mainLeaderID)",
          {'groupName': group.groupName, 'mainLeaderID': group.mainLeaderID});

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