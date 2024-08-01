import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'flights.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE flights(id INTEGER PRIMARY KEY, departureCity TEXT, destinationCity TEXT, departureTime TEXT, arrivalTime TEXT)",
        );
      },
    );
  }

  Future<void> insertFlight(Map<String, String> flight) async {
    final db = await database;
    await db.insert(
      'flights',
      {
        'departureCity': flight['departureCity']!,
        'destinationCity': flight['destinationCity']!,
        'departureTime': flight['departureTime']!,
        'arrivalTime': flight['arrivalTime']!,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> flights() async {
    final db = await database;
    return await db.query('flights');
  }

  Future<void> updateFlight(int id, Map<String, String> flight) async {
    final db = await database;
    await db.update(
      'flights',
      {
        'departureCity': flight['departureCity']!,
        'destinationCity': flight['destinationCity']!,
        'departureTime': flight['departureTime']!,
        'arrivalTime': flight['arrivalTime']!,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteFlight(int id) async {
    final db = await database;
    await db.delete(
      'flights',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
