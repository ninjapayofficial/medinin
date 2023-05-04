import 'package:flutter/material.dart';
import 'package:medinin_doc/patient.dart';
import 'package:medinin_doc/drug_widget.dart';
import 'package:medinin_doc/report_widget.dart';
import 'package:medinin_doc/vital_widget.dart';

class PatientHistoryPage extends StatefulWidget {
  final Patient patient;

  PatientHistoryPage({required this.patient});

  @override
  _PatientHistoryPageState createState() => _PatientHistoryPageState();
}

class _PatientHistoryPageState extends State<PatientHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Patient History'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Drugs'),
              Tab(text: 'Reports'),
              Tab(text: 'Vitals'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DrugsTab(patient: widget.patient),
            ReportsTab(patient: widget.patient),
            VitalsTab(patient: widget.patient),
          ],
        ),
      ),
    );
  }
}

////// Widgets
// class DrugsTab extends StatelessWidget {
//   final Patient patient;

//   DrugsTab({required this.patient});

//   @override
//   Widget build(BuildContext context) {
//     // Implement the UI and functionality for the Drugs tab
//     return Container();
//   }
// }

// class ReportsTab extends StatelessWidget {
//   final Patient patient;

//   ReportsTab({required this.patient});

//   @override
//   Widget build(BuildContext context) {
//     // Implement the UI and functionality for the Reports tab
//     return Container();
//   }
// }

// class VitalsTab extends StatelessWidget {
//   final Patient patient;

//   VitalsTab({required this.patient});

//   @override
//   Widget build(BuildContext context) {
//     // Implement the UI and functionality for the Vitals tab
//     return Container();
//   }
// }
