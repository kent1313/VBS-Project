library vbs_shared;
import 'dart:convert';

class Group {
  int? groupID;
  String? groupName;
  int? mainLeaderID;
  int? memberCount;
  int? hereCount;
  int? score;

  Object toJSON() {
    Object obj = {
      'groupID': groupID,
      'groupName': groupName,
      'mainLeaderID': mainLeaderID,
      'memberCount': memberCount,
      'hereCount': hereCount,
      'score': score,
    };
    return obj;
  }

  static Group fromJSON(String json) {
    var obj = jsonDecode(json);
    return fromJSONObject(obj);
  }

  static Group fromJSONObject(Map<String,dynamic> obj) {
    var group = Group();
    group.groupID = obj["groupID"];
    group.groupName = obj["groupName"];
    group.mainLeaderID = obj["mainLeaderID"];
    group.memberCount = obj["memberCount"];
    group.hereCount = obj["hereCount"];
    group.score = obj["score"];
    return group;
  }

  static List<Group> fromJSONList(String json) {
    List<Group> groups = [];
    List<dynamic> objs = jsonDecode(json);
    for(var obj in objs) {
      var group = fromJSONObject(obj);
      groups.add(group);
    }
    return groups;
  }
}

class Kid {
  int? kidID;
  String? firstName;
  String? lastName;
  int? grade;
  int? familyID;
  Family? family;
  int? groupID;
  String? groupName;
  int age = 0;

  Map<String, dynamic> toJSON() {
    return {
      'kidID': kidID,
      'firstName': firstName,
      'lastName': lastName,
      'groupID': groupID,
      'grade': grade,
      'familyID': familyID,
      'family': family == null ? null : family!.toJSON(),
      'groupName': groupName,
      'age': age,
    };
  }

  static Kid fromJSON(String json) {
    var obj = jsonDecode(json);
    return fromJSONObject(obj);
  }

  static Kid fromJSONObject(Map<String,dynamic> obj) {
    var kid = Kid();
    kid.groupID = obj["groupID"];
    kid.firstName = obj["firstName"];
    kid.lastName = obj["lastName"];
    kid.grade = obj["grade"];
    kid.familyID = obj["familyID"];
    kid.groupName = obj["groupName"];
    if(obj["family"] != null) {
      kid.family = Family.fromJSONObect(obj["family"]);
    }
    kid.kidID = obj["kidID"];
    kid.age = obj["age"];
    return kid;
  }

  static List<Kid> fromJSONList(String json) {
    List<Kid> kids = [];
    List<dynamic> objs = jsonDecode(json);
    for(var obj in objs) {
      var kid = fromJSONObject(obj);
      kids.add(kid);
    }
    return kids;
  }
}

class KidCount {
  int? here;
  int? kids;


  Map<String, dynamic> toJSON() {
    return {
      'here': here,
      'kids': kids,
    };
  }

  static KidCount fromJSON(String json) {
    var obj = jsonDecode(json);
    return fromJSONObject(obj);
  }

  static KidCount fromJSONObject(Map<String,dynamic> obj) {
    var kidCount = KidCount();
    kidCount.here = obj["here"];
    kidCount.kids = obj["kids"];
    return kidCount;
  }

  static List<KidCount> fromJSONList(String json) {
    List<KidCount> kidCounts = [];
    List<dynamic> objs = jsonDecode(json);
    for(var obj in objs) {
      var kidCount = fromJSONObject(obj);
      kidCounts.add(kidCount);
    }
    return kidCounts;
  }
}

class UserInfo {
  String? userName;
  int? leaderID;
  String? admin;
  int? groupID;
  String? groupName;

  Map<String, dynamic> toJSON() {
    return {
      'userName': userName,
      'leaderID': leaderID,
      'admin': admin,
      'groupID': groupID,
      'groupName': groupName,
    };
  }

  static UserInfo fromJSON(String json) {
    var obj = jsonDecode(json);
    return fromJSONObject(obj);
  }

  static UserInfo fromJSONObject(Map<String,dynamic> obj) {
    var userInfo = UserInfo();
    userInfo.groupID = obj["groupID"];
    userInfo.leaderID = obj["leaderID"];
    userInfo.admin = obj["admin"];
    userInfo.userName = obj["userName"];
    userInfo.groupName = obj["groupName"];
    return userInfo;
  }

  static List<UserInfo> fromJSONList(String json) {
    List<UserInfo> data = [];
    List<dynamic> objs = jsonDecode(json);
    for(var obj in objs) {
      var fact = fromJSONObject(obj);
      data.add(fact);
    }
    return data;
  }
}

class GroupData {
  Group? group;
  List<Kid> kids = [];
  List<Attendance> attendance = [];

  Object toJSON() {
    var aList = [];
    for(var attend in attendance) {
      aList.add(attend.toJSON());
    }
    Object obj = {
      'details': group == null ? null : group!.toJSON(),
      'attendance': aList,
    };
    return obj;
  }

  static GroupData fromJSONObject(Map json) {
    var data = GroupData();
    if(json["details"] != null) {
      data.group = Group.fromJSONObject(json["details"]);
    }
    for(var attendJson in json["attendance"]) {
      data.attendance.add(Attendance.fromJSONObject(attendJson));
    }
    return data;
  }
}

class Attendance {
  Kid? kid;
  dynamic today;
  int? kidID;
  bool? verse;
  bool? here;
  bool? bible;
  int? visitors;

  Object toJSON() {
    Object obj = {
      'kid': (kid == null ? null : kid!.toJSON()),
      'today': today,
      'kidID': kidID,
      'verse': verse,
      'here': here,
      'bible': bible,
      'visitors': visitors,
    };
    return obj;
  }

  static Attendance fromJSONObject(Map<String, dynamic> json) {
    var data = Attendance();
    data.kidID = json["kidID"];
    data.today = json['today'];
    data.here = json['here'];
    data.verse = json['verse'];
    data.bible = json['bible'];
    data.visitors = json['visitors'];
    if(json['kid'] != null) {
      data.kid = Kid.fromJSONObject(json['kid']);
    }
    return data;
  }
}

class AddKid {
  String? firstName;
  String? lastName;
  int? grade;
  String? familyName;
  String? groupName;
  Family? family;
  int age = 0;

  Object toJSON() {
    Object obj = {
      'firstName': firstName,
      'lastName': lastName,
      'groupName': groupName,
      'grade': grade,
      'familyName': familyName,
      'age': age,
    };
    return obj;
  }

  static AddKid fromJSON(String json) {
    var obj = jsonDecode(json);
    return fromJSONObject(obj);
  }

  static AddKid fromJSONObject(Map<String,dynamic> obj) {
    var kid = AddKid();
    kid.groupName = obj["groupName"];
    kid.firstName = obj["firstName"];
    kid.lastName = obj["lastName"];
    kid.grade = obj["grade"];
    kid.familyName = obj["familyName"];
    kid.age = obj["age"];
    return kid;
  }

  static List<AddKid> fromJSONList(String json) {
    List<AddKid> kids = [];
    List<dynamic> objs = jsonDecode(json);
    for(var obj in objs) {
      var kid = fromJSONObject(obj);
      kids.add(kid);
    }
    return kids;
  }
}

class Family {
  int id = -1;
  String familyName = "";
  String parentName = "";
  String address = "";
  String phone = "";
  String email = "";

  static Family fromJSONObect(Map<String, dynamic> json) {
    Family newFamily =  Family();
    newFamily.id = json["id"];
    newFamily.familyName = json["familyName"];
    newFamily.parentName = json["parentName"];
    newFamily.address = json["address"];
    newFamily.phone = json["phone"];
    newFamily.email = json["email"];
    return newFamily;
  }

  Map<String, dynamic> toJSON() {
    return {
      "id": id,
      "familyName": familyName,
      "parentName": parentName,
      "address": address,
      "phone": phone,
      "email": email
    };
  }
}

class User {
  String userName = "";
  String password = "";
  int leaderID = -1;
  String systemAdmin = "N";
  int organizationID = -1;

  static User fromJSONObject(Map<String, dynamic> json) {
    User user = User();
    user.userName = json["userName"];
    user.password = json["password"];
    user.leaderID = json["leaderID"];
    user.systemAdmin = json["systemAdmin"];
    user.organizationID = json["organizationID"];
    return user;
  }

  Map<String, dynamic> toJSON() {
    return {
      "userName": userName,
      "password": password,
      "leaderID": leaderID,
      "systemAdmin": systemAdmin,
      "organizationID": organizationID,
    };
  }
}

class Leader {
  int leaderID = -1;
  String firstName = "";
  String lastName = "";
  String email = "";
  int phone = 0;
  int groupID = -1;
  int organizationID = -1;
  String associatedUser = "";

  static Leader fromJSONObject(Map<String, dynamic> json) {
    Leader leader = Leader();
    leader.leaderID = json["leaderID"];
    leader.firstName = json["firstName"];
    leader.lastName = json["lastName"];
    leader.email = json["email"];
    leader.phone = json["phone"];
    leader.groupID = json["groupID"];
    leader.organizationID = json["organizationID"];
    leader.associatedUser = json["associatedUser"];
    return leader;
  }

  Map<String, dynamic> toJSON() {
    return {
      "leaderID": leaderID,
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "phone": phone,
      "groupID": groupID,
      "organizationID": organizationID,
      "associatedUser": associatedUser,
    };
  }

}