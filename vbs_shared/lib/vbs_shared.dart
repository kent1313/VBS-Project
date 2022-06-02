library vbs_shared;
import 'dart:convert';

class Group {
  int? groupID;
  String? groupName;
  int? mainLeaderID;

  Object toJSON() {
    Object obj = {
      'groupID': groupID,
      'groupName': groupName,
      'mainLeaderID': mainLeaderID,
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
  String? DOB;
  int? grade;
  int? familyID;
  int? groupID;

  Object toJSON() {
    Object obj = {
      'kidID': kidID,
      'firstName': firstName,
      'lastName': lastName,
      'groupID': groupID,
      'DOB': DOB,
      'grade': grade,
      'familyID': familyID
    };
    return obj;
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
    kid.DOB = obj["DOB"];
    kid.grade = obj["grade"];
    kid.familyID = obj["familyID"];
    kid.kidID = obj["kidID"];
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
      'details': group!.toJSON(),
      'attendance': aList,
    };
    return obj;
  }

  static GroupData fromJSONObject(Map json) {
    var data = GroupData();
    data.group = Group.fromJSONObject(json["details"]);
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

  Object toJSON() {
    Object obj = {
      'kid': (kid == null ? null : kid!.toJSON()),
      'today': today,
      'kidID': kidID,
      'verse': verse,
      'here': here,
    };
    return obj;
  }

  static Attendance fromJSONObject(Map<String, dynamic> json) {
    var data = Attendance();
    data.kidID = json["kidID"];
    data.today = json['today'];
    data.here = json['here'];
    data.verse = json['verse'];
    if(json['kid'] != null) {
      data.kid = Kid.fromJSONObject(json['kid']);
    }
    return data;
  }
}

