import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

// DatabaseHelper is a singleton managing all SQLite operations
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Private constructor for singleton pattern
  DatabaseHelper._internal();

  // Factory constructor returns the same instance every time
  factory DatabaseHelper() => _instance;

  // Lazy initialization of the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database file and create the tasks table
  Future<Database> _initDatabase() async {
    // Get the default database directory path
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todo_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTable,
    );
  }

  // SQL to create the tasks table with required columns
  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        title       TEXT    NOT NULL,
        description TEXT    NOT NULL,
        isComplete  INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // INSERT a new task and return its generated id
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // SELECT all tasks ordered by id descending (newest first)
  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('tasks', orderBy: 'id DESC');
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // SELECT only completed tasks (isComplete = 1)
  Future<List<Task>> getCompletedTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'isComplete = ?',
      whereArgs: [1],
      orderBy: 'id DESC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // SELECT only pending tasks (isComplete = 0)
  Future<List<Task>> getPendingTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'isComplete = ?',
      whereArgs: [0],
      orderBy: 'id DESC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // UPDATE an existing task by its id
  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // DELETE a single task by its id
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE all completed tasks at once (bonus feature)
  Future<int> deleteCompletedTasks() async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'isComplete = ?',
      whereArgs: [1],
    );
  }

  // Close the database connection
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
