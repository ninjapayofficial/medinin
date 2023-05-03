import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:medinin_v1/patient.dart';

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
  }

  Future<int> insert(Patient patient) async {
    Database db = await instance.database;
    var res = await db.insert(table, patient.toJson());
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
}
