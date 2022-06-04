import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:vbs_shared/vbs_shared.dart';
import 'authorizationData.dart';
import 'kidData.dart';

class Kids extends StatefulWidget {
  const Kids({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<Kids> createState() => _KidsState();
}

class _KidsState extends State<Kids> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as KidParameter;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: FutureBuilder<GroupData> (
              future: api.loadKids(args.groupID, context, Date.today()),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  //print(loadGroups());
                  return ListView.builder(
                      itemBuilder: (_, index) {
                        var attendance = snapshot.data!.attendance[index];
                        var kidFirstNames = attendance.kid!.firstName;
                        var kidLastNames = attendance.kid!.lastName;
                        bool here = attendance.here ?? false;
                        return ListTile(
                          leading: Icon(Icons.account_circle),
                          onTap: () {
                            var parm = KidDataParameter(attendance: attendance);
                            Navigator.pushNamed(context, '/kidData', arguments: parm,
                            ).then((value) => setState(() {}));
                          },
                          title: Text(kidFirstNames.toString()),
                          subtitle: Text(kidLastNames.toString()),
                          trailing: here ? Icon(Icons.check): Icon(Icons.close),
                        );
                      },
                      itemCount: snapshot.data!.attendance.length
                  );
                } else {
                  if (snapshot.hasError) {
                    print('Error: ${snapshot.error}');
                    return Column(
                      children: [
                        Icon(Icons.error_outline,
                          color: Colors.red,
                          size: 60,),
                        Text("Error: ${snapshot.error}")
                      ],
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }
              }

          )

          ,

        )

    );
  }}

class KidParameter {
  final int groupID;

  KidParameter(this.groupID);
}