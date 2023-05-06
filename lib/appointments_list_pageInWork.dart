// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'add_appointment_page.dart';
// import 'database_helper.dart';

// class AppointmentsListPage extends StatefulWidget {
//   @override
//   _AppointmentsListPageState createState() => _AppointmentsListPageState();
// }

// class _AppointmentsListPageState extends State<AppointmentsListPage> {
//   DateTime? _selectedDate;
//   bool _showPastAppointments = false;
//   List<Map<String, dynamic>> _appointments = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadAppointments();
//   }

//   void _loadAppointments() async {
//     List<Map<String, dynamic>> appointmentsJson =
//         await DatabaseHelper.instance.loadAppointmentsFromJson();
//     setState(() {
//       _appointments = appointmentsJson;
//     });
//     print('Loaded appointments: $_appointments');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Appointments'),
//         actions: <Widget>[
//           IconButton(
//             icon: Icon(Icons.date_range),
//             onPressed: () async {
//               final DateTime? nullablePickedDate = await showDatePicker(
//                 context: context,
//                 initialDate: _selectedDate ?? DateTime.now(),
//                 firstDate: DateTime(DateTime.now().year - 5),
//                 lastDate: DateTime(DateTime.now().year + 5),
//               );
//               final DateTime pickedDate = nullablePickedDate ?? DateTime.now();
//               if (pickedDate != null && pickedDate != _selectedDate) {
//                 setState(() {
//                   _selectedDate = pickedDate;
//                 });
//               }
//             },
//           ),
//           IconButton(
//             icon: Icon(_showPastAppointments
//                 ? Icons.visibility_off
//                 : Icons.visibility),
//             onPressed: () {
//               setState(() {
//                 _showPastAppointments = !_showPastAppointments;
//               });
//             },
//           ),
//         ],
//       ),
//       body: ListView.builder(
//         itemCount: _appointments.length,
//         itemBuilder: (context, index) {
//           Map<String, dynamic> appointment = _appointments[index];
//           DateTime appointmentDate =
//               DateTime.parse(appointment['appointmentDate']);
//           return Dismissible(
//             key: UniqueKey(),
//             onDismissed: (direction) async {
//               await DatabaseHelper.instance.deleteAppointmentFromJson(index);
//               setState(() {
//                 _appointments.removeAt(index);
//               });
//             },
//             background: Container(color: Colors.red),
//             child: ListTile(
//               title: Text(appointment['patientName']),
//               subtitle: Text(DateFormat.yMMMMd().format(appointmentDate)),
//               onTap: () {
//                 // Navigate to the appointment details page
//               },
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           Map<String, dynamic> newAppointment = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => AddAppointmentPage()),
//           );
//           print('New appointment: $newAppointment');
//           if (newAppointment != null) {
//             await DatabaseHelper.instance
//                 .saveAppointmentsToJson([newAppointment]);
//             _loadAppointments();
//           }
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }



///////////////////////////////////////////////////////////////////////////////////////////
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'add_appointment_page.dart';

// class AppointmentsListPage extends StatefulWidget {
//   @override
//   _AppointmentsListPageState createState() => _AppointmentsListPageState();
// }

// class _AppointmentsListPageState extends State<AppointmentsListPage> {
//   DateTime? _selectedDate; // Date to null
//   // DateTime _selectedDate = DateTime.now();
//   bool _showPastAppointments = false;
//   List<Map<String, dynamic>> _appointments = [];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Appointments'),
//         actions: <Widget>[
//           IconButton(
//             icon: Icon(Icons.date_range),
//             onPressed: () async {
//               final DateTime? nullablePickedDate = await showDatePicker(
//                 context: context,
//                 initialDate: _selectedDate ?? DateTime.now(),
//                 firstDate: DateTime(DateTime.now().year - 5),
//                 lastDate: DateTime(DateTime.now().year + 5),
//               );
//               final DateTime pickedDate = nullablePickedDate ?? DateTime.now();
//               if (pickedDate != null && pickedDate != _selectedDate) {
//                 setState(() {
//                   _selectedDate = pickedDate;
//                 });
//               }
//             },
//           ),
//           IconButton(
//             icon: Icon(_showPastAppointments
//                 ? Icons.visibility_off
//                 : Icons.visibility),
//             onPressed: () {
//               setState(() {
//                 _showPastAppointments = !_showPastAppointments;
//               });
//             },
//           ),
//         ],
//       ),
//       body: ListView(
//         children: _appointments.where((appointment) {
//           final appointmentDateTime = appointment['appointmentDate'].add(
//               Duration(
//                   hours: appointment['appointmentTime'].hour,
//                   minutes: appointment['appointmentTime'].minute));
//           final isSameDay = _selectedDate == null ||
//               (appointment['appointmentDate'].day == _selectedDate!.day &&
//                   appointment['appointmentDate'].month ==
//                       _selectedDate!.month &&
//                   appointment['appointmentDate'].year == _selectedDate!.year);

//           return _showPastAppointments
//               ? appointmentDateTime.isBefore(DateTime.now()) && isSameDay
//               : appointmentDateTime.isAfter(DateTime.now()) && isSameDay;
//         }).map((appointment) {
//           return ListTile(
//             title: Text(appointment['patientName']),
//             subtitle: Text(
//               '${DateFormat.yMMMMd().format(appointment['appointmentDate'])} ${appointment['appointmentTime'].format(context)} (${appointment['appointmentDuration']} min) - Notes: ${appointment['notes']}',
//             ),
//           );
//         }).toList(),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           // Navigate to a page where the user can add a new appointment
//           final newAppointment = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => AddAppointmentPage()),
//           );
//           if (newAppointment != null) {
//             // Update the appointments list with the new appointment
//             setState(() {
//               _appointments.add(newAppointment);
//               _appointments.sort((a, b) {
//                 final aDateTime = a['appointmentDate'].add(Duration(
//                     hours: a['appointmentTime'].hour,
//                     minutes: a['appointmentTime'].minute));
//                 final bDateTime = b['appointmentDate'].add(Duration(
//                     hours: b['appointmentTime'].hour,
//                     minutes: b['appointmentTime'].minute));
//                 return aDateTime.compareTo(bDateTime);
//               });
//             });
//           }
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }
