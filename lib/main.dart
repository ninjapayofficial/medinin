// import 'package:flutter/material.dart';
// import 'package:medinin_doc/doctor_signup_page.dart';
// import 'package:medinin_doc/patient_list_page.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'MediNin',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: DoctorSignupPage(),
//       routes: {
//         '/patientList': (context) => PatientListPage(),
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:medinin_doc/doctor_signup_page.dart';
import 'package:medinin_doc/patient_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

final MaterialColor myPrimarySwatch = MaterialColor(
  0xFF1A95AB, // The same value as the `Color.fromARGB()` method
  <int, Color>{
    50: Color(0xFFE0F2F3),
    100: Color(0xFFB2DFDB),
    200: Color(0xFF80CBC4),
    300: Color(0xFF4DB6AC),
    400: Color(0xFF26A69A),
    500: Color(0xFF1A95AB),
    600: Color(0xFF00897B),
    700: Color(0xFF00796B),
    800: Color(0xFF00695C),
    900: Color(0xFF004D40),
  },
);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medinin',
      theme: ThemeData(
        primarySwatch: myPrimarySwatch,
        primaryColor: Color(0xFFB2DFDB),
        accentColor: Color(0xFFB2DFDB),
        fontFamily: 'Montserrat',
      ),
      home: MyHomePage(title: 'Medinin'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _fullName = '';
  String _designation = '';
  String _pincode = '';

  @override
  void initState() {
    super.initState();
    _loadDoctorDetails();
  }

  void _loadDoctorDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('fullName') ?? '';
      _designation = prefs.getString('designation') ?? '';
      _pincode = prefs.getString('pincode') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome, Dr. $_fullName',
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: 16.0),
            Text(
              '$_designation, Pincode: $_pincode',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PatientListPage()),
                );
              },
              child: Text('Patient List'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DoctorSignupPage()),
                );
              },
              child: Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
