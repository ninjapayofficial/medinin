import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medinin_v1/patient.dart';
import 'package:medinin_v1/patient_details_page.dart';
import 'package:medinin_v1/add_patient_page.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientListPage extends StatefulWidget {
  @override
  _PatientListPageState createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  List<Patient> _patients = [];
  Patient? _selectedPatient;

  @override
  void initState() {
    super.initState();
    _getPatients();
  }

  void _savePatients(List<Patient> patients) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(patients);
    await prefs.setString('patients', json);
  }

  Future<List<Patient>> _getPatients() async {
    final prefs = await SharedPreferences.getInstance();
    final patientListJson = prefs.getString('patientList') ?? '[]';
    final List<dynamic> patientListDynamic = json.decode(patientListJson);
    final List<Patient> patientList = patientListDynamic
        .map((patientJson) => Patient.fromJson(patientJson))
        .toList();
    return patientList;
  }

  void _navigateToPatientDetails(Patient patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PatientDetailsPage(patient: patient)),
    );
  }

  void _addPatient(Patient patient) {
    setState(() {
      _patients.add(patient);
    });
    _savePatients(_patients);
  }

  void _navigateToAddPatient() async {
    final newPatient = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddPatientPage(onAddPatient: _addPatient)),
    );

    if (newPatient != null) {
      _addPatient(newPatient);
    }
  }

  void _deletePatient(Patient patient) {
    setState(() {
      _patients.remove(patient);
    });
    _savePatients(_patients);
  }

  void _showDeleteConfirmationDialog(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Patient'),
        content: Text('Are you sure you want to delete ${patient.name}?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () {
              _deletePatient(patient);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _downloadBackup() async {
    final patients = await _getPatients();

    // Get the app's document directory
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/patients.csv';

    // Write the patient list to a CSV file
    final csvData = List<List<String>>.from([
      ['Name', 'Date of Birth', 'Gender', 'Phone Number', 'Email'],
      ...patients.map((p) => [
            p.name,
            p.dob ?? '',
            p.gender ?? '',
            p.phoneNumber ?? '',
            p.email ?? ''
          ]),
    ]);
    final csvString = const ListToCsvConverter().convert(csvData);
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
            key: Key(patient.name),
            onDismissed: (direction) {
              _showDeleteConfirmationDialog(patient);
            },
            background: Container(
              color: Colors.red,
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              title: Text(patient.name),
              onTap: () {
                _navigateToPatientDetails(patient);
              },
            ),
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
