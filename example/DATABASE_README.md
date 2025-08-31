# Flutter SQLite 数据库使用说明

## 概述

本项目使用 `sqflite` 插件实现了完整的本地数据库功能，包含三张表：用户信息、城市信息、学校学习科目。

## 数据库结构

### 1. 城市表 (cities)
```sql
CREATE TABLE cities (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,           -- 城市名称
  province TEXT,                -- 省份
  population INTEGER,           -- 人口（万）
  area REAL,                   -- 面积（平方公里）
  description TEXT,            -- 城市描述
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2. 科目表 (subjects)
```sql
CREATE TABLE subjects (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,           -- 科目名称
  category TEXT,                -- 科目分类
  credits INTEGER,              -- 学分
  difficulty TEXT,              -- 难度等级
  description TEXT,             -- 科目描述
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 3. 用户表 (users)
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,           -- 用户姓名
  email TEXT UNIQUE NOT NULL,   -- 邮箱（唯一）
  age INTEGER,                  -- 年龄
  city_id INTEGER,              -- 所在城市ID（外键）
  subject_ids TEXT,             -- 学习科目ID列表（逗号分隔）
  phone TEXT,                   -- 电话号码
  avatar TEXT,                  -- 头像文件名
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (city_id) REFERENCES cities (id)
);
```

## 主要功能

### 基础CRUD操作
- **创建 (Create)**: `insertUser()`, `insertCity()`, `insertSubject()`
- **读取 (Read)**: `getAllUsers()`, `getUserById()`, `searchUsers()`
- **更新 (Update)**: `updateUser()`, `updateCity()`, `updateSubject()`
- **删除 (Delete)**: `deleteUser()`, `deleteCity()`, `deleteSubject()`

### 高级查询功能
- **关联查询**: `getUsersWithCityInfo()` - 获取用户及其城市信息
- **条件查询**: `getUsersByAge()`, `getUsersByCity()`, `getSubjectsByCategory()`
- **模糊搜索**: `searchUsers()`, `searchCities()`, `searchSubjects()`
- **统计查询**: `getUserCount()`, `getCityPopulationStats()`, `getSubjectCategoryStats()`

### 数据库管理
- **初始化**: 自动创建表结构和示例数据
- **升级**: 支持数据库版本升级
- **重置**: 清空所有数据或重置整个数据库

## 使用方法

### 1. 获取数据库服务实例
```dart
final DatabaseService dbService = DatabaseService();
```

### 2. 基本操作示例
```dart
// 插入用户
final userId = await dbService.insertUser({
  'name': '张三',
  'email': 'zhangsan@example.com',
  'age': 18,
  'city_id': 1,
  'subject_ids': '1,2,3',
  'phone': '13800138001',
});

// 查询所有用户
final users = await dbService.getAllUsers();

// 搜索用户
final searchResults = await dbService.searchUsers('张');

// 更新用户
await dbService.updateUser({
  'id': 1,
  'age': 19,
});

// 删除用户
await dbService.deleteUser(1);
```

### 3. 高级查询示例
```dart
// 获取用户及其城市信息
final usersWithCity = await dbService.getUsersWithCityInfo();

// 获取城市人口统计
final cityStats = await dbService.getCityPopulationStats();

// 获取科目分类统计
final subjectStats = await dbService.getSubjectCategoryStats();

// 获取用户年龄分布
final ageDistribution = await dbService.getUserAgeDistribution();
```

### 4. 关联查询示例
```dart
// 获取指定用户的科目信息
final userSubjects = await dbService.getUserSubjects(userId);

// 获取学习指定科目的用户
final usersBySubject = await dbService.getUsersBySubject(subjectId);
```

## 注意事项

1. **异步操作**: 所有数据库操作都是异步的，需要使用 `await` 关键字
2. **错误处理**: 建议使用 try-catch 包装数据库操作
3. **内存管理**: 数据库连接会自动管理，无需手动关闭
4. **数据一致性**: 外键关系确保数据完整性
5. **性能优化**: 大量数据操作时考虑使用事务

## 示例数据

数据库初始化时会自动插入以下示例数据：

### 城市数据
- 北京、上海、广州、深圳

### 科目数据
- 数学、英语、物理、化学、生物

### 用户数据
- 张三、李四、王五（包含关联的城市和科目信息）

## 扩展功能

可以根据需要添加以下功能：
- 数据导入/导出
- 数据备份/恢复
- 复杂查询优化
- 数据缓存机制
- 离线同步支持

## 技术特点

- **单例模式**: 确保数据库服务只有一个实例
- **懒加载**: 数据库连接在首次使用时才建立
- **类型安全**: 使用 Map<String, dynamic> 存储数据
- **跨平台**: 支持 iOS、Android、Web、Desktop
- **性能优化**: 使用预编译语句和索引优化查询性能
