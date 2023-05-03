import 'package:flutter/material.dart';
import 'package:medinin_v1/patient.dart';

class AddPatientPage extends StatefulWidget {
  final Function(Patient) onAddPatient;

  AddPatientPage({required this.onAddPatient});

  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  String _fullName = '';
  String _dob = '';
  String _gender = '';
  String _phoneNumber = '';
  String _email = '';

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newPatient = Patient(
        fullName: _fullName,
        dob: _dob,
        gender: _gender,
        phoneNumber: _phoneNumber,
        email: _email,
      );

      widget.onAddPatient(newPatient);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Patient'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the patient\'s full name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _fullName = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Date of Birth'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the patient\'s date of birth';
                  }
                  return null;
                },
                onSaved: (value) {
                  _dob = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Gender'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the patient\'s gender';
                  }
                  return null;
                },
                onSaved: (value) {
                  _gender = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the patient\'s phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phoneNumber = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the patient\'s email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Patient'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
