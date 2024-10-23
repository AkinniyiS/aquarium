import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final _databaseName = "aquarium.db";
  static final _databaseVersion = 1;
  
  static final table = 'settings';
  
  static final columnId = '_id';
  static final columnFishCount = 'fish_count';
  static final columnFishSpeed = 'fish_speed';
  static final columnFishColor = 'fish_color';

  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;
  
  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnFishCount INTEGER NOT NULL,
        $columnFishSpeed REAL NOT NULL,
        $columnFishColor TEXT NOT NULL
      )
    ''');
  }

  Future<int> saveSettings(int fishCount, double fishSpeed, String fishColor) async {
    Database? db = await instance.database;
    Map<String, dynamic> row = {
      columnFishCount: fishCount,
      columnFishSpeed: fishSpeed,
      columnFishColor: fishColor
    };
    return await db!.insert(table, row);
  }

  Future<Map<String, dynamic>?> loadSettings() async {
    Database? db = await instance.database;
    List<Map<String, dynamic>> result = await db!.query(table, limit: 1, orderBy: '$columnId DESC');
    return result.isNotEmpty ? result.first : null;
  }
}
