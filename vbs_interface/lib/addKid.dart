import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vbs_interface/kidConfiguration.dart';
import 'package:vbs_shared/vbs_shared.dart';

class AddKid extends StatefulWidget {
  const AddKid({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<AddKid> createState() => _AddKidState();
}

class _AddKidState extends State<AddKid> {
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  String message = '';
  bool badInput = false;
  String grade = 'Pick a grade';
  String familyName = 'Pick a family';
  Kid kid = Kid();
  List<Group> groups = [];

  var grades = const [
    {"id": null, "label": "Pick a grade"},
    {"id": -1, "label": "Pre-K"},
    {"id": 0, "label": "Kindergarten"},
    {"id": 1, "label": "First Grade"},
    {"id": 2, "label": "Second Grade"},
    {"id": 3, "label": "Third Grade"},
    {"id": 4, "label": "Fourth Grade"},
    {"id": 5, "label": "Fifth Grade"},
    {"id": 6, "label": "Sixth Grade"},
  ];

  @override
  void initState() {
    super.initState();
    //  https://stackoverflow.com/questions/56262655/flutter-get-passed-arguments-from-navigator-in-widgets-states-initstate
    // future that allows us to access context. function is called inside the future
    // otherwise it would be skipped and args would return null
    Future.delayed(Duration.zero, () {
      KidArguments? args = ModalRoute.of(context)!.settings.arguments as KidArguments;
      if(args == null) {
        kid = Kid();
        // This won't work -- we have to always pass the KidArguments
        groups = [];
      } else {
        kid = args.kid;
        firstName.text = kid.firstName ?? "";
        lastName.text = kid.lastName ?? "";
        groups = args.groups;
      }
      print("Kid = ${kid.toJSON()}");
      setState(() {});
    });
  }

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
        body: Center(
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Visibility(
                    child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
                        child: Text(message, style: const TextStyle(color: Colors.red,),)
                    ),
                  visible: badInput,
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 15, 10, 5),
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'First Name',
                    ),
                    controller: firstName,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(
                          r'[A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,'
                          r'a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z, ]'))
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Last Name',
                    ),
                    controller: lastName,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(
                          r'[A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,'
                          r'a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z, ]'))
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 10, 20, 20),
                      child: DropdownButton<int> (
                        value: kid.groupID,
                        icon: const Icon(Icons.arrow_downward),
                        onChanged: (int? newValue) {
                          setState(() {
                            kid.groupID = newValue;
                          });
                        },
                        items: groups
                            .map<DropdownMenuItem<int>>((Group group) {
                          return DropdownMenuItem<int>(
                            value: group.groupID,
                            child: Text(group.groupName ?? ""),
                          );
                        }).toList()..add(DropdownMenuItem(child: Text("<Pick a group>"))),
                      )
                    ),
                    Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        child: DropdownButton<int?> (
                          value: kid.grade,
                          icon: const Icon(Icons.arrow_downward),
                          onChanged: (int? newValue) {
                            setState(() {
                              kid.grade = newValue!;
                            });
                          },
                          items: grades
                              .map<DropdownMenuItem<int?>>((var value) {
                            return DropdownMenuItem<int?>(
                              value: value["id"] as int?,
                              child: Text(value["label"]! as String),
                            );
                          }).toList(),
                        )
                    ),
                    Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 10, 20),
                        child: DropdownButton<String> (
                          value: familyName,
                          icon: const Icon(Icons.arrow_downward),
                          onChanged: (String? newValue) {
                            setState(() {
                              familyName = newValue!;
                            });
                          },
                          items: ['Pick a family', 'Cucumber','Tomato','Carrot','Nezzer']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
                    ),
                  ],
                ),
                ElevatedButton(
                    onPressed: saveKid,
                    child: const Text('Save')
                ),
              ]
        ),
          )
        )
    );
  }

  saveKid() {

  }
}