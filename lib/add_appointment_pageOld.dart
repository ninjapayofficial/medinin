// import 'package:flutter/material.dart';

// class AddAppointmentPage extends StatefulWidget {
//   @override
//   _AddAppointmentPageState createState() => _AddAppointmentPageState();
// }

// class _AddAppointmentPageState extends State<AddAppointmentPage> {
//   TextEditingController _patientNameController = TextEditingController();
//   TextEditingController _notesController = TextEditingController();
//   DateTime _appointmentDate = DateTime.now();
//   TimeOfDay _appointmentTime = TimeOfDay.now();
//   int _appointmentDuration = 30;

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? nullablePickedDate = await showDatePicker(
//       context: context,
//       initialDate: _appointmentDate,
//       firstDate: DateTime(DateTime.now().year - 5),
//       lastDate: DateTime(DateTime.now().year + 5),
//     );

//     final DateTime pickedDate = nullablePickedDate ?? DateTime.now();

//     if (pickedDate != _appointmentDate) {
//       setState(() {
//         _appointmentDate = pickedDate;
//       });
//     }
//   }

//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? nullablePickedTime = await showTimePicker(
//       context: context,
//       initialTime: _appointmentTime,
//     );

//     final TimeOfDay pickedTime = nullablePickedTime ?? TimeOfDay.now();

//     if (pickedTime != _appointmentTime) {
//       setState(() {
//         _appointmentTime = pickedTime;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Appointment'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             // Add widgets to input a patient name
//             TextField(
//               controller: _patientNameController,
//               decoration: InputDecoration(
//                 labelText: 'Patient Name',
//                 hintText: 'Enter the patient name',
//               ),
//             ),
//             // Add widgets to select the appointment date and time
//             ListTile(
//               title: Text('Date: ${_appointmentDate.toLocal()}'),
//               trailing: Icon(Icons.arrow_forward),
//               onTap: () => _selectDate(context),
//             ),
//             ListTile(
//               title: Text('Time: ${_appointmentTime.format(context)}'),
//               trailing: Icon(Icons.arrow_forward),
//               onTap: () => _selectTime(context),
//             ),
//             // Add widgets to select the appointment duration (optional)
//             TextField(
//               keyboardType: TextInputType.number,
//               onChanged: (value) {
//                 setState(() {
//                   _appointmentDuration = int.tryParse(value) ?? 30;
//                 });
//               },
//               decoration: InputDecoration(
//                 labelText: 'Duration (minutes)',
//                 hintText: 'Enter the duration in minutes',
//               ),
//             ),
//             // Add a widget to input the notes (optional)
//             TextField(
//               controller: _notesController,
//               decoration: InputDecoration(
//                 labelText: 'Notes',
//                 hintText: 'Enter any additional notes (optional)',
//               ),
//               maxLines: null,
//               keyboardType: TextInputType.multiline,
//             ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () {
//                 // Save the appointment
//                 // Then navigate back to the appointments list page
//                 Navigator.pop(context, {
//                   'patientName': _patientNameController.text,
//                   'appointmentDate': _appointmentDate,
//                   'appointmentTime': _appointmentTime,
//                   'appointmentDuration': _appointmentDuration,
//                   'notes': _notesController.text,
//                 });
//               },
//               child: Text('Save Appointment'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // Import the DateFormat class

// class AddAppointmentPage extends StatefulWidget {
//   @override
//   _AddAppointmentPageState createState() => _AddAppointmentPageState();
// }

// class _AddAppointmentPageState extends State<AddAppointmentPage> {
//   TextEditingController _patientNameController = TextEditingController();
//   TextEditingController _notesController = TextEditingController();
//   DateTime _appointmentDate = DateTime.now();
//   TimeOfDay _appointmentTime = TimeOfDay.now();
//   int _appointmentDuration = 30;

//   // Add this function to format the date
//   String _formattedDate(DateTime date) {
//     return DateFormat('yyyy-MM-dd').format(date);
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? nullablePickedDate = await showDatePicker(
//       context: context,
//       initialDate: _appointmentDate,
//       firstDate: DateTime(DateTime.now().year - 5),
//       lastDate: DateTime(DateTime.now().year + 5),
//     );

//     final DateTime pickedDate = nullablePickedDate ?? DateTime.now();

//     if (pickedDate != _appointmentDate) {
//       setState(() {
//         _appointmentDate = pickedDate;
//       });
//     }
//   }

//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? nullablePickedTime = await showTimePicker(
//       context: context,
//       initialTime: _appointmentTime,
//     );

//     final TimeOfDay pickedTime = nullablePickedTime ?? TimeOfDay.now();

//     if (pickedTime != _appointmentTime) {
//       setState(() {
//         _appointmentTime = pickedTime;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Appointment'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             TextField(
//               controller: _patientNameController,
//               decoration: InputDecoration(
//                 labelText: 'Patient Name',
//                 hintText: 'Enter the patient name',
//               ),
//             ),
//             ListTile(
//               title: Text('Date: ${_formattedDate(_appointmentDate)}'),
//               trailing: Icon(Icons.arrow_forward),
//               onTap: () => _selectDate(context),
//             ),
//             ListTile(
//               title: Text('Time: ${_appointmentTime.format(context)}'),
//               trailing: Icon(Icons.arrow_forward),
//               onTap: () => _selectTime(context),
//             ),
//             TextField(
//               keyboardType: TextInputType.number,
//               onChanged: (value) {
//                 setState(() {
//                   _appointmentDuration = int.tryParse(value) ?? 30;
//                 });
//               },
//               decoration: InputDecoration(
//                 labelText: 'Duration (minutes)',
//                 hintText: 'Enter the duration in minutes',
//               ),
//             ),
//             TextField(
//               controller: _notesController,
//               decoration: InputDecoration(
//                 labelText: 'Notes',
//                 hintText: 'Enter any additional notes (optional)',
//               ),
//               maxLines: null,
//               keyboardType: TextInputType.multiline,
//             ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context, {
//                   'patientName': _patientNameController.text,
//                   'appointmentDate': _formattedDate(_appointmentDate),
//                   'appointmentTime': _appointmentTime,
//                   'appointmentDuration': _appointmentDuration,
//                   'notes': _notesController.text,
//                 });
//               },
//               child: Text('Save Appointment'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
