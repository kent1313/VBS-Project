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

    var results = await conn.execute('select * from tblKid;');
    var data = [];
    for (final row in results.rows) {
      // print(row.colAt(0));
      // print(row.colByName("title"));
      var kid = Kid();
      kid.kidID = int.parse(row.colByName("kidID") ?? '0');
      kid.firstName = row.colByName("firstName");
      kid.lastName = row.colByName("lastName");
      kid.DOB = row.colByName('DOB');
      kid.groupID = int.parse(row.colByName("groupID") ?? '0');
      kid.familyID = int.parse(row.colByName("familyID") ?? '0');
      kid.grade = int.parse(row.colByName("grade") ?? '0');
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

    var results = await conn.execute('select * from tblKid;');
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
        kid.DOB = row.colByName('DOB');
        kid.groupID = int.parse(row.colByName("groupID") ?? '0');
        kid.familyID = int.parse(row.colByName("familyID") ?? '0');
        kid.grade = int.parse(row.colByName("grade") ?? '0');
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
      kid.DOB = row.colByName('DOB');
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
        "select k.kidID, k.familyID, k.DOB, k.grade, k.firstName, k.lastName, k.groupID, "
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
      attend.kid!.DOB = row.typedAssoc()['DOB'];
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

    print("attedance = ${attendance.toJSON()}");
    print("here = ${attendance.here}");
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
      var execution = await conn.execute("select count(*) rowCount from tblAttendance"
          " where kidID = kidID and today = :today;",
          {'kidID': attendance.kidID, 'today': attendance.today});
      if(execution.rows.first.typedAssoc()["rowCount"] == 0) {
        var action = await conn.execute(
            "insert into tblAttendance (today, kidID, verse, visitors, leaderID)"
                "values (:today, :kidID, :verse, 0, 2);",
            {
              'kidID': attendance.kidID,
              'today': attendance.today,
              'verse': verse
            });
        print("action = $action");
      } else {
        var action = await conn.execute("update tblAttendance set verse = :verse"
            " where kidID = :kidID and today = :today;",
            {'kidID': attendance.kidID, 'today': attendance.today, 'verse': verse});
      }
    }
    conn.close();
    return Response.ok('hello-world');
  });

  app.post('/addKid', (Request request) async {
    final body = await request.readAsString();
    final conn = await config.connectToDatabase();

    var kid = Kid.fromJSONObject(jsonDecode(body));
    print(kid);
    conn.close();
    return Response.ok('hello-world');
  });

  // Configure a pipeline that logs requests.
  final _handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_headersMiddleware)
      .addMiddleware(createMiddleware(requestHandler: AuthProvider.handle))
      .addHandler(app);

  config.load();
  var server = await io.serve(_handler, 'localhost', 8080);
}