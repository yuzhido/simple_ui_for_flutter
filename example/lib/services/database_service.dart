import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // 尝试使用文件数据库，如果失败则使用内存数据库
    try {
      // 获取数据库文件路径
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'school_database.db');

      // 创建/打开数据库
      return await openDatabase(path, version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
    } catch (e) {
      print('文件数据库初始化失败，使用内存数据库: $e');
      // 如果失败，使用内存数据库作为备选
      return await openDatabase(inMemoryDatabasePath, version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // 创建城市表
    await db.execute('''
      CREATE TABLE cities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        province TEXT,
        population INTEGER,
        area REAL,
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 创建科目表
    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT,
        credits INTEGER,
        difficulty TEXT,
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 创建用户表
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        age INTEGER,
        city_id INTEGER,
        subject_ids TEXT,
        phone TEXT,
        avatar TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (city_id) REFERENCES cities (id)
      )
    ''');

    // 插入一些示例数据
    await _insertSampleData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 数据库升级逻辑
    if (oldVersion < 2) {
      // 可以在这里添加新的表或修改现有表结构
    }
  }

  Future<void> _insertSampleData(Database db) async {
    // 插入示例城市数据
    await db.insert('cities', {'name': '北京', 'province': '北京市', 'population': 2154, 'area': 16410.0, 'description': '中华人民共和国首都'});
    await db.insert('cities', {'name': '上海', 'province': '上海市', 'population': 2424, 'area': 6340.0, 'description': '国际化大都市'});
    await db.insert('cities', {'name': '广州', 'province': '广东省', 'population': 1531, 'area': 7434.0, 'description': '花城'});
    await db.insert('cities', {'name': '深圳', 'province': '广东省', 'population': 1344, 'area': 1997.0, 'description': '创新之城'});

    // 插入示例科目数据
    await db.insert('subjects', {'name': '数学', 'category': '基础学科', 'credits': 4, 'difficulty': '中等', 'description': '数学基础课程'});
    await db.insert('subjects', {'name': '英语', 'category': '语言学科', 'credits': 3, 'difficulty': '简单', 'description': '英语基础课程'});
    await db.insert('subjects', {'name': '物理', 'category': '基础学科', 'credits': 4, 'difficulty': '困难', 'description': '物理基础课程'});
    await db.insert('subjects', {'name': '化学', 'category': '基础学科', 'credits': 3, 'difficulty': '中等', 'description': '化学基础课程'});
    await db.insert('subjects', {'name': '生物', 'category': '基础学科', 'credits': 3, 'difficulty': '简单', 'description': '生物基础课程'});

    // 插入示例用户数据
    await db.insert('users', {
      'name': '张三',
      'email': 'zhangsan@example.com',
      'age': 18,
      'city_id': 1, // 北京
      'subject_ids': '1,2,3', // 数学,英语,物理
      'phone': '13800138001',
      'avatar': 'avatar1.jpg',
    });
    await db.insert('users', {
      'name': '李四',
      'email': 'lisi@example.com',
      'age': 19,
      'city_id': 2, // 上海
      'subject_ids': '2,4,5', // 英语,化学,生物
      'phone': '13800138002',
      'avatar': 'avatar2.jpg',
    });
    await db.insert('users', {
      'name': '王五',
      'email': 'wangwu@example.com',
      'age': 20,
      'city_id': 3, // 广州
      'subject_ids': '1,3,4', // 数学,物理,化学
      'phone': '13800138003',
      'avatar': 'avatar3.jpg',
    });
  }

  // ==================== 城市相关操作 ====================
  Future<int> insertCity(Map<String, dynamic> city) async {
    final db = await database;
    return await db.insert('cities', city);
  }

  Future<List<Map<String, dynamic>>> getAllCities() async {
    final db = await database;
    return await db.query('cities', orderBy: 'name ASC');
  }

  Future<List<Map<String, dynamic>>> searchCities(String keyword) async {
    final db = await database;
    return await db.query(
      'cities',
      where: 'name LIKE ? OR province LIKE ? OR description LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],
      orderBy: 'name ASC',
    );
  }

  Future<Map<String, dynamic>?> getCityById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query('cities', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateCity(Map<String, dynamic> city) async {
    final db = await database;
    return await db.update('cities', city, where: 'id = ?', whereArgs: [city['id']]);
  }

  Future<int> deleteCity(int id) async {
    final db = await database;
    return await db.delete('cities', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== 科目相关操作 ====================
  Future<int> insertSubject(Map<String, dynamic> subject) async {
    final db = await database;
    return await db.insert('subjects', subject);
  }

  Future<List<Map<String, dynamic>>> getAllSubjects() async {
    final db = await database;
    return await db.query('subjects', orderBy: 'name ASC');
  }

  Future<List<Map<String, dynamic>>> searchSubjects(String keyword) async {
    final db = await database;
    return await db.query(
      'subjects',
      where: 'name LIKE ? OR category LIKE ? OR description LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],
      orderBy: 'name ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getSubjectsByCategory(String category) async {
    final db = await database;
    return await db.query('subjects', where: 'category = ?', whereArgs: [category], orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> getSubjectById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query('subjects', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateSubject(Map<String, dynamic> subject) async {
    final db = await database;
    return await db.update('subjects', subject, where: 'id = ?', whereArgs: [subject['id']]);
  }

  Future<int> deleteSubject(int id) async {
    final db = await database;
    return await db.delete('subjects', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== 用户相关操作 ====================
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> searchUsers(String keyword) async {
    final db = await database;
    return await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ? OR phone LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],
      orderBy: 'name ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getUsersByAge(int minAge, int maxAge) async {
    final db = await database;
    return await db.query('users', where: 'age BETWEEN ? AND ?', whereArgs: [minAge, maxAge], orderBy: 'age ASC');
  }

  Future<List<Map<String, dynamic>>> getUsersByCity(int cityId) async {
    final db = await database;
    return await db.query('users', where: 'city_id = ?', whereArgs: [cityId], orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.update('users', user, where: 'id = ?', whereArgs: [user['id']]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== 关联查询操作 ====================
  Future<List<Map<String, dynamic>>> getUsersWithCityInfo() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        u.id, u.name, u.email, u.age, u.phone, u.avatar, u.created_at,
        c.name as city_name, c.province, c.population, c.area
      FROM users u
      LEFT JOIN cities c ON u.city_id = c.id
      ORDER BY u.created_at DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getUserSubjects(int userId) async {
    final db = await database;
    // 先获取用户的科目ID列表
    final user = await getUserById(userId);
    if (user == null || user['subject_ids'] == null) return [];

    final subjectIds = user['subject_ids'].toString().split(',');
    if (subjectIds.isEmpty) return [];

    // 构建IN查询的占位符
    final placeholders = List.filled(subjectIds.length, '?').join(',');

    return await db.rawQuery('''
      SELECT * FROM subjects 
      WHERE id IN ($placeholders)
      ORDER BY name ASC
    ''', subjectIds);
  }

  Future<List<Map<String, dynamic>>> getUsersBySubject(int subjectId) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT 
        u.id, u.name, u.email, u.age, u.phone, u.avatar,
        c.name as city_name, c.province
      FROM users u
      LEFT JOIN cities c ON u.city_id = c.id
      WHERE u.subject_ids LIKE ?
      ORDER BY u.name ASC
    ''',
      ['%$subjectId%'],
    );
  }

  // ==================== 统计查询操作 ====================
  Future<int> getUserCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return result.first['count'] as int;
  }

  Future<int> getCityCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM cities');
    return result.first['count'] as int;
  }

  Future<int> getSubjectCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM subjects');
    return result.first['count'] as int;
  }

  Future<List<Map<String, dynamic>>> getCityPopulationStats() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        province,
        COUNT(*) as city_count,
        SUM(population) as total_population,
        AVG(population) as avg_population
      FROM cities
      GROUP BY province
      ORDER BY total_population DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getSubjectCategoryStats() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        category,
        COUNT(*) as subject_count,
        AVG(credits) as avg_credits
      FROM subjects
      GROUP BY category
      ORDER BY subject_count DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getUserAgeDistribution() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        CASE 
          WHEN age < 18 THEN '未成年'
          WHEN age BETWEEN 18 AND 25 THEN '青年'
          WHEN age BETWEEN 26 AND 35 THEN '中年'
          ELSE '老年'
        END as age_group,
        COUNT(*) as user_count
      FROM users
      GROUP BY age_group
      ORDER BY user_count DESC
    ''');
  }

  // ==================== 数据库管理操作 ====================
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('users');
    await db.delete('cities');
    await db.delete('subjects');
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.close();
    _database = null;

    // 重新初始化数据库
    await database;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
