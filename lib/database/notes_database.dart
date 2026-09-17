import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

class NotesDatabase {
  static final NotesDatabase instance = NotesDatabase._init();

  NotesDatabase._init();

  static sqflite.Database? _database;

  Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<sqflite.Database> _initDB(String filePath) async {
    final dbPath = await sqflite.getDatabasesPath();
    final path = join(dbPath, filePath);
    return await sqflite.openDatabase(
        path,
        version: 1,
        onCreate: _createDB
    );
  }

  Future _createDB(sqflite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,   
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        color INTEGER NOT NULL DEFAULT 0
         )
         '''
    );
  }

  Future<int> addNote(
      String title,
      String description,
      String data,
      int color,
      ) async {
    final db = await instance.database;
    return await db.insert('notes', {
      'title': title,
      'description': description,
      'date': data,
      'color': color,
    }
    );
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await instance.database;
    return await db.query('notes', orderBy: 'date DESC');
  }

  Future<int> updateNote(String title, String description, String data,
      int id, int color) async {
    final db = await instance.database;
    return await db.update('notes', {
      'title': title,
      'description': description,
      'date': data,
      'color': color,
    },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete('notes',
        where: 'id = ?',
        whereArgs: [id],
    );
  }
}
