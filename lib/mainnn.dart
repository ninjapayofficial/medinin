// import 'package:flutter/material.dart';
// import 'package:medinin_doc/doctor_signup_page.dart';
// import 'package:medinin_doc/patient_list_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Medinin',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(title: 'Medinin'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key, required this.title}) : super(key: key);

//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   String _fullName = '';
//   String _designation = '';
//   String _pincode = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadDoctorDetails();
//   }

//   void _loadDoctorDetails() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _fullName = prefs.getString('fullName') ?? '';
//       _designation = prefs.getString('designation') ?? '';
//       _pincode = prefs.getString('pincode') ?? '';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Welcome, Dr. $_fullName',
//               style: Theme.of(context).textTheme.headline5,
//             ),
//             SizedBox(height: 16.0),
//             Text(
//               '$_designation, Pincode: $_pincode',
//               style: Theme.of(context).textTheme.subtitle1,
//             ),
//             SizedBox(height: 32.0),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => PatientListPage()),
//                 );
//               },
//               child: Text('Patient List'),
//             ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => DoctorSignupPage()),
//                 );
//               },
//               child: Text('Edit Profile'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
