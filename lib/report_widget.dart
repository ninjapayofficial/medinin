import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medinin_doc/patient.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class ReportsTab extends StatefulWidget {
  final Patient patient;

  ReportsTab({required this.patient});

  @override
  _ReportsTabState createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  List<Report> _reports = [];
  final _dbHelper = DatabaseHelper.instance;

  Future<void> _loadReports() async {
    final reports = await _dbHelper.getReports(widget.patient.id!);
    setState(() {
      _reports = reports;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _reports.length,
        itemBuilder: (BuildContext context, int index) {
          final report = _reports[index];
          return ListTile(
            title: Text(report.title),
            subtitle: Text(DateFormat('dd MMM h:mm a').format(report.date)),
            leading: report.imagePath != null
                ? Image.file(
                    File(report.imagePath!),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : Icon(Icons.image),
            onTap: () {
              if (report.imagePath != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FullScreenImage(imagePath: report.imagePath!),
                  ),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReportDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController titleController = TextEditingController();
        return AlertDialog(
          title: Text('Add Report'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Report Title'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.getImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      print('Image picked: ${pickedFile.path}');
                      final appDocDir =
                          await getApplicationDocumentsDirectory();
                      final fileName = basename(pickedFile.path);
                      final localFilePath = join(appDocDir.path, fileName);
                      final localFile =
                          await File(pickedFile.path).copy(localFilePath);
                      print('Image copied to: ${localFile.path}');

                      final newReport = Report(
                        imagePath: localFile.path,
                        title: titleController.text,
                        date: DateTime.now(),
                        patientId: widget.patient.id!,
                      );
                      await _dbHelper.insertReport(
                          newReport, widget.patient.id!);
                      print('Report saved to database');
                      _loadReports();
                      Navigator.pop(context);
                    } else {
                      print('No image selected.');
                    }
                  },
                  child: Text('Select Image'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//
class Report {
  final String title;
  final DateTime date;
  final String? imagePath;
  final int patientId; // Add this field

  Report(
      {required this.title,
      required this.date,
      this.imagePath,
      required this.patientId}); // Add this field to the constructor
}

// Show image in full screen
class FullScreenImage extends StatelessWidget {
  final String imagePath;

  FullScreenImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Screen Image'),
      ),
      body: Center(
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
