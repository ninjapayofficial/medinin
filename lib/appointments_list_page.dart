import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_appointment_page.dart';

class AppointmentsListPage extends StatefulWidget {
  @override
  _AppointmentsListPageState createState() => _AppointmentsListPageState();
}

class _AppointmentsListPageState extends State<AppointmentsListPage> {
  DateTime? _selectedDate;
  bool _showPastAppointments = false;
  List<Appointment> _appointments = [];
  // Helper method to create an Appointment object from a Map
  Appointment _createAppointmentFromMap(Map<String, dynamic> map) {
    return Appointment(
      patientName: map['patientName'],
      appointmentDate: map['appointmentDate'],
      appointmentTime: map['appointmentTime'],
      appointmentDuration: map['appointmentDuration'],
      notes: map['notes'],
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _saveAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      'appointments',
      _appointments.map((appointment) {
        return '${appointment.patientName}|${appointment.appointmentDate.toIso8601String()}|${appointment.appointmentTime.format(context)}|${appointment.appointmentDuration}|${appointment.notes}';
      }).toList(),
    );
  }

  Future<void> _loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final appointmentStrings = prefs.getStringList('appointments') ?? [];
    setState(() {
      _appointments = appointmentStrings.map((appointmentString) {
        final parts = appointmentString.split('|');
        return Appointment(
          patientName: parts[0],
          appointmentDate: DateTime.parse(parts[1]),
          appointmentTime: TimeOfDay.fromDateTime(DateTime.parse(parts[1])),
          appointmentDuration: int.parse(parts[3]),
          notes: parts[4],
        );
      }).toList();
    });
  }

  void _addAppointment(Appointment appointment) {
    setState(() {
      _appointments.add(appointment);
      _appointments.sort((a, b) {
        final aDateTime = a.appointmentDate.add(Duration(
            hours: a.appointmentTime.hour, minutes: a.appointmentTime.minute));
        final bDateTime = b.appointmentDate.add(Duration(
            hours: b.appointmentTime.hour, minutes: b.appointmentTime.minute));
        return aDateTime.compareTo(bDateTime);
      });
    });
    _saveAppointments();
  }

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
          final appointmentDateTime = appointment.appointmentDate.add(Duration(
              hours: appointment.appointmentTime.hour,
              minutes: appointment.appointmentTime.minute));
          final isSameDay = _selectedDate == null ||
              (appointment.appointmentDate.day == _selectedDate!.day &&
                  appointment.appointmentDate.month == _selectedDate!.month &&
                  appointment.appointmentDate.year == _selectedDate!.year);

          return _showPastAppointments
              ? appointmentDateTime.isBefore(DateTime.now()) && isSameDay
              : appointmentDateTime.isAfter(DateTime.now()) && isSameDay;
        }).map((appointment) {
          return ListTile(
            title: Text(appointment.patientName),
            subtitle: Text(
              '${DateFormat.yMMMMd().format(appointment.appointmentDate)} ${appointment.appointmentTime.format(context)} (${appointment.appointmentDuration} min) - Notes: ${appointment.notes}',
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newAppointmentMap = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAppointmentPage()),
          );
          if (newAppointmentMap != null) {
            _addAppointment(_createAppointmentFromMap(newAppointmentMap));
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
