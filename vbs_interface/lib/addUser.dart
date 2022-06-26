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
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool hidePass = true;
  String pickAdmin = 'Set permissions';
  int? groupID;
  bool isUserLeaderLoaded = false;
  User? user;
  Leader? leader;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as UserScreenArgs;

    return Scaffold(
        appBar: AppBar(

          title: Text(widget.title),
        ),
        body: Center(
            child: FutureBuilder<ScreenData>(
              future: loadData(args),
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  final data = snapshot.data!;
                  final groups = data.groups;
                  return Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          CheckboxListTile(
                              title: const Text("User account for logging in"),
                              value: user != null,
                              onChanged: (newValue) {
                                if(newValue ?? false) {
                                  user = User();
                                } else {
                                  user = null;
                                }
                                setState((){});
                              }
                          ),
                          Visibility(
                            visible: user != null,
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
                                          if (value == null || value.isEmpty) {
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
                                                if (value == null || value.isEmpty) {
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
                                            if (hidePass) {
                                              hidePass = false;
                                            } else {
                                              hidePass = true;
                                            }
                                            setState(() {});
                                          },
                                          icon: hidePass
                                              ? const Icon(Icons.visibility)
                                              : const Icon(Icons.visibility_off),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
                                  SizedBox(
                                    width: 200,
                                    height: 50,
                                    child: Flexible(
                                      child: DropdownButtonFormField<String>(
                                        value: pickAdmin,
                                        validator: (value) {
                                          if (value == 'Set permissions') {
                                            return username.text.isEmpty
                                                ? 'Please set the permissions'
                                                : 'Please set the permissions for ${username
                                                .text}';
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
                                            .map<DropdownMenuItem<String>>((
                                            String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ]
                            ),
                          ),
                          CheckboxListTile(
                              title: const Text("Leader of a group"),
                              value: leader != null,
                              onChanged: (newValue) {
                                if(newValue ?? false) {
                                  leader = Leader();
                                } else {
                                  leader = null;
                                }
                                setState((){});
                              }
                          ),
                          Visibility(
                            visible: leader != null,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(10, 15, 50, 5),
                                    child: TextFormField(
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'First Name',
                                        ),
                                        controller: firstName,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a first name';
                                          }
                                          return null;
                                        },
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(25),
                                        ]
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(10, 15, 50, 5),
                                    child: TextFormField(
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Last Name',
                                        ),
                                        controller: lastName,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a last name';
                                          }
                                          return null;
                                        },
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(25),
                                        ]
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(10, 15, 50, 5),
                                    child: TextFormField(
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Email',
                                        ),
                                        controller: email,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(30),
                                        ]
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(10, 15, 50, 5),
                                    child: TextFormField(
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Phone',
                                        ),
                                        controller: phone,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                        ]
                                    ),
                                  ),
                                  Container(
                                      padding:
                                      const EdgeInsets.fromLTRB(
                                          10, 10, 20, 10),
                                      child: SizedBox(
                                        width: 200,
                                        height: 50,
                                        child: Flexible(
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
                                                    child: Text(
                                                        "${group.groupName ??
                                                            ""} "), //Text("${group.groupName ?? ""} (${group.memberCount})"),
                                                  );
                                                }).toList()
                                              ..add(const DropdownMenuItem(
                                                  child: Text(
                                                      "Pick a group")
                                              )
                                              ),
                                            validator: (value) {
                                              if (value == null) {
                                                return "Please select a group";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      )),
                                ],
                              )
                          ),
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
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              }
            )
        )
    );
  }

  createUser() async {
    if(leader != null) {
      leader!.firstName = firstName.text;
      leader!.lastName = lastName.text;
      leader!.email = email.text;
      if(phone.text.isEmpty) {
        leader!.phone = -1;
      } else {
        leader!.phone = int.parse(phone.text);
      }
      if(groupID != null) {
        leader!.groupID = groupID!;
      }
      await api.updateLeader(context, leader!);
    }
    if(user != null) {
      user!.userName = username.text;
      user!.password = password.text;
      if (pickAdmin == 'Leader') {
        user!.systemAdmin = 'N';
      }
      if (pickAdmin == 'Check-in') {
        user!.systemAdmin = 'S';
      }
      if (pickAdmin == 'Administrator') {
        user!.systemAdmin = 'Y';
      }
      if(leader != null) {
        // the updateLeader() will update the leaderID after inserting
        user!.leaderID = leader!.leaderID;
      }
      await api.updateUser(context, user!);
    }
  }

  Future<ScreenData> loadData(UserScreenArgs args) async {
    Future<List<Group>> groups = api.loadGroups(context);
    Future<Leader>? leader;
    Future<User>? user;
    if(!isUserLeaderLoaded && args.leaderID != null) {
      leader = api.getLeader(context, args.leaderID!);
    }
    if(!isUserLeaderLoaded && args.userID != null) {
      user = api.getUser(context, args.userID!);
    }

    if(leader != null) {
      this.leader = await leader;
      firstName.text = this.leader!.firstName;
      lastName.text = this.leader!.lastName;
      phone.text = this.leader!.phone.toString();
      email.text = this.leader!.email;
      groupID = this.leader!.groupID;
    }
    if(user != null) {
      this.user = await user;
      username.text = this.user!.userName;
      password.text = "*****";
      if(this.user!.systemAdmin == "N") {
        pickAdmin = "Leader";
      }
      if(this.user!.systemAdmin == "S") {
        pickAdmin = "Check-in";
      }
      if(this.user!.systemAdmin == "Y") {
        pickAdmin = "Administrator";
      }
    }

    isUserLeaderLoaded = true;

    return ScreenData(
        groups: await groups,
      leader: this.leader,
    );
  }
}

class ScreenData {
  List<Group> groups;
  Leader? leader;

  ScreenData({required this.groups, this.leader});
}

class UserScreenArgs {
  String? userID;
  int? leaderID;

  UserScreenArgs({this.userID, this.leaderID});
}