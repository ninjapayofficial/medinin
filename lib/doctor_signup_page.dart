import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medinin_doc/patient_list_page.dart';

class DoctorSignupPage extends StatefulWidget {
  @override
  _DoctorSignupPageState createState() => _DoctorSignupPageState();
}

class _DoctorSignupPageState extends State<DoctorSignupPage> {
  // Define some variables to hold the form data
  final _formKey = GlobalKey<FormState>();
  String _fullName = '';
  String _designation = '';
  String _pincode = '';

  @override
  void initState() {
    super.initState();
    _loadDoctorDetails();
  }

  void _loadDoctorDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('fullName') ?? '';
      _designation = prefs.getString('designation') ?? '';
      _pincode = prefs.getString('pincode') ?? '';
    });
  }

  // Function to handle form submission
  void _submitForm() async {
    // Check if the form is valid
    if (_formKey.currentState!.validate()) {
      // Save the form data to the variables
      _formKey.currentState!.save();

      // Save the doctor's details to the local storage
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('fullName', _fullName);
      prefs.setString('designation', _designation);
      prefs.setString('pincode', _pincode);

      // Navigate to the patient list page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PatientListPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Signup'),
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
                    return 'Please enter your full name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _fullName = value!;
                },
                initialValue: _fullName,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Designation'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your designation';
                  }
                  return null;
                },
                onSaved: (value) {
                  _designation = value!;
                },
                initialValue: _designation,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Pincode'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your pincode';
                  }
                  return null;
                },
                onSaved: (value) {
                  _pincode = value!;
                },
                initialValue: _pincode,
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
