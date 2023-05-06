import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_appointment_page.dart';

class AppointmentsListPage extends StatefulWidget {
  @override
  _AppointmentsListPageState createState() => _AppointmentsListPageState();
}

class _AppointmentsListPageState extends State<AppointmentsListPage> {
  DateTime? _selectedDate; // Date to null
  // DateTime _selectedDate = DateTime.now();
  bool _showPastAppointments = false;
  List<Map<String, dynamic>> _appointments = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () async {
              final DateTime? nullablePickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(DateTime.now().year - 5),
                lastDate: DateTime(DateTime.now().year + 5),
              );
              final DateTime pickedDate = nullablePickedDate ?? DateTime.now();
              if (pickedDate != null && pickedDate != _selectedDate) {
                setState(() {
                  _selectedDate = pickedDate;
                });
              }
            },
          ),
          IconButton(
            icon: Icon(_showPastAppointments
                ? Icons.visibility_off
                : Icons.visibility),
            onPressed: () {
              setState(() {
                _showPastAppointments = !_showPastAppointments;
              });
            },
          ),
        ],
      ),
      body: ListView(
        children: _appointments.where((appointment) {
          final appointmentDateTime = appointment['appointmentDate'].add(
              Duration(
                  hours: appointment['appointmentTime'].hour,
                  minutes: appointment['appointmentTime'].minute));
          final isSameDay = _selectedDate == null ||
              (appointment['appointmentDate'].day == _selectedDate!.day &&
                  appointment['appointmentDate'].month ==
                      _selectedDate!.month &&
                  appointment['appointmentDate'].year == _selectedDate!.year);

          return _showPastAppointments
              ? appointmentDateTime.isBefore(DateTime.now()) && isSameDay
              : appointmentDateTime.isAfter(DateTime.now()) && isSameDay;
        }).map((appointment) {
          return ListTile(
            title: Text(appointment['patientName']),
            subtitle: Text(
              '${DateFormat.yMMMMd().format(appointment['appointmentDate'])} ${appointment['appointmentTime'].format(context)} (${appointment['appointmentDuration']} min) - Notes: ${appointment['notes']}',
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to a page where the user can add a new appointment
          final newAppointment = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAppointmentPage()),
          );
          if (newAppointment != null) {
            // Update the appointments list with the new appointment
            setState(() {
              _appointments.add(newAppointment);
              _appointments.sort((a, b) {
                final aDateTime = a['appointmentDate'].add(Duration(
                    hours: a['appointmentTime'].hour,
                    minutes: a['appointmentTime'].minute));
                final bDateTime = b['appointmentDate'].add(Duration(
                    hours: b['appointmentTime'].hour,
                    minutes: b['appointmentTime'].minute));
                return aDateTime.compareTo(bDateTime);
              });
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class Appointment {
  final String patientName;
  final DateTime appointmentDate;
  final TimeOfDay appointmentTime;
  final int appointmentDuration;
  final String notes;

  Appointment({
    required this.patientName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.appointmentDuration,
    required this.notes,
  });
}
