import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vbs_shared/vbs_shared.dart';
import 'authorizationData.dart';

class AddUser extends StatefulWidget {
  const AddUser({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool hidePass = true;
  String pickAdmin = 'Set permissions';
  int? groupID;

  @override
  Widget build(BuildContext context) {
    final groups = ModalRoute.of(context)!.settings.arguments as List<Group>; //This is a list of all the groups

    return Scaffold(
        appBar: AppBar(

          title: Text(widget.title),
        ),
        body: Center(
            child: Form(
              key: _formKey,
              child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 15, 50, 5),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                        ),
                        controller: username,
                        validator: (value) {
                          if(value == null || value.isEmpty) {
                            return 'Each user must have a username.';
                          }
                          return null;
                        },
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(20),
                          ]
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 15, 10, 5),
                      child: Row(
                        children: [
                          Flexible(
                            child: TextFormField(
                              obscureText: hidePass,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Password',
                                ),
                                controller: password,
                                validator: (value) {
                                  if(value == null || value.isEmpty) {
                                    return 'Each user must have a username.';
                                  }
                                  return null;
                                },
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(20),
                                ]
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                if(hidePass) {
                                  hidePass = false;
                                } else {
                                  hidePass = true;
                                }
                                setState(() {});
                              },
                              icon: hidePass ? const Icon(Icons.visibility): const Icon(Icons.visibility_off),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      width: 550,
                      child: Row(
                        //mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            child: Flexible(
                              child: DropdownButtonFormField<String>(
                                value: pickAdmin,
                                validator: (value) {
                                  if(value == 'Set permissions') {
                                    return username.text.isEmpty ? 'Please set the permissions': 'Please set the permissions for ${username.text}';
                                  }
                                  return null;
                                },
                                icon: const Icon(Icons.arrow_downward),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    pickAdmin = newValue!;
                                  });
                                },
                                items: [
                                  'Set permissions',
                                  'Leader',
                                  'Check-in',
                                  'Administrator',
                                ]
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: pickAdmin == 'Leader',
                              child: Expanded(
                                child: Container(
                                    padding:
                                    const EdgeInsets.fromLTRB(
                                        10, 10, 20, 10),
                                    child: DropdownButtonFormField<int>(
                                      value: groupID,
                                      icon: const Icon(
                                          Icons.arrow_downward),
                                      onChanged: (int? newValue) {
                                        setState(() {
                                          groupID = newValue;
                                        });
                                      },
                                      items: groups.map<
                                          DropdownMenuItem<int>>(
                                              (Group group) {
                                            return DropdownMenuItem<int>(
                                              value: group.groupID,
                                              child: Text("${group.groupName ?? ""} "), //Text("${group.groupName ?? ""} (${group.memberCount})"),
                                            );
                                          }).toList()
                                        ..add(const DropdownMenuItem(
                                            child: Text(
                                                "Pick a group")
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
                          ),
                          const SizedBox(width: 40,),
                          ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  createUser();
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text('Submit')
                          ),
                        ],
                      ),
                    ),
                  ]
              ),
            )
        )
    );
  }

  createUser() {
    User user = User();
    user.userName = username.text;
    user.password = password.text;
    if(pickAdmin == 'Leader') {
      user.systemAdmin = 'N';
    }
    if(pickAdmin == 'Check-in') {
      user.systemAdmin = 'S';
    }
    if(pickAdmin == 'Administrator') {
      user.systemAdmin = 'Y';
    }
    print('---- User: ${user.toJSON()}');
  }
}