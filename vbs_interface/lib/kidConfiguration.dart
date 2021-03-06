import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vbs_shared/vbs_shared.dart';
import 'authorizationData.dart';

class kidConfiguration extends StatefulWidget {
  const kidConfiguration({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<kidConfiguration> createState() => _kidConfigurationState();
}

class _kidConfigurationState extends State<kidConfiguration> {
  int selectedIndex = 0;
  TextEditingController search = TextEditingController();
  List<Kid>? list;

  List<Group>? groups;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.add, control: true):
        newButtonClick,
        const SingleActivator(LogicalKeyboardKey.keyN, control: true):
        newButtonClick,
      },
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: newButtonClick,
          child: Icon(Icons.person_add),
        ),
        body: Center(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: TextField(
                    autofocus: true,
                    controller: search,
                    onChanged: submitSearch,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search',
                      icon: Icon(Icons.search),
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(
                          r'[A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,'
                          r'a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z, ]'))
                    ],
                  ),
                ),
                Flexible(
                    child: FutureBuilder<List<Kid>> (
                        future: loadSearch(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            //print(loadGroups());
                            return ListView.builder (
                                itemBuilder: (_, index) {
                                  var kid = snapshot.data![index];
                                  var kidFirstNames = kid.firstName;
                                  var kidLastNames = kid.lastName;
                                  var groupName = kid.groupName;
                                  return ListTile(
                                    leading: const Icon(Icons.account_circle),
                                    onTap: () {
                                      // SKP -- changed to add kid so we only use 1 screen
                                      //  also added the kid argument
                                      /* if(api.admin == 'none') {
                                        permissionDenied1();
                                      } else { */
                                        Navigator.pushNamed(context, '/addKid', arguments: KidArguments(kid: kid, groups: groups!));
                                      //}
                                    },
                                    title: Text(kidFirstNames.toString()),
                                    subtitle: Text(kidLastNames.toString()),
                                    trailing: Text(groupName.toString()),
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

                    ),
                ),
              ],
            )
        ),
      ),
    );
  }

  Future permissionDenied1() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'You do not have permission to edit kids. Please check with an administrator to continue.'),
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

  Future permissionDenied2() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'You do not have permission to add kids. Please check with an administrator to continue.'),
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

  Future<List<Kid>> loadSearch() async {
    if(search.text.isEmpty) {
      if(groups == null || list == null) {
        groups = await api.loadGroups(context);
        list = await api.loadAllKids(context);
        return list!;
      } else {
        return list!;
      }
    } else {
      return await api.loadSearchKids(context,search.text);
    }
  }
  submitSearch(newValue) {
    print('State reset');
    setState(() {});
  }
  newButtonClick() {
    //if(api.admin == 'none') {
    //  permissionDenied2();
    //} else {
      Navigator.pushNamed(context, '/addKid', arguments: KidArguments(kid: Kid(), groups: groups!));
    //}
  }
}

// Creating a class to use to pass the kid from the
// search page to the add/edit kig page
class KidArguments {
  Kid kid;
  List<Group> groups;

  KidArguments({required this.kid, required this.groups});
}