import 'package:flutter/material.dart';
import 'package:medinin_doc/patient.dart';

class PatientDetailsPage extends StatelessWidget {
  final Patient patient;

  PatientDetailsPage({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name: ${patient.fullName}'),
          Text('Date of Birth: ${patient.dob}'),
          Text('Gender: ${patient.gender}'),
          Text('Phone Number: ${patient.phoneNumber}'),
          Text('Email: ${patient.email}'),
        ],
      ),
    );
  }
}
