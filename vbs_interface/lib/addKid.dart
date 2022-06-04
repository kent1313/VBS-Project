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
  TextEditingController address = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  String message = '';
  bool badInput = false;
  String grade = 'Pick a grade';
  String familyName = 'Pick a family';
  Kid kid = Kid();
  Family family = Family();
  List<Group> groups = [];
  List<Kid> familyMembers = [];
  bool existingFamily = false;

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
        if(kid.family == null) {
          kid.family = Family();
        }
        groups = args.groups;
      }
      familyMembers.add(kid);
      family = kid.family!;
      setupTextControllers();
      setState(() {});
    });
  }

  setupTextControllers() {
    firstName = TextEditingController();
    lastName = TextEditingController();
    address = TextEditingController();
    phone = TextEditingController();
    email = TextEditingController();

    firstName.text = kid.firstName ?? "";
    lastName.text = kid.lastName ?? "";
    address.text = family.address;
    phone.text = family.phone;
    email.text = family.email;

    firstName.addListener(() {kid.firstName = firstName.text;});
    lastName.addListener(() {kid.lastName = lastName.text;});
    address.addListener(() {kid.family!.address = address.text;});
    phone.addListener(() {kid.family!.phone = phone.text;});
    email.addListener(() {kid.family!.email = email.text;});
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
          title: Text((firstName.text.isEmpty && lastName.text.isEmpty) || badInput == true ? "New Kid" : "Editing: ${firstName.text} ${lastName.text}"),
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
                Visibility(
                  visible: familyMembers.length == 1,
                  child: Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 20, 5, 5),
                          child: TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'First Name',
                            ),
                            controller: firstName,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(
                                  r'[A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,'
                                  r'a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,]'))
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(5, 20, 10, 5),
                          child: TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Last Name',
                            ),
                            controller: lastName,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(
                                  r'[A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,'
                                  r'a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,]'))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                  child: Visibility(
                    visible: familyMembers.length == 1,
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if(existingFamily) {
                              existingFamily = false;
                              setState(() {});
                            } else {
                              existingFamily = true;
                              setState(() {});
                            }
                          },
                          child: Text(existingFamily ? 'Create new family': 'Use existing family'),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                  child: TextField(
                    enabled: existingFamily ? false: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Address',
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(
                          r'[A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,'
                          r'a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z, ,1,2,3,4,5,6,7,8,9,0,.]'))
                    ],
                    controller: address,
                    maxLines: 4,
                  ),
                ),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 10, 5, 5),
                        child: TextField(
                          enabled: existingFamily ? false: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Phone',
                          ),
                          controller: phone,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(
                                r'[1,2,3,4,5,6,7,8,9,0]'))
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(5, 10, 10, 5),
                        child: TextField(
                          enabled: existingFamily ? false: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email',
                          ),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(
                                r'[a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z, '
                                r',1,2,3,4,5,6,7,8,9,0,.,!,@,#,$,%,^,&,*,(,),{,},[,],?,-,_,+,=,~]'))
                          ],
                          controller: email,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Visibility(
                      visible: familyMembers.length > 1,
                      child: Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: familyMembers.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(familyMembers[index].firstName ?? "no name"),
                                );
                              }
                          )
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Visibility(
                            visible: familyMembers.length > 1,
                            child: Row(
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(10, 20, 5, 5),
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
                                ),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(5, 20, 10, 5),
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
                                ),
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
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  onPressed: saveKid,
                                  child: const Text('Save')
                              ),
                              SizedBox(width: 10,),
                              ElevatedButton(
                                  onPressed: newFamilyMember,
                                  child: const Text('Add Family Member')
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
        ),
          )
        )
    );
  }

  saveKid() {
    int counter = 0;
    if(firstName.text == '' || firstName.text.length >= 25) {
      badInput = true;
      message = 'Each kid must have a valid first name';
      setState((){});
    } else {
      if(lastName.text == '' || lastName.text.length >= 25) {
        badInput = true;
        message = 'Each kid must have a valid last name';
        setState((){});
      } else {
        if(address.text == '' || address.text.length >= 45) {
          badInput = true;
          message = 'Each family must have a valid home address';
          setState((){});
        } else {
          if(phone.text == '' || phone.text.length != 9) {
            badInput = true;
            message = 'Each family must have a valid phone number';
            setState((){});
          } else {
            if(email.text == '' || email.text.length >= 30) {
              badInput = true;
              message = 'Each family must have a valid email address';
              setState((){});
            } else {
              Navigator.pop(context);
            }
          }
        }
      }
    }
  }

  newFamilyMember() {
    kid = Kid();
    kid.family = family;
    familyMembers.add(kid);
    setupTextControllers();
    setState((){});
  }
}