import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:vbs_interface/kids.dart';
import 'package:vbs_shared/vbs_shared.dart';
import 'authorizationData.dart';

class Groups extends StatefulWidget {
  const Groups({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/addGroup');
          },
          child: Icon(Icons.group_add),
        ),

        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: FutureBuilder<List<Group>> (
              future: api.loadGroups(context),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  //print(loadGroups());
                  return ListView.builder(
                      itemBuilder: (_, index) {
                        var group = snapshot.data![index];
                        var groupName = group.groupName;
                        return ListTile(
                          leading: Icon(Icons.group),
                          onTap: () {
                            var parm = KidParameter(group.groupID ?? 0);

                            Navigator.pushNamed(context, '/kids', arguments: parm
                            );
                          },
                          title: Text(groupName ?? 'No Name!!'),
                        );
                      },
                      itemCount: snapshot.data!.length
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
  }
}