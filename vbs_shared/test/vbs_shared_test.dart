import 'dart:convert';

import 'package:test/test.dart';
import 'package:vbs_shared/vbs_shared.dart';

void main() {
  test('kid loads', () {
    Kid kid = Kid();
    kid.kidID = 1;
    kid.firstName = "Bob";
    kid.lastName = "Tomato";
    kid.grade = 2;
    kid.familyID = 1;
    kid.family = Family();
    kid.family!.familyName = "The Tomatos";
    kid.groupID = 1;
    kid.groupName = "Testing";

    var json = jsonEncode(kid.toJSON());
    var newKid = Kid.fromJSON(json);
    expect(newKid.kidID, 1);
    expect(newKid.firstName, "Bob");
    expect(newKid.lastName, "Tomato");
    expect(newKid.grade, 2);
    expect(newKid.familyID, 1);
    expect(newKid.family!.familyName, "The Tomatos");
    expect(newKid.groupID, 1);
    expect(newKid.groupName, "Testing");
  });
}
