import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vbs_shared/vbs_shared.dart';
import 'authorizationData.dart';

class userConfiguration extends StatefulWidget {
  const userConfiguration({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<userConfiguration> createState() => _userConfigurationState();
}

class _userConfigurationState extends State<userConfiguration> {
  int selectedIndex = 0;
  TextEditingController search = TextEditingController();

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
                  decoration: InputDecoration(
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
                child: FutureBuilder<Map<String, dynamic>> (
                    future: loadSearch(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return SingleChildScrollView(
                          child: Wrap(
                            direction: Axis.horizontal,
                            children: snapshot.data!["allLeaders"]["groups"].map<Widget>((group)=>LeaderByGroupCard(group)).toList() ,
                          ),
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

  Future<Map<String, dynamic>> loadSearch() async {
    var data = <String, dynamic>{};
    data["allLeaders"] = await api.getAllLeaders(context);
    data["matches"] = [];
    if(search.text.isEmpty) {
      // data["allLeaders"] = await api.getAllLeaders(context);
    } else {
      // return await api.loadSearchKids(context,search.text);
      var searchText = search.text.toLowerCase();
      for(var leader in data["allLeaders"]["leaders"]) {
        var name = "${leader['firstName']} ${leader['lastName']}";
        if(name.toLowerCase().contains(searchText)) {
          data["matches"].add(UserLeaderMatch(name: name, leader: Leader.fromJSONObject(leader)));
        }
      }
    }
    return data;
  }
  submitSearch(newValue) {
    setState(() {

    });
  }
}

class LeaderByGroupCard extends StatelessWidget {
  Map<String, dynamic> group;
  LeaderByGroupCard(this.group);
  
  @override
  Widget build(BuildContext context) {
    return Card(
        child: SizedBox(
          width: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(
                          30),
                    ),
                    child: Text(group["name"],
                    style: TextStyle(fontSize: 20),),
                ),
              ),
              Column(
                children: group["leaders"].map<Widget>((leader) => ListTile(
                  title: Text("${leader["firstName"]} ${leader["lastName"]}"),
                )).toList(),
              ),
            ],
          ),
        )
    );
  }
  
}

class UserLeaderMatch {
  String name;
  Leader? leader;
  User? user;

  UserLeaderMatch({required this.name, this.leader, this.user});
}