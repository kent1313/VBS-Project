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



  app.get('/hello', (Request request) {
    return Response.ok('hello-world');
  });

  app.get('/groupNames', (Request request) async {
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

  app.get('/kidNames', (Request request) async {
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

  app.get('/kidSearch/<search>', (Request request, String search) async {
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

  app.get('/getGroupName/<groupID>', (Request request, String groupID) async {
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

  app.get('/kidNames/<groupID>', (Request request, String groupID) async {
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

  app.get('/myKids', (Request request) async {
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

  app.get('/group/<groupID>/<date>',
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
        "select k.kidID, k.familyID, k.grade, k.firstName, k.lastName, k.groupID, "
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

  app.post('/updateAttendance', (Request request) async {
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
          " where kidID = kidID and today = :today;",
          {'kidID': attendance.kidID, 'today': attendance.today});
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

  app.post('/addKid', (Request request) async {
    final body = await request.readAsString();
    final conn = await config.connectToDatabase();

    var kid = Kid.fromJSONObject(jsonDecode(body));

    int? groupID;
    var getGroupID = await conn.execute(""
        "select groupID from tblGroup where groupName = :groupName;",
    {'groupName': kid.groupName});

    for (final row in getGroupID.rows) {
      groupID = row.typedAssoc()['groupID'];
    }

    var checkFamily = await conn.execute('select * from tblFamily where familyName = :familyName',
    {'familyName': kid.family!.familyName});

    if(checkFamily.rows.isEmpty) {
      int? familyID;
      var addFamily = await conn.execute(
          "insert into tblFamily (familyName, address, phone, email)"
              "values (:familyName, :address, :phone, :email);",
          {
            'familyName': kid.family!.familyName,
            'address': kid.family!.address,
            'phone': kid.family!.phone,
            'email': kid.family!.email,
          }
      );

      var getFamilyID = await conn.execute('select familyID from tblFamily where familyName = :familyName',
          {'familyName': kid.family!.familyName});

      for (final row in getFamilyID.rows) {
        familyID = row.typedAssoc()['familyID'];
      }

      var addKid = await conn.execute(
          "insert into tblKid (familyID, grade, firstName, lastName, groupID)"
              "values (:familyID, :grade, :firstName, :lastName, :groupID);",
          {
            'familyID': familyID,
            'grade': kid.grade,
            'firstName': kid.firstName,
            'lastName': kid.lastName,
            'groupID': groupID,
          }
      );
    } else {
      int? familyID;
      var getFamilyID = await conn.execute(""
          "select familyID from tblFamily where familyName = :familyName;",
          {'familyName': kid.family!.familyName});

      for (final row in getFamilyID.rows) {
        familyID = row.typedAssoc()['familyID'];
      }

      var addKid = await conn.execute(
          "insert into tblKid (familyID, grade, firstName, lastName, groupID)"
              "values (:familyID, :grade, :firstName, :lastName, :groupID);",
          {
            'familyID': familyID,
            'grade': kid.grade,
            'firstName': kid.firstName,
            'lastName': kid.lastName,
            'groupID': groupID,
          }
      );
    }

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

  config.load();
  var server = await io.serve(_handler, 'localhost', 8080);
}