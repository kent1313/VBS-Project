import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:vbs_shared/vbs_shared.dart';
import 'authorizationData.dart';

class KidData extends StatefulWidget {
  const KidData({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<KidData> createState() => _KidDataState();
}

class _KidDataState extends State<KidData> {
  bool isHere = false;
  Attendance? attendance;
  TextEditingController visitors = TextEditingController();
  dynamic today = DateTime.now();


  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as KidDataParameter;
    if(attendance == null) {
      attendance = args.attendance;
    }
    attendance!.today = today.toString().substring(0,10);
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
        body: Center(child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: CheckboxListTile(
                  title: const Text('Here', style: TextStyle(fontSize: 18),),
                  secondary: const Icon(Icons.beenhere),
                  value: attendance!.here,
                  onChanged: (bool? value) {
                    setState(() {
                      attendance!.here = value;
                      if(value == false) {
                        attendance!.verse = value;
                        visitors.text = '';
                      }
                      api.updateAttendance(context, attendance!);
                      isHere = value!;
                    });
                    print(value);
                  },
                )
              ),
              Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: CheckboxListTile(
                    title: const Text('Verse', style: TextStyle(fontSize: 18),),
                    secondary: const Icon(Icons.beenhere),
                    value: attendance!.verse,
                    onChanged: (attendance!.here ?? false) ? verseChecked: null,
                  )
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(25, 0, 10, 0),
                      child: Icon(
                        Icons.emoji_people, color: (isHere) ? Colors.black87: Colors.black38,
                      )
                  ),
                  Container(
                      padding: const EdgeInsets.fromLTRB(18, 0, 10, 0),
                      child: Text(
                        'Visitors', style: TextStyle(
                          fontSize: 18, color: (isHere) ? Colors.black: Colors.black38
                      ),
                      )
                  ),
                  Flexible(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 23, 0),
                          width: 70.0,
                          height: 70.0,
                          child: TextField(
                            maxLength: 2,
                            enabled: isHere,
                            controller: visitors,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              //labelText: 'Visitors',
                            ),
                            onChanged: (value) {
                              setState(() {
                                attendance!.visitors = int.parse(visitors.text);
                                api.updateAttendance(context, attendance!);
                              });
                            },
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            ],
                          ),
                        ),
                      ),
                  ),
                ],
              )
            ]
        )
        )
    );
  }

  void verseChecked(bool? verse) {
    if (isHere == true) {
      setState(() {
        //set "attendance.verse" to "verse"
        attendance!.verse = verse;
        api.updateAttendance(context, attendance!);
      });
    } else {
    }
  }

}

loadData() {

}

testTouch() {
  print('You tapped the button!');
}


class KidDataParameter {
  final Attendance attendance;

  KidDataParameter({required this.attendance});


}