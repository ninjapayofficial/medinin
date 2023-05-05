import 'package:flutter/material.dart';
import 'package:medinin_doc/patient.dart';

import 'package:flutter/material.dart';
import 'package:medinin_doc/patient.dart';

class VitalsTab extends StatefulWidget {
  final Patient patient;

  VitalsTab({required this.patient});

  @override
  _VitalsTabState createState() => _VitalsTabState();
}

class _VitalsTabState extends State<VitalsTab> {
  List<Vital> _vitals = [];
  final _formKey = GlobalKey<FormState>();
  TextEditingController _bodyWeightController = TextEditingController();
  TextEditingController _bloodPressureController = TextEditingController();
  TextEditingController _temperatureController = TextEditingController();
  TextEditingController _heartRateController = TextEditingController();
  TextEditingController _sugarLevelController = TextEditingController();
  TextEditingController _spo2Controller = TextEditingController();
  TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load Vitals from the database or API here
  }

  void _addVital() {
    Vital newVital = Vital(
      id: 0, // This should be replaced with the actual id from the database or API
      patientId: widget.patient.id!.toInt(),
      bodyWeight: _bodyWeightController.text,
      bloodPressure: _bloodPressureController.text,
      temperature: _temperatureController.text,
      heartRate: _heartRateController.text,
      sugarLevel: _sugarLevelController.text,
      spo2: _spo2Controller.text,
      notes: _notesController.text,
    );

    setState(() {
      _vitals.insert(0, newVital);
    });

    // Save the new vital to the database or API here
  }

  void _showAddVitalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Vitals'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _bodyWeightController,
                    decoration: InputDecoration(labelText: 'Body weight'),
                  ),
                  TextFormField(
                    controller: _bloodPressureController,
                    decoration: InputDecoration(labelText: 'Blood Pressure'),
                  ),
                  TextFormField(
                    controller: _temperatureController,
                    decoration: InputDecoration(labelText: 'Temperature'),
                  ),
                  TextFormField(
                    controller: _heartRateController,
                    decoration: InputDecoration(labelText: 'Heart Rate'),
                  ),
                  TextFormField(
                    controller: _sugarLevelController,
                    decoration: InputDecoration(labelText: 'Sugar Level'),
                  ),
                  TextFormField(
                    controller: _spo2Controller,
                    decoration: InputDecoration(labelText: 'SpO2'),
                  ),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(labelText: 'Notes'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _addVital();
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: _vitals.map((vital) {
          return ListTile(
            title: Text('Vitals'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Body weight: ${vital.bodyWeight}'),
                Text('Blood Pressure: ${vital.bloodPressure}'),
                Text('Temperature: ${vital.temperature}'),
                Text('Heart Rate: ${vital.heartRate}'),
                Text('Sugar Level: ${vital.sugarLevel}'),
                Text('SpO2: ${vital.spo2}'),
                Text('Notes: ${vital.notes}'),
              ],
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVitalDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}

// class
class Vital {
  int id;
  int patientId;
  String bodyWeight;
  String bloodPressure;
  String temperature;
  String heartRate;
  String sugarLevel;
  String spo2;
  String notes;

  Vital({
    required this.id,
    required this.patientId,
    required this.bodyWeight,
    required this.bloodPressure,
    required this.temperature,
    required this.heartRate,
    required this.sugarLevel,
    required this.spo2,
    required this.notes,
  });

  factory Vital.fromJson(Map<String, dynamic> json) {
    return Vital(
      id: json['id'],
      patientId: json['patient_id'],
      bodyWeight: json['body_weight'],
      bloodPressure: json['blood_pressure'],
      temperature: json['temperature'],
      heartRate: json['heart_rate'],
      sugarLevel: json['sugar_level'],
      spo2: json['spo2'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'body_weight': bodyWeight,
      'blood_pressure': bloodPressure,
      'temperature': temperature,
      'heart_rate': heartRate,
      'sugar_level': sugarLevel,
      'spo2': spo2,
      'notes': notes,
    };
  }
}
