import 'dart:async';
import 'package:medinin_doc/report_widget.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:medinin_doc/patient.dart';

class DatabaseHelper {
  static final _databaseName = "Medinin.db";
  static final _databaseVersion = 1;

  static final table = "patients";

  static final columnId = "id";
  static final columnName = "fullName";
  static final columnDob = "dob";
  static final columnGender = "gender";
  static final columnPhoneNumber = "phoneNumber";
  static final columnEmail = "email";

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    // Create patients table
    await db.execute('''
    CREATE TABLE $table (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnName TEXT NOT NULL,
      $columnDob TEXT,
      $columnGender TEXT,
      $columnPhoneNumber TEXT,
      $columnEmail TEXT
    )
  ''');
    // Create reports table
    _createReportsTable(db);
  }

  Future<int> insert(Patient patient) async {
    Database db = await instance.database;
    var res = await db.insert(table, patient.toJson());
    print('Inserted patient: $patient, Result: $res');
    return res;
  }

  Future<List<Patient>> getPatients() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) {
      return Patient.fromJson(maps[i]);
    });
  }

  Future<int> update(Patient patient) async {
    Database db = await instance.database;
    return await db.update(table, patient.toJson(),
        where: '$columnId = ?', whereArgs: [patient.id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  // reports

  // Add the following methods in your DatabaseHelper class

// Create a table for the reports
  void _createReportsTable(Database db) async {
    await db.execute('''
    CREATE TABLE reports (
      id INTEGER PRIMARY KEY,
      patient_id INTEGER,
      title TEXT,
      date TEXT,
      image_path TEXT,
      FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
    )
  ''');
  }

// Add a report to the database
  Future<int> insertReport(Report report, int patientId) async {
    Database db = await instance.database;
    return await db.insert('reports', {
      'patient_id': patientId,
      'title': report.title,
      'date': report.date.toIso8601String(),
      'image_path': report.imagePath,
    });
  }

// Get all reports for a patient
  Future<List<Report>> getReports(int patientId) async {
    Database db = await instance.database;
    final reportData = await db
        .query('reports', where: 'patient_id = ?', whereArgs: [patientId]);
    return reportData
        .map((report) => Report(
              title: report['title'] as String,
              date: DateTime.parse(report['date'] as String),
              imagePath: report['image_path'] as String?,
            ))
        .toList();
  }

// Delete a report from the database
  Future<int> deleteReport(int id) async {
    Database db = await instance.database;
    return await db.delete('reports', where: 'id = ?', whereArgs: [id]);
  }
}
