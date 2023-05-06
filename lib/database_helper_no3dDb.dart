// import 'dart:async';
// import 'package:csv/csv.dart';
// import 'package:medinin_doc/report_widget.dart';
// import 'package:medinin_doc/vital_widget.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:medinin_doc/patient.dart';
// import 'dart:io';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;

// class DatabaseHelper {
//   static final _databaseName = "Medinin.db";
//   static final _databaseVersion = 2;

//   static final table = "patients";

//   static final columnId = "id";
//   static final columnName = "fullName";
//   static final columnDob = "dob";
//   static final columnGender = "gender";
//   static final columnPhoneNumber = "phoneNumber";
//   static final columnEmail = "email";

//   DatabaseHelper._privateConstructor();
//   static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

//   static Database? _database;
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   _initDatabase() async {
//     String path = join(await getDatabasesPath(), _databaseName);
//     return await openDatabase(path,
//         version: _databaseVersion, onCreate: _onCreate);
//   }

//   Future _onCreate(Database db, int version) async {
//     // Create patients table
//     await db.execute('''
//     CREATE TABLE $table (
//       $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
//       $columnName TEXT NOT NULL,
//       $columnDob TEXT,
//       $columnGender TEXT,
//       $columnPhoneNumber TEXT,
//       $columnEmail TEXT
//     )
//   ''');
//     // Create reports table
//     _createReportsTable(db);

//     // Create models table
//     _createModelsTable(db);
//   }

//   Future<int> insert(Patient patient) async {
//     Database db = await instance.database;
//     var res = await db.insert(table, patient.toJson());
//     print('Inserted patient: $patient, Result: $res');
//     return res;
//   }

//   Future<List<Patient>> getPatients() async {
//     Database db = await instance.database;
//     final List<Map<String, dynamic>> maps = await db.query(table);
//     return List.generate(maps.length, (i) {
//       return Patient.fromJson(maps[i]);
//     });
//   }

//   Future<int> update(Patient patient) async {
//     Database db = await instance.database;
//     return await db.update(table, patient.toJson(),
//         where: '$columnId = ?', whereArgs: [patient.id]);
//   }

//   Future<int> delete(int id) async {
//     Database db = await instance.database;
//     return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
//   }

//   // reports

// // Create a table for the reports
//   void _createReportsTable(Database db) async {
//     await db.execute('''
//     CREATE TABLE reports (
//       id INTEGER PRIMARY KEY,
//       patient_id INTEGER,
//       title TEXT,
//       date TEXT,
//       image_path TEXT,
//       FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
//     )
//   ''');
//   }

// // Add a report to the database
//   Future<int> insertReport(Report report, int patientId) async {
//     Database db = await instance.database;
//     return await db.insert('reports', {
//       'patient_id': patientId,
//       'title': report.title,
//       'date': DateFormat('yyyy-MM-ddTHH:mm:ss').format(report.date),
//       'image_path': report.imagePath ?? '',
//     });
//   }

// // Get all reports for a patient
//   Future<List<Report>> getReports(int patientId) async {
//     Database db = await instance.database;
//     final reportData = await db
//         .query('reports', where: 'patient_id = ?', whereArgs: [patientId]);
//     return reportData
//         .map((report) => Report(
//               title: report['title'] as String,
//               date: DateTime.parse(report['date'] as String),
//               imagePath: report['image_path'] as String?,
//               patientId:
//                   patientId, // Pass the patientId when creating a Report instance
//             ))
//         .toList();
//   }

// // Delete a report from the database
//   Future<int> deleteReport(int id) async {
//     Database db = await instance.database;
//     return await db.delete('reports', where: 'id = ?', whereArgs: [id]);
//   }

//   // Save a report to the database
//   Future<void> saveReportToCsv(List<Report> reports, int patientId) async {
//     final appDocDir = await getApplicationDocumentsDirectory();
//     final csvFile = File('${appDocDir.path}/reports.csv');

//     List<List<dynamic>> rows = [];

//     if (csvFile.existsSync()) {
//       // Read existing CSV file
//       final content = csvFile.readAsStringSync();
//       rows = const CsvToListConverter().convert(content);
//     }

//     // Add new report data to rows
//     for (Report report in reports) {
//       rows.add([
//         patientId,
//         report.title,
//         report.date.toIso8601String(),
//         report.imagePath ?? ''
//       ]);
//     }

//     // Convert rows to CSV format
//     final csvContent = const ListToCsvConverter().convert(rows);

//     // Write CSV content to file
//     csvFile.writeAsStringSync(csvContent);
//   }

//   // Load a report from the database
//   Future<List<Report>> loadReportsFromCsv() async {
//     final appDocDir = await getApplicationDocumentsDirectory();
//     final csvFile = File('${appDocDir.path}/reports.csv');
//     final csvString = await csvFile.readAsString();

//     final rows = const CsvToListConverter().convert(csvString);

//     return rows
//         .map((row) {
//           try {
//             return Report(
//               patientId: int.tryParse(row[0].toString()) ?? 0,
//               title: row[1].toString(),
//               date: DateTime.parse(row[2].toString()),
//               imagePath: row[3].toString().isEmpty
//                   ? null
//                   : row[3].toString(), // Update this line
//             );
//           } catch (e) {
//             print('Error parsing row: $row');
//             print('Exception: $e');
//             return null;
//           }
//         })
//         .where((report) => report != null)
//         .cast<Report>()
//         .toList();
//   }

//   // Vitals section

//   // Create vitals table
//   void _createVitalsTable(Database db) async {
//     await db.execute('''
//     CREATE TABLE vitals (
//       id INTEGER PRIMARY KEY,
//       patient_id INTEGER,
//       body_weight REAL,
//       blood_pressure TEXT,
//       temperature REAL,
//       heart_rate INTEGER,
//       sugar_level INTEGER,
//       spo2 INTEGER,
//       notes TEXT,
//       FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
//     )
//   ''');
//   }

// // Add a vital to the database
//   Future<int> insertVital(Vital vital) async {
//     Database db = await instance.database;
//     return await db.insert('vitals', vital.toJson());
//   }

// // Get all vitals for a patient
//   Future<List<Vital>> getVitals(int patientId) async {
//     Database db = await instance.database;
//     final vitalData = await db
//         .query('vitals', where: 'patient_id = ?', whereArgs: [patientId]);
//     return vitalData.map((vital) => Vital.fromJson(vital)).toList();
//   }

// // Update a vital in the database
//   Future<int> updateVital(Vital vital) async {
//     Database db = await instance.database;
//     return await db.update('vitals', vital.toJson(),
//         where: 'id = ?', whereArgs: [vital.id]);
//   }

// // Delete a vital from the database
//   Future<int> deleteVital(int id) async {
//     Database db = await instance.database;
//     return await db.delete('vitals', where: 'id = ?', whereArgs: [id]);
//   }

//   //3D Anatomy

//   // Create models table
//   void _createModelsTable(Database db) async {
//     await db.execute('''
//     CREATE TABLE models (
//       id INTEGER PRIMARY KEY,
//       name TEXT NOT NULL,
//       url TEXT NOT NULL UNIQUE,
//       local_path TEXT
//     )
//   ''');
//   }

//   // Save a 3D model to the database
//   Future<int> saveModel(String name, String url, String localPath) async {
//     Database db = await instance.database;
//     return await db.insert('models', {
//       'name': name,
//       'url': url,
//       'local_path': localPath,
//     });
//   }

//   // Get a 3D model from the database using its URL
//   Future<String?> getModelLocalPath(String modelName) async {
//     Database db = await instance.database;
//     final modelData =
//         await db.query('models', where: 'name = ?', whereArgs: [modelName]);
//     if (modelData.isNotEmpty) {
//       return modelData.first['local_path'] as String?;
//     } else {
//       return null;
//     }
//   }

//   // Download the model first to load in viewer
//   Future<String> downloadAndSaveModel(String url, String name) async {
//     // Download the 3D model
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode != 200) {
//       throw Exception('Failed to download 3D model from $url');
//     }

//     // Save the 3D model to local storage
//     final directory = await getApplicationDocumentsDirectory();
//     final modelsDirectory = Directory('${directory.path}/models');

//     // Create the models directory if it does not exist
//     if (!modelsDirectory.existsSync()) {
//       await modelsDirectory.create(recursive: true);
//     }

//     final filePath = '${modelsDirectory.path}/$name.obj';
//     final file = File(filePath);
//     await file.writeAsBytes(response.bodyBytes);

//     // Save the local path of the model in the database
//     await saveModel(name, url, filePath);

//     return filePath;
//   }
// }




/////////////////////////////////////////////////////////////////////////////////////////////////////////
///
// import 'dart:async';
// import 'dart:convert';
// import 'package:csv/csv.dart';
// import 'package:medinin_doc/report_widget.dart';
// import 'package:medinin_doc/vital_widget.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:medinin_doc/patient.dart';
// import 'dart:io';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;

// class DatabaseHelper {
//   static final _databaseName = "Medinin.db";
//   static final _databaseVersion = 1;

//   static final table = "patients";

//   static final columnId = "id";
//   static final columnName = "fullName";
//   static final columnDob = "dob";
//   static final columnGender = "gender";
//   static final columnPhoneNumber = "phoneNumber";
//   static final columnEmail = "email";

//   DatabaseHelper._privateConstructor();
//   static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

//   static Database? _database;
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   _initDatabase() async {
//     String path = join(await getDatabasesPath(), _databaseName);
//     return await openDatabase(path,
//         version: _databaseVersion, onCreate: _onCreate);
//   }

//   Future _onCreate(Database db, int version) async {
//     // Create patients table
//     await db.execute('''
//     CREATE TABLE $table (
//       $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
//       $columnName TEXT NOT NULL,
//       $columnDob TEXT,
//       $columnGender TEXT,
//       $columnPhoneNumber TEXT,
//       $columnEmail TEXT
//     )
//   ''');
//     // Create reports table
//     _createReportsTable(db);

//     // Create appointments table
//     await db.execute('''
//     CREATE TABLE appointments (
//       id INTEGER PRIMARY KEY AUTOINCREMENT,
//       patient_id INTEGER,
//       appointment_date TEXT NOT NULL,
//       appointment_time TEXT NOT NULL,
//       appointment_duration INTEGER,
//       notes TEXT,
//       FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
//     )
//   ''');
//   }

//   Future<int> insert(Patient patient) async {
//     Database db = await instance.database;
//     var res = await db.insert(table, patient.toJson());
//     print('Inserted patient: $patient, Result: $res');
//     return res;
//   }

//   Future<List<Patient>> getPatients() async {
//     Database db = await instance.database;
//     final List<Map<String, dynamic>> maps = await db.query(table);
//     return List.generate(maps.length, (i) {
//       return Patient.fromJson(maps[i]);
//     });
//   }

//   Future<int> update(Patient patient) async {
//     Database db = await instance.database;
//     return await db.update(table, patient.toJson(),
//         where: '$columnId = ?', whereArgs: [patient.id]);
//   }

//   Future<int> delete(int id) async {
//     Database db = await instance.database;
//     return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
//   }

//   // reports

// // Create a table for the reports
//   void _createReportsTable(Database db) async {
//     await db.execute('''
//     CREATE TABLE reports (
//       id INTEGER PRIMARY KEY,
//       patient_id INTEGER,
//       title TEXT,
//       date TEXT,
//       image_path TEXT,
//       FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
//     )
//   ''');
//   }

// // Add a report to the database
//   Future<int> insertReport(Report report, int patientId) async {
//     Database db = await instance.database;
//     return await db.insert('reports', {
//       'patient_id': patientId,
//       'title': report.title,
//       'date': DateFormat('yyyy-MM-ddTHH:mm:ss').format(report.date),
//       'image_path': report.imagePath ?? '',
//     });
//   }

// // Get all reports for a patient
//   Future<List<Report>> getReports(int patientId) async {
//     Database db = await instance.database;
//     final reportData = await db
//         .query('reports', where: 'patient_id = ?', whereArgs: [patientId]);
//     return reportData
//         .map((report) => Report(
//               title: report['title'] as String,
//               date: DateTime.parse(report['date'] as String),
//               imagePath: report['image_path'] as String?,
//               patientId:
//                   patientId, // Pass the patientId when creating a Report instance
//             ))
//         .toList();
//   }

// // Delete a report from the database
//   Future<int> deleteReport(int id) async {
//     Database db = await instance.database;
//     return await db.delete('reports', where: 'id = ?', whereArgs: [id]);
//   }

//   // Save a report to the database
//   Future<void> saveReportToCsv(List<Report> reports, int patientId) async {
//     final appDocDir = await getApplicationDocumentsDirectory();
//     final csvFile = File('${appDocDir.path}/reports.csv');

//     List<List<dynamic>> rows = [];

//     if (csvFile.existsSync()) {
//       // Read existing CSV file
//       final content = csvFile.readAsStringSync();
//       rows = const CsvToListConverter().convert(content);
//     }

//     // Add new report data to rows
//     for (Report report in reports) {
//       rows.add([
//         patientId,
//         report.title,
//         report.date.toIso8601String(),
//         report.imagePath ?? ''
//       ]);
//     }

//     // Convert rows to CSV format
//     final csvContent = const ListToCsvConverter().convert(rows);

//     // Write CSV content to file
//     csvFile.writeAsStringSync(csvContent);
//   }

//   // Load a report from the database
//   Future<List<Report>> loadReportsFromCsv() async {
//     final appDocDir = await getApplicationDocumentsDirectory();
//     final csvFile = File('${appDocDir.path}/reports.csv');
//     final csvString = await csvFile.readAsString();

//     final rows = const CsvToListConverter().convert(csvString);

//     return rows
//         .map((row) {
//           try {
//             return Report(
//               patientId: int.tryParse(row[0].toString()) ?? 0,
//               title: row[1].toString(),
//               date: DateTime.parse(row[2].toString()),
//               imagePath: row[3].toString().isEmpty
//                   ? null
//                   : row[3].toString(), // Update this line
//             );
//           } catch (e) {
//             print('Error parsing row: $row');
//             print('Exception: $e');
//             return null;
//           }
//         })
//         .where((report) => report != null)
//         .cast<Report>()
//         .toList();
//   }

//   // Vitals section

//   // Create vitals table
//   void _createVitalsTable(Database db) async {
//     await db.execute('''
//     CREATE TABLE vitals (
//       id INTEGER PRIMARY KEY,
//       patient_id INTEGER,
//       body_weight REAL,
//       blood_pressure TEXT,
//       temperature REAL,
//       heart_rate INTEGER,
//       sugar_level INTEGER,
//       spo2 INTEGER,
//       notes TEXT,
//       FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
//     )
//   ''');
//   }

// // Add a vital to the database
//   Future<int> insertVital(Vital vital) async {
//     Database db = await instance.database;
//     return await db.insert('vitals', vital.toJson());
//   }

// // Get all vitals for a patient
//   Future<List<Vital>> getVitals(int patientId) async {
//     Database db = await instance.database;
//     final vitalData = await db
//         .query('vitals', where: 'patient_id = ?', whereArgs: [patientId]);
//     return vitalData.map((vital) => Vital.fromJson(vital)).toList();
//   }

// // Update a vital in the database
//   Future<int> updateVital(Vital vital) async {
//     Database db = await instance.database;
//     return await db.update('vitals', vital.toJson(),
//         where: 'id = ?', whereArgs: [vital.id]);
//   }

// // Delete a vital from the database
//   Future<int> deleteVital(int id) async {
//     Database db = await instance.database;
//     return await db.delete('vitals', where: 'id = ?', whereArgs: [id]);
//   }

//   //3D Anatomy
//   Future<String> downloadAndSaveModel(String url) async {
//     // Download the 3D model
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode != 200) {
//       throw Exception('Failed to download 3D model from $url');
//     }

//     // Save the 3D model to local storage
//     final directory = await getApplicationDocumentsDirectory();
//     final filePath = '${directory.path}/model.obj';
//     final file = File(filePath);
//     await file.writeAsBytes(response.bodyBytes);

//     return filePath;
//   }

//   // Appointments
//   Future<void> saveAppointmentsToJson(
//       List<Map<String, dynamic>> appointments) async {
//     print('Appointments to save: $appointments');
//     try {
//       final appDocDir = await getApplicationDocumentsDirectory();
//       final jsonFile = File('${appDocDir.path}/appointments.json');
//       List<Map<String, dynamic>> appointmentsForJson =
//           appointments.map((appointment) {
//         return {
//           ...appointment,
//           'appointmentDate': appointment['appointmentDate'].toIso8601String(),
//           'appointmentTime': appointment['appointmentTime'].toString(),
//         };
//       }).toList();
//       String jsonString = jsonEncode(appointmentsForJson);
//       print('Encoded JSON string: $jsonString');
//       await jsonFile.writeAsString(jsonString);
//     } catch (e) {
//       print('Error in saveAppointmentsToJson: $e');
//     }
//   }

//   Future<List<Map<String, dynamic>>> loadAppointmentsFromJson() async {
//     final appDocDir = await getApplicationDocumentsDirectory();
//     final jsonFile = File('${appDocDir.path}/appointments.json');
//     if (jsonFile.existsSync()) {
//       final jsonString = await jsonFile.readAsString();
//       return List<Map<String, dynamic>>.from(jsonDecode(jsonString));
//     } else {
//       return [];
//     }
//   }

//   Future<void> deleteAppointmentFromJson(int index) async {
//     List<Map<String, dynamic>> appointments = await loadAppointmentsFromJson();
//     appointments.removeAt(index);
//     await saveAppointmentsToJson(appointments);
//   }

//   // Insert an appointment
//   Future<int> insertAppointment(Map<String, dynamic> appointment) async {
//     Database db = await instance.database;
//     return await db.insert('appointments', appointment);
//   }

// // Get all appointments for a patient
//   Future<List<Map<String, dynamic>>> getAppointments(int patientId) async {
//     Database db = await instance.database;
//     return await db
//         .query('appointments', where: 'patient_id = ?', whereArgs: [patientId]);
//   }

// // Update an appointment
//   Future<int> updateAppointment(Map<String, dynamic> appointment) async {
//     Database db = await instance.database;
//     return await db.update('appointments', appointment,
//         where: 'id = ?', whereArgs: [appointment['id']]);
//   }

// // Delete an appointment
//   Future<int> deleteAppointment(int id) async {
//     Database db = await instance.database;
//     return await db.delete('appointments', where: 'id = ?', whereArgs: [id]);
//   }
// }
