import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:vbs_shared/vbs_shared.dart';
import 'authorizationData.dart';
import 'package:side_navigation/side_navigation.dart';
import 'kidData.dart';
import 'kids.dart';

class homePage extends StatefulWidget {
  const homePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Navigation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            Visibility(
              visible: api.admin == 'full',
              child: ListTile(
                leading: Icon(Icons.admin_panel_settings),
                title: Text('Users'),
                onTap: () {
                  if (api.admin == 'full') {
                    Navigator.pushNamed(context, '/users').then((value) => setState((){}));
                  } else {
                    permissionDenied();
                  }
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Kids'),
              onTap: () {
                Navigator.pushNamed(context, '/kidConfiguration').then((value) => setState((){}));
              },
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Groups'),
              onTap: () {
                Navigator.pushNamed(context, '/groups').then((value) => setState((){}));
              },
            ),
            LoginLogoutTile(),
            ListTile(
              leading: Icon(Icons.close),
              title: Text('Close'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: MainContent(),
    );
  }

  Future permissionDenied() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'You do not have permission to edit or create users. Please check with an administrator to continue.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class LoginLogoutTile extends StatefulWidget {
  @override
  State<LoginLogoutTile> createState() => _LoginLogoutTileState();
}

class _LoginLogoutTileState extends State<LoginLogoutTile> {

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: api.isLoggedIn ? Icon(Icons.logout) : Icon(Icons.login),
      title: api.isLoggedIn ? Text('Logout') : Text('Login'),
      onTap: () {
        if (api.isLoggedIn) {
          api.token = '';
          setState(() {});
          Navigator.pop(context);
        } else {
          setState(() {});
          Navigator.pushNamed(context, '/login').then((value) => setState((){}));
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    api.addTokenListener(listener);
  }

  @override
  void dispose() {
    // You have to remove the listener (kind of deteats the point of listening)
    // otherwise you get an error trying to call set state on a dead state
    api.removeTokenListener(listener);
    super.dispose();
  }

  void listener() {
    setState((){});
  }
}

class MainContent extends StatefulWidget {
  @override
  State<MainContent> createState() => _MainContent();
}

class _MainContent extends State<MainContent> {

  @override
  Widget build(BuildContext context) {
    String userType = '';
    if(api.admin == 'none') {
      userType = 'a leader';
    }
    if(api.admin == 'some') {
      userType = 'a check in helper';
    }
    if(api.admin == 'full') {
      userType = 'an administrator';
    }

    //String userName = api.userName.substring(0,1).toUpperCase() + api.userName.substring(1,api.userName.length);
    String userName = api.userName;
    return api.isLoggedIn ? Align(
      alignment: Alignment.center,
      child: api.admin == 'none' ? FutureBuilder<ScreenData> (
          future: loadGroupData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              //print(loadGroups());
              return Column(
                children: [
                  Text(
                    'Welcome, ${snapshot.data!.userInfo.userName!.substring(0,1).toUpperCase()}${snapshot.data!.userInfo.userName!.substring(1,snapshot.data!.userInfo.userName!.length)}',
                    style: const TextStyle(fontSize: 25),
                  ),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Group ${snapshot.data!.groupData.group!.groupName}', style: const TextStyle(fontSize: 25),),
                      const Text('  Quick Access', style: TextStyle(fontSize: 23, fontStyle: FontStyle.italic,),),
                    ],
                  ),
                  Flexible(
                    child: ListView.builder(
                        itemBuilder: (_, index) {
                          var attendance = snapshot.data!.groupData.attendance[index];
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
                        itemCount: snapshot.data!.groupData.attendance.length
                    ),
                  ),
                ],
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
      ):
      Column(
        children: [
          Text('Welcome! $userName', style: const TextStyle(fontSize: 25),),
          /*
          FutureBuilder(
            future: api.kidCount(context, Date.today().makeString()),
              builder: (context, snapshot) {
              if(snapshot.hasData) {
                return Column(
                  children: [
                    Text('Welcome! $userName', style: const TextStyle(fontSize: 25),),
                    Text('There are ${snapshot.data.}'),
                  ],
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          )

           */
        ],
      )
    ):
    Container(
      padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            const Text('You are currently logged out.', style: TextStyle(fontSize: 25),),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
              child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pushNamed(context, '/login');
        },
                  child: const Text('Log in here'),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    api.addTokenListener(listener);
  }

  @override
  void dispose() {
    // You have to remove the listener (kind of deteats the point of listening)
    // otherwise you get an error trying to call set state on a dead state
    api.removeTokenListener(listener);
    super.dispose();
  }

  void listener() {
    setState((){});
  }

  Future<ScreenData> loadGroupData() async {
    var userInfo = await api.getUserInfo(context);
    var groupData = await api.loadKids(userInfo.groupID!, context, Date.today());
    return ScreenData(userInfo, groupData);
  }
}

class ScreenData {
  UserInfo userInfo;
  GroupData groupData;

  ScreenData(this.userInfo, this.groupData);
}