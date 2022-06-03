import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:vbs_shared/vbs_shared.dart';
import 'authorizationData.dart';
import 'package:side_navigation/side_navigation.dart';

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addKid',);
        },
        child: Icon(Icons.person_add),
      ),
      body: Center(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: TextField(
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
                                var groupName = api.getGroupName(context, kid.groupID ?? 0);
                                return ListTile(
                                  leading: const Icon(Icons.account_circle),
                                  onTap: () {
                                    Navigator.pushNamed(context, '/editKid',);
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
    );
  }

  Future<List<Kid>> loadSearch() async {
    if(search.text.isEmpty) {
      if(list == null) {
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
    setState(() {

    });
  }
}