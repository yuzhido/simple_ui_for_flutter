import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class DatabaseDemoPage extends StatefulWidget {
  const DatabaseDemoPage({super.key});

  @override
  State<DatabaseDemoPage> createState() => _DatabaseDemoPageState();
}

class _DatabaseDemoPageState extends State<DatabaseDemoPage> {
  final DatabaseService _dbService = DatabaseService();

  // 数据列表
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _subjects = [];

  // 统计数据
  int _userCount = 0;
  int _cityCount = 0;
  int _subjectCount = 0;

  // 搜索关键词
  final TextEditingController _searchController = TextEditingController();

  // 加载状态
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([_loadUsers(), _loadCities(), _loadSubjects(), _loadStatistics()]);
    } catch (e) {
      _showSnackBar('加载数据失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUsers() async {
    _users = await _dbService.getAllUsers();
    setState(() {});
  }

  Future<void> _loadCities() async {
    _cities = await _dbService.getAllCities();
    setState(() {});
  }

  Future<void> _loadSubjects() async {
    _subjects = await _dbService.getAllSubjects();
    setState(() {});
  }

  Future<void> _loadStatistics() async {
    _userCount = await _dbService.getUserCount();
    _cityCount = await _dbService.getCityCount();
    _subjectCount = await _dbService.getSubjectCount();
    setState(() {});
  }

  Future<void> _searchData() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      await _loadAllData();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([_dbService.searchUsers(keyword), _dbService.searchCities(keyword), _dbService.searchSubjects(keyword)]);

      setState(() {
        _users = results[0];
        _cities = results[1];
        _subjects = results[2];
      });
    } catch (e) {
      _showSnackBar('搜索失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addSampleData() async {
    setState(() => _isLoading = true);
    try {
      // 添加新城市
      await _dbService.insertCity({'name': '杭州', 'province': '浙江省', 'population': 1194, 'area': 16853.0, 'description': '人间天堂'});

      // 添加新科目
      await _dbService.insertSubject({'name': '计算机科学', 'category': '技术学科', 'credits': 5, 'difficulty': '困难', 'description': '计算机基础课程'});

      // 添加新用户
      await _dbService.insertUser({
        'name': '赵六',
        'email': 'zhaoliu@example.com',
        'age': 21,
        'city_id': 5, // 杭州
        'subject_ids': '1,6', // 数学,计算机科学
        'phone': '13800138004',
        'avatar': 'avatar4.jpg',
      });

      _showSnackBar('添加示例数据成功');
      await _loadAllData();
    } catch (e) {
      _showSnackBar('添加数据失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAdvancedQueries() async {
    showDialog(context: context, builder: (context) => const AdvancedQueriesDialog());
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2), backgroundColor: const Color(0xFF007AFF)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据库演示'),
        backgroundColor: const Color(0xFF007AFF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAllData, tooltip: '刷新数据'),
          IconButton(icon: const Icon(Icons.analytics), onPressed: _showAdvancedQueries, tooltip: '高级查询'),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 统计信息
                  _buildStatisticsCard(),
                  const SizedBox(height: 16),

                  // 搜索框
                  _buildSearchBar(),
                  const SizedBox(height: 16),

                  // 操作按钮
                  _buildActionButtons(),
                  const SizedBox(height: 24),

                  // 用户数据
                  _buildDataSection('用户信息', _users, _buildUserCard),
                  const SizedBox(height: 16),

                  // 城市数据
                  _buildDataSection('城市信息', _cities, _buildCityCard),
                  const SizedBox(height: 16),

                  // 科目数据
                  _buildDataSection('科目信息', _subjects, _buildSubjectCard),
                ],
              ),
            ),
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('用户', _userCount, Icons.people, Colors.blue),
            _buildStatItem('城市', _cityCount, Icons.location_city, Colors.green),
            _buildStatItem('科目', _subjectCount, Icons.book, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(hintText: '搜索用户、城市或科目...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
            onSubmitted: (_) => _searchData(),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: _searchData, child: const Text('搜索')),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: _addSampleData,
          icon: const Icon(Icons.add),
          label: const Text('添加示例数据'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _dbService.resetDatabase().then((_) => _loadAllData()),
          icon: const Icon(Icons.refresh),
          label: const Text('重置数据库'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
        ),
      ],
    );
  }

  Widget _buildDataSection<T>(String title, List<T> data, Widget Function(T item) itemBuilder) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('$title (${data.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          if (data.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('暂无数据', style: TextStyle(color: Colors.grey)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) => itemBuilder(data[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return ListTile(
      leading: CircleAvatar(child: Text(user['name']?.substring(0, 1) ?? '?')),
      title: Text(user['name'] ?? ''),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('邮箱: ${user['email'] ?? ''}'), Text('年龄: ${user['age'] ?? ''}'), Text('电话: ${user['phone'] ?? ''}')],
      ),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('编辑')]),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(children: [Icon(Icons.delete), SizedBox(width: 8), Text('删除')]),
          ),
        ],
        onSelected: (value) => _handleUserAction(value, user),
      ),
    );
  }

  Widget _buildCityCard(Map<String, dynamic> city) {
    return ListTile(
      leading: const Icon(Icons.location_city, size: 32),
      title: Text(city['name'] ?? ''),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('省份: ${city['province'] ?? ''}'), Text('人口: ${city['population'] ?? ''}万'), Text('面积: ${city['area'] ?? ''}平方公里')],
      ),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('编辑')]),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(children: [Icon(Icons.delete), SizedBox(width: 8), Text('删除')]),
          ),
        ],
        onSelected: (value) => _handleCityAction(value, city),
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    return ListTile(
      leading: const Icon(Icons.book, size: 32),
      title: Text(subject['name'] ?? ''),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('分类: ${subject['category'] ?? ''}'), Text('学分: ${subject['credits'] ?? ''}'), Text('难度: ${subject['difficulty'] ?? ''}')],
      ),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('编辑')]),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(children: [Icon(Icons.delete), SizedBox(width: 8), Text('删除')]),
          ),
        ],
        onSelected: (value) => _handleSubjectAction(value, subject),
      ),
    );
  }

  void _handleUserAction(String action, Map<String, dynamic> user) {
    // 这里可以实现编辑和删除逻辑
    _showSnackBar('用户操作: $action - ${user['name']}');
  }

  void _handleCityAction(String action, Map<String, dynamic> city) {
    _showSnackBar('城市操作: $action - ${city['name']}');
  }

  void _handleSubjectAction(String action, Map<String, dynamic> subject) {
    _showSnackBar('科目操作: $action - ${subject['name']}');
  }
}

class AdvancedQueriesDialog extends StatefulWidget {
  const AdvancedQueriesDialog({super.key});

  @override
  State<AdvancedQueriesDialog> createState() => _AdvancedQueriesDialogState();
}

class _AdvancedQueriesDialogState extends State<AdvancedQueriesDialog> {
  final DatabaseService _dbService = DatabaseService();
  List<Map<String, dynamic>> _queryResults = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('高级查询', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 16),

            // 查询按钮
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(onPressed: () => _runQuery(_dbService.getUsersWithCityInfo()), child: const Text('用户+城市信息')),
                ElevatedButton(onPressed: () => _runQuery(_dbService.getCityPopulationStats()), child: const Text('城市人口统计')),
                ElevatedButton(onPressed: () => _runQuery(_dbService.getSubjectCategoryStats()), child: const Text('科目分类统计')),
                ElevatedButton(onPressed: () => _runQuery(_dbService.getUserAgeDistribution()), child: const Text('用户年龄分布')),
              ],
            ),

            const SizedBox(height: 16),

            // 查询结果
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _queryResults.isEmpty
                  ? const Center(
                      child: Text('点击上方按钮执行查询', style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      itemCount: _queryResults.length,
                      itemBuilder: (context, index) {
                        final item = _queryResults[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: item.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text('${entry.key}: ${entry.value}', style: const TextStyle(fontSize: 14)),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runQuery(Future<List<Map<String, dynamic>>> query) async {
    setState(() => _isLoading = true);
    try {
      final results = await query;
      setState(() => _queryResults = results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('查询失败: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
