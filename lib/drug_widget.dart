import 'package:flutter/material.dart';
import 'package:medinin_doc/patient.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class DrugsTab extends StatelessWidget {
//   final Patient patient;

//   DrugsTab({required this.patient});

//   @override
//   Widget build(BuildContext context) {
//     // Implement the UI and functionality for the Drugs tab
//     return Container();
//   }
// }

class DrugsTab extends StatefulWidget {
  final Patient patient;

  DrugsTab({required this.patient});

  @override
  _DrugsTabState createState() => _DrugsTabState();
}

class _DrugsTabState extends State<DrugsTab> {
  List<Prescription> _prescriptions = [];
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _notes = '';

  Future<void> _savePrescriptions() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      'prescriptions_${widget.patient.id}',
      _prescriptions.map((prescription) {
        return '${prescription.name}|${prescription.notes}|${prescription.date.toIso8601String()}';
      }).toList(),
    );
  }

  Future<void> _loadPrescriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final prescriptionStrings =
        prefs.getStringList('prescriptions_${widget.patient.id}') ?? [];
    setState(() {
      _prescriptions = prescriptionStrings.map((prescriptionString) {
        final parts = prescriptionString.split('|');
        return Prescription(
          name: parts[0],
          notes: parts[1],
          date: DateTime.parse(parts[2]),
        );
      }).toList();
    });
  }

  // void _addPrescription() {
  //   setState(() {
  //     _prescriptions.insert(
  //         0, Prescription(name: _name, notes: _notes, date: DateTime.now()));
  //   });
  // }

  void _addPrescription() {
    setState(() {
      _prescriptions.insert(
          0, Prescription(name: _name, notes: _notes, date: DateTime.now()));
    });
    _savePrescriptions();
  }

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  // Function to show the dialog for adding a new prescription
  void _showAddPrescriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Prescription'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Prescription Name'),
                    onSaved: (value) {
                      _name = value!;
                    },
                  ),
                  SizedBox(height: 8.0), // Add some space between the fields
                  Container(
                    height: 150, // Fixed height for the container
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        border:
                            OutlineInputBorder(), // Add a border around the TextFormField
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      onSaved: (value) {
                        _notes = value!;
                      },
                    ),
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
                  _addPrescription();
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
        children: _prescriptions.map((prescription) {
          return ListTile(
            title: Text(prescription.name),
            subtitle: Text(prescription.notes),
            trailing: Text(prescription.date.toString()),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPrescriptionDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}

class Prescription {
  final String name;
  final String notes;
  final DateTime date;

  Prescription({required this.name, required this.notes, required this.date});
}
