import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void callbackDispatcher() {
  print('yo');
  Workmanager().executeTask((task, inputData) async {
    DateTime now = DateTime.now();
    print('callback called');
    DateTime updateTime = DateTime(now.day, now.month, now.year, 23, 0);
    int timeDifferenceInSeconds = updateTime.difference(now).inSeconds;
    int updateThresholdInSeconds = 60 * 60;
    if (timeDifferenceInSeconds >= 0 &&
        timeDifferenceInSeconds <= updateThresholdInSeconds) {
      final prefs = await SharedPreferences.getInstance();
      int leftMedicine = prefs.getInt('medicines_left') ?? 4;
      int takenMedicine = prefs.getInt('medicines_taken') ?? 6;
      print('takenMedicine: $takenMedicine');
      print('kushal ${takenMedicine}');
      if (leftMedicine == 0 || takenMedicine == 10) {
        takenMedicine = 1;
        leftMedicine = 9;
      } else {
        takenMedicine++;
        leftMedicine--;
      }
      prefs.setInt('medicines_taken', takenMedicine);
      prefs.setInt('medicines_left', leftMedicine);

      // Update date, month, and year
      prefs.setInt('date', now.day);
      prefs.setInt('month', now.month);
      prefs.setInt('year', now.year);
    }
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerOneOffTask(
    'regularUpdateTask',
    'updateMedicineCounts',
    initialDelay: Duration(
      hours: 23 - DateTime.now().hour, // Hours remaining until 11 PM
      minutes: 40 - DateTime.now().minute, // Minutes remaining until 11 minutes
    ),
  );
  Workmanager().registerPeriodicTask(
    'backgroundCheckTask',
    'backgroundCheck',
    frequency: Duration(minutes: 15),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DateTime lastDay = DateTime.now().subtract(Duration(days: 1));
  int noOfTakenMedicine = 10;
  int noOfLeftMedicine = 0;
  late int date = lastDay.day;
  late int month = lastDay.month;
  late int year = lastDay.year;
  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'June',
    'July',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadsMedicineCounts();
    loadsDate();
    print('Init State');
    print(noOfTakenMedicine);
  }

  loadsMedicineCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      noOfLeftMedicine = prefs.getInt('medicines_left') ?? 4;
      noOfTakenMedicine = prefs.getInt('medicines_taken') ?? 6;
    });
    print('Init State calling function update');
    print(noOfTakenMedicine);
  }

  loadsDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      date = prefs.getInt('date') ?? lastDay.day;
      month = prefs.getInt('month') ?? lastDay.month;
      year = prefs.getInt('year') ?? lastDay.year;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          leading: Container(
            margin: EdgeInsets.only(left: 10, top: 8, bottom: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Colors.black38,
            ),
            child: Center(
              child: Icon(
                Icons.person,
                size: 30,
              ),
            ),
          ),
          title: const Text("Bp Medicine Tracker"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Text(
                  '1:00 PM',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                trailing: Text(
                  '${noOfLeftMedicine} Medicine Left',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.water_drop,
                    color: Colors.white,
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        height: 40,
                        width: 1,
                        color: Colors.white54,
                      ),
                      Expanded(
                        child: ListTile(
                          leading: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Bp Medicine',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                '$date ${months[month - 1]} $year',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            '${noOfTakenMedicine} Taken Until',
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              const Text(
                'Updates Regularly at 1:00 PM',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
