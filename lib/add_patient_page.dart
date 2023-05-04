import 'package:flutter/material.dart';
import 'package:medinin_doc/patient.dart';

// Define the AddPatientPage StatefulWidget, which accepts a callback function called onAddPatient
class AddPatientPage extends StatefulWidget {
  final Function(Patient) onAddPatient;

  AddPatientPage({required this.onAddPatient});

  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

// Define the state for the AddPatientPage StatefulWidget
class _AddPatientPageState extends State<AddPatientPage> {
  // Create a GlobalKey to access the form's state
  final _formKey = GlobalKey<FormState>();

  // Define the state variables for each form field
  String _fullName = '';
  String _dob = '';
  String _gender = '';
  String _phoneNumber = '';
  String _email = '';

  // Function to handle the form submission
  void _submitForm() {
    // If the form is valid, save the form data and create a new Patient object
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newPatient = Patient(
        fullName: _fullName,
        dob: _dob,
        gender: _gender,
        phoneNumber: _phoneNumber,
        email: _email,
        // prescriptions: [], // Add this line to pass an empty list of prescriptions
      );

      // Call the onAddPatient callback with the newPatient object
      widget.onAddPatient(newPatient);

      // Pop the current page from the navigation stack to return to the previous page
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return a Scaffold widget to create the basic structure of the page
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
                onSaved: (value) {
                  _dob = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Gender'),
                onSaved: (value) {
                  _gender = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                onSaved: (value) {
                  _phoneNumber = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                onSaved: (value) {
                  _email = value!;
                },
              ),
              // The 'Add Patient' button triggers the _submitForm function when pressed
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
