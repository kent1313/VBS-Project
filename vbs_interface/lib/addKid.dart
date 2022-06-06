import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vbs_interface/kidConfiguration.dart';
import 'package:vbs_shared/vbs_shared.dart';
import 'authorizationData.dart';

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
  TextEditingController age = TextEditingController();
  TextEditingController parentName = TextEditingController();
  late FocusNode firstNameFocusNode;
  String message = '';
  bool badInput = false;
  String grade = 'Pick a grade';
  String familyName = 'Pick a family';
  Kid kid = Kid();
  Family family = Family();
  List<Group> groups = [];
  List<Kid> familyMembers = [];
  bool existingFamily = false;
  KidArguments? screenArguments;
  bool familyLoaded = false;

  // for validation
  final _formKey = GlobalKey<FormState>();

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
    {"id": 7, "label": "Seventh Grade"},
  ];

  @override
  void initState() {
    super.initState();
    //  https://stackoverflow.com/questions/56262655/flutter-get-passed-arguments-from-navigator-in-widgets-states-initstate
    // future that allows us to access context. function is called inside the future
    // otherwise it would be skipped and args would return null
    /*  This doesn't work with the future ... the future gets called first ... causes strange errors
        moved to the build()
    Future.delayed(Duration.zero, () {
      KidArguments? args =
          ModalRoute.of(context)!.settings.arguments as KidArguments;
      if (args == null) {
        kid = Kid();
        // This won't work -- we have to always pass the KidArguments
        groups = [];
      } else {
        kid = args.kid;
        if (kid.family == null) {
          kid.family = Family();
          kid.family!.id = kid.familyID!;
        }
        groups = args.groups;
      }
      familyMembers.add(kid);
      family = kid.family!;
      setupTextControllers();
      setState(() {});
    });
         */
    firstNameFocusNode = FocusNode();
  }

  initScreenArguments() {
    if (screenArguments == null) {
      kid = Kid();
      // This won't work -- we have to always pass the KidArguments
      groups = [];
      throw Exception("This screen called without arguments.");
    } else {
      kid = screenArguments!.kid;
      if (kid.family == null) {
        kid.family = Family();
        kid.family!.id = kid.familyID ?? -1;
      }
      groups = screenArguments!.groups;
    }
    familyMembers.add(kid);
    family = kid.family!;
    setupTextControllers();
  }

  @override
  void dispose() {
    firstNameFocusNode.dispose();
    super.dispose();
  }

  setupTextControllers() {
    firstName = TextEditingController();
    lastName = TextEditingController();
    address = TextEditingController();
    phone = TextEditingController();
    email = TextEditingController();
    age = TextEditingController();
    parentName = TextEditingController();

    firstName.text = kid.firstName ?? "";
    lastName.text = kid.lastName ?? "";
    address.text = family.address;
    phone.text = family.phone;
    email.text = family.email;
    if(kid.age > 0) {
      age.text = kid.age.toString();
    }
    parentName.text = family.parentName;

    firstName.addListener(() {
      kid.firstName = firstName.text;
    });
    lastName.addListener(() {
      kid.lastName = lastName.text;
    });
    address.addListener(() {
      kid.family!.address = address.text;
    });
    phone.addListener(() {
      kid.family!.phone = phone.text;
    });
    email.addListener(() {
      kid.family!.email = email.text;
    });
    age.addListener(() {
      if (age.text.isEmpty) {
        kid.age = 0;
      } else {
        kid.age = int.parse(age.text);
      }
    });
    parentName.addListener(() {
      kid.family!.parentName = parentName.text;
    });
  }

  @override
  Widget build(BuildContext context) {

    // get the screen's arguments on the first build call
    if(screenArguments == null) {
      screenArguments = ModalRoute.of(context)!.settings.arguments as KidArguments;
      initScreenArguments();
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.add, control: true):
            newFamilyMember,
        const SingleActivator(LogicalKeyboardKey.keyN, control: true):
        newFamilyMember,
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): saveKid,
      },
      child: Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text((firstName.text.isEmpty && lastName.text.isEmpty) ||
                    badInput == true
                ? "New Kid"
                : "Editing: ${firstName.text} ${lastName.text}"),
          ),
          body: FutureBuilder<Object>(
            future: loadFamily(),
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                return Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(children: [
                      Visibility(
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
                            child: Text(
                              message,
                              style: const TextStyle(
                                color: Colors.red,
                              ),
                            )),
                        visible: message.isNotEmpty,
                      ),
                      Visibility(
                        visible: familyMembers.length == 1,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                    10, 20, 5, 5),
                                child: TextFormField(
                                  autofocus: true,
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter a first name!";
                                    }
                                    if (value.length > 25) {
                                      return "Please keep the name less than 25 characters";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                    5, 20, 10, 5),
                                child: TextFormField(
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter a last name!";
                                    }
                                    if (value.length > 25) {
                                      return "Please keep the name less than 25 characters";
                                    }
                                    return null;
                                  },
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
                                  if (existingFamily) {
                                    existingFamily = false;
                                    setState(() {});
                                  } else {
                                    existingFamily = true;
                                    setState(() {});
                                  }
                                },
                                child: Text(existingFamily
                                    ? 'Create new family'
                                    : 'Use existing family'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                        child: TextField(
                          enabled: existingFamily ? false : true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Parent\'s Name',
                          ),
                          controller: parentName
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                        child: TextField(
                          enabled: existingFamily ? false : true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Address',
                          ),
                          controller: address,
                          maxLines: 4,
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                  10, 10, 5, 5),
                              child: TextField(
                                enabled: existingFamily ? false : true,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Phone',
                                ),
                                controller: phone,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[1,2,3,4,5,6,7,8,9,0]'))
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                  5, 10, 10, 5),
                              child: TextField(
                                enabled: existingFamily ? false : true,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Email',
                                ),
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
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(),
                                          borderRadius: BorderRadius.circular(
                                              5),
                                        ),
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: familyMembers.length,
                                            itemBuilder: (context, index) {
                                              return ListTile(
                                                title: Text(
                                                    familyMembers[index]
                                                        .firstName ??
                                                        "no name"),
                                                onTap: () {
                                                  selectFamilyMember(familyMembers[index]);
                                                },
                                              );
                                            }),
                                      ),
                                    ),
                                    Positioned(
                                        left: 15,
                                        top: 1,
                                        child: Container(
                                          padding: EdgeInsets.only(bottom: 10,
                                              left: 10,
                                              right: 10),
                                          color: Colors.white,
                                          child: Text(
                                            'Family Members',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          ),
                                        )),
                                  ],
                                )),
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
                                          padding:
                                          const EdgeInsets.fromLTRB(
                                              10, 20, 5, 5),
                                          child: TextFormField(
                                            autofocus: true,
                                            focusNode: firstNameFocusNode,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: 'First Name',
                                            ),
                                            controller: firstName,
                                            inputFormatters: <
                                                TextInputFormatter>[
                                              FilteringTextInputFormatter
                                                  .allow(RegExp(
                                                  r'[A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,'
                                                  r'a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z, ]'))
                                            ],
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Please enter a first name!";
                                              }
                                              if (value.length > 25) {
                                                return "Please keep the name less than 25 characters";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          padding:
                                          const EdgeInsets.fromLTRB(
                                              5, 20, 10, 5),
                                          child: TextFormField(
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: 'Last Name',
                                            ),
                                            controller: lastName,
                                            inputFormatters: <
                                                TextInputFormatter>[
                                              FilteringTextInputFormatter
                                                  .allow(RegExp(
                                                  r'[A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,'
                                                  r'a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z, ]'))
                                            ],
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Please enter a last name!";
                                              }
                                              if (value.length > 25) {
                                                return "Please keep the name less than 25 characters";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                          padding:
                                          const EdgeInsets.fromLTRB(
                                              10, 10, 20, 20),
                                          child: DropdownButtonFormField<int>(
                                            value: kid.groupID,
                                            icon: const Icon(
                                                Icons.arrow_downward),
                                            onChanged: (int? newValue) {
                                              setState(() {
                                                kid.groupID = newValue;
                                              });
                                            },
                                            items: groups.map<
                                                DropdownMenuItem<int>>(
                                                    (Group group) {
                                                  return DropdownMenuItem<int>(
                                                    value: group.groupID,
                                                    child: Text("${group.groupName ?? ""} (${group.memberCount})"),
                                                  );
                                                }).toList()
                                              ..add(DropdownMenuItem(
                                                  child: Text(
                                                      "<Pick a group>")
                                              )
                                              ),
                                            validator: (value) {
                                              if(value == null) {
                                                return "Please select a group";
                                              }
                                              return null;
                                            },
                                          )),
                                    ),
                                    Expanded(
                                      child: Container(
                                          padding:
                                          const EdgeInsets.fromLTRB(
                                              20, 10, 20, 20),
                                          child: DropdownButtonFormField<int?>(
                                            value: kid.grade,
                                            icon: const Icon(
                                                Icons.arrow_downward),
                                            onChanged: (int? newValue) {
                                              setState(() {
                                                kid.grade = newValue!;
                                              });
                                            },
                                            items: grades.map<
                                                DropdownMenuItem<int?>>(
                                                    (var value) {
                                                  return DropdownMenuItem<int?>(
                                                    value: value["id"] as int?,
                                                    child: Text(
                                                        value["label"]! as String),
                                                  );
                                                }).toList(),
                                            validator: (value) {
                                              if(value == null) {
                                                return "Grade is required";
                                              }
                                              return null;
                                            },
                                          )),
                                    ),
                                    Flexible(
                                      child: Container(
                                        padding:
                                        const EdgeInsets.fromLTRB(
                                            10, 10, 5, 5),
                                        child: TextField(
                                          enabled: existingFamily
                                              ? false
                                              : true,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Age',
                                          ),
                                          controller: age,
                                          inputFormatters: <
                                              TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(
                                                    r'[1,2,3,4,5,6,7,8,9,0]'))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                        onPressed: saveKid,
                                        child: const Text('Save')),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    ElevatedButton(
                                        onPressed: newFamilyMember,
                                        child: const Text(
                                            'Add Family Member')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),
                );
              } else {
                return CircularProgressIndicator();
              }
            }
          )),
    );
  }

  saveKid() async {
    if (_formKey.currentState!.validate()) {
      try {
        badInput = false;
        message = "";
        await api.saveKid(context, family, familyMembers);
        Navigator.pop(context);
      } catch(e) {
        message = e.toString();
        badInput = true;
        setState((){});
      }
    }
  }

  newFamilyMember() {
    if (_formKey.currentState!.validate()) {
      kid = Kid();
      kid.family = family;
      familyMembers.add(kid);
      setupTextControllers();
      firstNameFocusNode.requestFocus();
      setState(() {});
    }
  }

  Future<FamilyResult> loadFamily() async {
    if(family.id == -1) {
      return FamilyResult();
    }
    if(familyLoaded) {
      var result = FamilyResult();
      result.family = family;
      result.members = familyMembers;
      return result;
    }
    var result = await api.loadFamily(context, family.id);
    familyLoaded = true;
    if(result.members!.length > 0) {
      kid = result.members![0];
    }
    familyMembers.clear();
    familyMembers.addAll(result.members!);
    family = result.family!;
    setupTextControllers();
    if(familyMembers.length > 1) {
      firstNameFocusNode.requestFocus();
    }
    return result;
  }

  void selectFamilyMember(Kid familyMember) {
    kid = familyMember;
    setupTextControllers();
    firstNameFocusNode.requestFocus();
    setState(() {});
  }
}

class FamilyResult {
  Family? family;
  List<Kid>? members;
}
