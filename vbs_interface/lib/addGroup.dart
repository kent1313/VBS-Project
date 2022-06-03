import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:vbs_shared/vbs_shared.dart';
import 'authorizationData.dart';

class AddGroup extends StatefulWidget {
  const AddGroup({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<AddGroup> createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  TextEditingController groupName = TextEditingController();
  String message = '';
  bool badInput = false;
  String mainLeader = 'Pick a Primary Leader';

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
            child: Column(
                children: [
                  Visibility(
                    child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
                        child: Text(
                          message, style: const TextStyle(color: Colors.red,),)
                    ),
                    visible: badInput,
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 15, 10, 5),
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Group Name',
                      ),
                      controller: groupName,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(
                            r'[A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,'
                            r'a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z, ]'))
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 10, 20),
                        child: DropdownButton<String>(
                          value: mainLeader,
                          icon: const Icon(Icons.arrow_downward),
                          onChanged: (String? newValue) {
                            setState(() {
                              mainLeader = newValue!;
                            });
                          },
                          items: [
                            'Pick a Primary Leader',
                            'Cucumber',
                            'Tomato',
                            'Carrot',
                            'Nezzer'
                          ]
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
                    ),
                  ),
                  ElevatedButton(
                      onPressed: createKid,
                      child: const Text('Submit')
                  ),
                ]
            )
        )
    );
  }

  createKid() {
    if (groupName.text == '') {
      badInput = true;
      message = 'Each group must have a name';
      setState(() {});
    } else {
      if (mainLeader == 'Pick a Primary Leader') {
        badInput = true;
        message = 'Each group must have a primary leader';
        setState(() {});
      }
    }
  }
}