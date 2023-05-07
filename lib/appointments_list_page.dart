import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_appointment_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AppointmentsListPage extends StatefulWidget {
  @override
  _AppointmentsListPageState createState() => _AppointmentsListPageState();
}

class _AppointmentsListPageState extends State<AppointmentsListPage> {
  DateTime? _selectedDate;
  bool _showPastAppointments = false;
  List<Appointment> _appointments = [];
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
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

  tz.TZDateTime _getScheduledNotificationDateTime(Appointment appointment) {
    final appointmentDateTime = tz.TZDateTime.from(
      DateTime(
        appointment.appointmentDate.year,
        appointment.appointmentDate.month,
        appointment.appointmentDate.day,
        appointment.appointmentTime.hour,
        appointment.appointmentTime.minute,
      ),
      tz.local,
    );

    return appointmentDateTime.subtract(Duration(minutes: 10));
  }

  Future<void> _scheduleNotification(Appointment appointment) async {
    var scheduledNotificationDateTime =
        _getScheduledNotificationDateTime(appointment);
    print(
        'Scheduling notification for appointment at $scheduledNotificationDateTime');

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'appointment_reminder_channel',
      'Appointment Reminders',
      channelDescription:
          'This channel is for appointment reminder notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    print(
        'Scheduling notification for appointment at $scheduledNotificationDateTime');

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Appointment Reminder',
      'You have an appointment with ${appointment.patientName} in 10 minutes',
      scheduledNotificationDateTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _loadAppointments();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: Text(title!),
            content: Text(body!),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Ok'),
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              )
            ],
          ),
        );
      },
    );

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
    });
    _requestNotificationPermissions();
  }

  void _requestNotificationPermissions() async {
    if (Platform.isIOS) {
      final settings = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      print('User granted permissions: $settings');
    }
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
        final date = DateTime.parse(parts[1]);
        final time = TimeOfDay.fromDateTime(
            DateTime(date.year, date.month, date.day).add(Duration(
                hours: int.parse(parts[2].split(':')[0]),
                minutes: int.parse(parts[2].split(':')[1]))));
        return Appointment(
          patientName: parts[0],
          appointmentDate: date,
          appointmentTime: time,
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
    _scheduleNotification(appointment); // Schedule the notification
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
