import 'dart:math';

void main() {
  generatePassword(25);
}

generatePassword(num) {
  String password = '';
  for(var i = 0; i < num; i++) {
    password = password + String.fromCharCode(Random().nextInt(93) + 33);
  }
  print(password);
}