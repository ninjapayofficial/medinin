import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medinin_doc/patient.dart';
import 'package:medinin_doc/patient_details_page.dart';
import 'package:medinin_doc/add_patient_page.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:medinin_doc/database_helper.dart';
import 'package:medinin_doc/patient_history_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class PatientListPage extends StatefulWidget {
  @override
  _PatientListPageState createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  List<Patient> _patients = [];
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _getPatients().then((patients) {
      setState(() {
        _patients = patients;
      });
    });
  }

  Future<List<Patient>> _getPatients() async {
    return await dbHelper.getPatients();
  }

  void _navigateToPatientDetails(Patient patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PatientDetailsPage(patient: patient)),
    );
  }

  void _addPatient(Patient patient) async {
    int newPatientId = await dbHelper.insert(patient);
    print('New patient ID: $newPatientId, Patient: $patient');
    setState(() {
      _patients.add(patient.copyWith(id: newPatientId));
    });
  }

  void _navigateToAddPatient() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddPatientPage(onAddPatient: _addPatient)),
    );
  }

  void _deletePatient(Patient patient) async {
    int deletedRows = await dbHelper.delete(patient.id!);
    if (deletedRows > 0) {
      setState(() {
        _patients.remove(patient);
      });
    }
  }

  void _downloadBackup() async {
    final patients = await _getPatients();

    List<List<String>> patientData = [
      [
        'Patient Name',
        'Date of Birth',
        'Gender',
        'Phone Number',
        'Email',
        'Prescription Name',
        'Prescription Notes',
        'Prescription Date'
      ]
    ];

    for (var patient in patients) {
      final prefs = await SharedPreferences.getInstance();
      final patientKey = 'prescriptions_${patient.id}';
      final prescriptionStrings = prefs.getStringList(patientKey) ?? [];

      if (prescriptionStrings.isEmpty) {
        patientData.add([
          patient.fullName,
          patient.dob ?? '',
          patient.gender ?? '',
          patient.phoneNumber ?? '',
          patient.email ?? '',
          '',
          '',
          '',
        ]);
      } else {
        prescriptionStrings.forEach((prescriptionString) {
          final parts = prescriptionString.split('|');
          final prescription = Prescription(
            name: parts[0],
            notes: parts[1],
            date: DateTime.parse(parts[2]),
          );

          patientData.add([
            patient.fullName,
            patient.dob ?? '',
            patient.gender ?? '',
            patient.phoneNumber ?? '',
            patient.email ?? '',
            prescription.name,
            prescription.notes,
            prescription.date.toString(),
          ]);
        });
      }
    }

    // Get the app's temporary directory
    final directory = await path_provider.getExternalStorageDirectory();
    final filePath = '${directory!.path}/patients.csv';

    // Write the patient list to a CSV file
    final csvString = const ListToCsvConverter().convert(patientData);
    final csvBytes = utf8.encode(csvString);
    await File(filePath).writeAsBytes(csvBytes);

    // Show a snackbar with the file path and download button
    final snackBar = SnackBar(
      content: Text('Backup downloaded to $filePath'),
      action: SnackBarAction(
        label: 'Open',
        onPressed: () {
          // Open the backup file
          OpenFile.open(filePath);
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient List'),
        actions: [
          IconButton(
            icon: Icon(Icons.cloud_download),
            onPressed: _downloadBackup,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _patients.length,
        itemBuilder: (context, index) {
          final patient = _patients[index];
          return Dismissible(
            key: Key(patient.fullName),
            onDismissed: (direction) {
              _deletePatient(patient);
            },
            background: Container(
              color: Colors.red,
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: _buildPatientTile(context, patient),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPatient,
        child: Icon(Icons.add),
      ),
    );
  }
}

ListTile _buildPatientTile(BuildContext context, Patient patient) {
  return ListTile(
    title: Text(patient.fullName),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatientDetailsPage(patient: patient),
        ),
      );
    },
    trailing: IconButton(
      icon: Icon(Icons.history),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientHistoryPage(patient: patient),
          ),
        );
      },
    ),
  );
}

class Prescription {
  final String name;
  final String notes;
  final DateTime date;

  Prescription({required this.name, required this.notes, required this.date});
}
