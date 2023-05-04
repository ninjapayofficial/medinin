import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medinin_doc/patient.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ReportsTab extends StatefulWidget {
  final Patient patient;

  ReportsTab({required this.patient});

  @override
  _ReportsTabState createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  List<Report> _reports = [];

  // TODO: Implement the database methods for adding, retrieving, and deleting reports

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _reports.length,
        itemBuilder: (BuildContext context, int index) {
          final report = _reports[index];
          return ListTile(
            title: Text(report.title),
            subtitle: Text(report.date.toString()),
            leading: report.imagePath != null
                ? Image.file(
                    File(report.imagePath!),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : Icon(Icons.image),
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
                      final appDocDir =
                          await getApplicationDocumentsDirectory();
                      final fileName = basename(pickedFile.path);
                      final localFilePath = join(appDocDir.path, fileName);
                      final localFile =
                          await File(pickedFile.path).copy(localFilePath);

                      final newReport = Report(
                        imagePath: localFile.path,
                        title: titleController.text,
                        date: DateTime.now(),
                      );
                      // TODO: Save the new report to the database and update the UI

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

class Report {
  final String title;
  final DateTime date;
  final String? imagePath;

  Report({required this.title, required this.date, this.imagePath});
}
