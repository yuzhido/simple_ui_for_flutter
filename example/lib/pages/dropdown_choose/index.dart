import 'package:flutter/material.dart';
import 'package:simple_ui/simple_ui.dart';
import '../../api/user_api.dart';
import '../../api/models/user.dart';

class DropdownSelectPage extends StatefulWidget {
  const DropdownSelectPage({super.key});
  @override
  State<DropdownSelectPage> createState() => _DropdownSelectPageState();
}

class _DropdownSelectPageState extends State<DropdownSelectPage> {
  // 下拉选择数据
  final List<SelectData<String>> singleChoose = const [
    SelectData(label: '选项1', value: '1', data: 'data1'),
    SelectData(label: '选项2', value: '2', data: 'data2'),
    SelectData(label: '选项3', value: '3', data: 'data3'),
    SelectData(label: '选项4', value: '4', data: 'data4'),
    SelectData(label: '选项5', value: '5', data: 'data5'),
    SelectData(label: '苹果', value: 'apple', data: 'fruit'),
    SelectData(label: '香蕉', value: 'banana', data: 'fruit'),
    SelectData(label: '橙子', value: 'orange', data: 'fruit'),
    SelectData(label: '葡萄', value: 'grape', data: 'fruit'),
    SelectData(label: '西瓜', value: 'watermelon', data: 'fruit'),
  ];

  // 当前选中的值
  SelectData<String>? selectedValue;
  SelectData<String>? filteredValue;
  SelectData<User>? remoteSelectedValue;
  SelectData<User>? remoteWithDefaultValue;
  List<SelectData<String>> localMultipleSelected = [];
  List<SelectData<User>> remoteMultipleSelected = [];

  @override
  void initState() {
    super.initState();
    // 设置默认选中第一个选项
    selectedValue = singleChoose.first;

    // 设置远程搜索的默认值（模拟编辑模式）
    remoteWithDefaultValue = SelectData<User>(
      label: '张三_2 (19岁)',
      value: '68ca1dee02cf5e1946e341d7',
      data: User(id: '68ca1dee02cf5e1946e341d7', name: '张三_2', age: 19, address: '淄博市新城区,镇区,区区,县区,市区691路34号', school: '中国传媒大学', birthday: '2006-04-15T00:00:00.000Z'),
    );

    // 设置本地多选的默认值
    localMultipleSelected = [
      singleChoose[0], // 选项1
      singleChoose[5], // 苹果
    ];

    // 设置远程多选的默认值
    remoteMultipleSelected = [
      SelectData<User>(
        label: '李四_2 (50岁)',
        value: '68ca1dee02cf5e1946e341d9',
        data: User(id: '68ca1dee02cf5e1946e341d9', name: '李四_2', age: 50, address: '重庆市西城市,镇市,区市,县市,市市686街705号', school: '北京师范大学', birthday: '1975-01-10T00:00:00.000Z'),
      ),
      SelectData<User>(
        label: '范五十 (52岁)',
        value: '68ca1dee02cf5e1946e341d5',
        data: User(id: '68ca1dee02cf5e1946e341d5', name: '范五十', age: 52, address: '合肥市西城市,镇市,区市,县市,市市104路295号', school: '西南大学', birthday: '1973-04-20T00:00:00.000Z'),
      ),
    ];
  }

  // 远程搜索用户数据
  Future<List<SelectData<User>>> _fetchRemoteUsers(String? keyword) async {
    try {
      final response = await UserApi.getUserList(page: 1, limit: 20, name: keyword?.isNotEmpty == true ? keyword : null);

      // 检查响应结构
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        // 检查data是直接数组还是包含users字段的Map
        List<dynamic> usersData;
        if (data is List) {
          // data直接是用户数组
          usersData = data;
        } else if (data is Map<String, dynamic> && data['users'] is List) {
          // data是Map，包含users字段
          usersData = data['users'];
        } else {
          return [];
        }

        if (usersData.isEmpty) {
          return [];
        }

        return usersData.map((userJson) {
          try {
            if (userJson is Map<String, dynamic>) {
              final user = User.fromJson(userJson);
              return SelectData<User>(label: '${user.name ?? '未知用户'} (${user.age ?? '未知年龄'}岁)', value: user.id ?? '', data: user);
            } else {
              return SelectData<User>(
                label: '数据格式错误',
                value: 'error',
                data: User(name: '数据格式错误', age: 0, address: '', school: '', birthday: ''),
              );
            }
          } catch (e) {
            return SelectData<User>(
              label: '解析失败的用户',
              value: 'error',
              data: User(name: '解析失败', age: 0, address: '', school: '', birthday: ''),
            );
          }
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('下拉选择组件示例'), backgroundColor: const Color(0xFF007AFF), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DropdownChoose 组件使用示例', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // 基础单选示例
            _buildSectionTitle('1. 基础单选'),
            const SizedBox(height: 8),
            Text(
              '当前选择: ${selectedValue?.label ?? '未选择'}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            DropdownChoose<String>(
              list: singleChoose,
              defaultValue: selectedValue,
              onSingleSelected: (val) {
                setState(() {
                  selectedValue = val;
                });
                _showToast('选择了：${val.label}');
              },
            ),
            const SizedBox(height: 24),

            // 本地搜索过滤示例
            _buildSectionTitle('2. 本地搜索过滤（filterable: true）'),
            const SizedBox(height: 8),
            Text(
              '当前选择: ${filteredValue?.label ?? '未选择'}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            DropdownChoose<String>(
              list: singleChoose,
              filterable: true,
              defaultValue: filteredValue,
              onSingleSelected: (val) {
                setState(() {
                  filteredValue = val;
                });
                _showToast('过滤选择了：${val.label}');
              },
            ),
            const SizedBox(height: 24),

            // 远程搜索示例
            _buildSectionTitle('3. 远程搜索（remote: true）'),
            const SizedBox(height: 8),
            Text(
              '当前选择: ${remoteSelectedValue?.label ?? '未选择'}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            DropdownChoose<User>(
              remote: true,
              remoteFetch: _fetchRemoteUsers,
              defaultValue: remoteSelectedValue,
              showAdd: true,
              onAdd: (val) {
                print(val);
              },
              onSingleSelected: (val) {
                setState(() {
                  remoteSelectedValue = val;
                });
                _showToast('远程搜索选择了：${val.label}');
              },
            ),
            const SizedBox(height: 24),

            // 远程搜索 + 默认值示例
            _buildSectionTitle('4. 远程搜索 + 默认值（编辑模式）'),
            const SizedBox(height: 8),
            Text(
              '当前选择: ${remoteWithDefaultValue?.label ?? '未选择'}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            DropdownChoose<User>(
              remote: true,
              remoteFetch: _fetchRemoteUsers,
              defaultValue: remoteWithDefaultValue,
              onSingleSelected: (val) {
                setState(() {
                  remoteWithDefaultValue = val;
                });
                _showToast('编辑模式选择了：${val.label}');
              },
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFF9800)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '编辑模式说明：',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                  ),
                  SizedBox(height: 4),
                  Text('• 模拟编辑场景，预设了默认选中的用户'),
                  Text('• 即使远程搜索没有返回这个用户，也能正确显示'),
                  Text('• 适用于编辑表单时的数据回显'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 本地数据多选示例
            _buildSectionTitle('5. 本地数据多选（multiple: true）'),
            const SizedBox(height: 8),
            Text(
              '当前选择: ${localMultipleSelected.isEmpty ? '未选择' : localMultipleSelected.map((e) => e.label).join(', ')}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            DropdownChoose<String>(
              list: singleChoose,
              multiple: true,
              defaultValue: localMultipleSelected,
              onMultipleSelected: (vals) {
                setState(() {
                  localMultipleSelected = vals;
                });
                _showToast('本地多选选择了：${vals.map((e) => e.label).join(', ')}');
              },
            ),
            const SizedBox(height: 24),

            // 远程多选示例
            _buildSectionTitle('6. 远程多选（remote: true, multiple: true）'),
            const SizedBox(height: 8),
            Text(
              '当前选择: ${remoteMultipleSelected.isEmpty ? '未选择' : remoteMultipleSelected.map((e) => e.label).join(', ')}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            DropdownChoose<User>(
              remote: true,
              remoteFetch: _fetchRemoteUsers,
              multiple: true,
              defaultValue: remoteMultipleSelected,
              onMultipleSelected: (vals) {
                setState(() {
                  remoteMultipleSelected = vals;
                });
                _showToast('远程多选选择了：${vals.map((e) => e.label).join(', ')}');
              },
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF4CAF50)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '多选模式说明：',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                  ),
                  SizedBox(height: 4),
                  Text('• 支持同时选择多个选项'),
                  Text('• 显示已选择的项目数量'),
                  Text('• 可以查看和移除已选择的项目'),
                  Text('• 支持本地和远程数据源'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 使用说明
            _buildSectionTitle('使用说明'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2196F3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '组件特性：',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
                  ),
                  SizedBox(height: 8),
                  Text('• list: 传入选项数据列表（本地模式）'),
                  Text('• remote: 启用远程搜索功能'),
                  Text('• remoteFetch: 远程数据获取函数'),
                  Text('• multiple: 启用多选模式'),
                  Text('• filterable: 启用本地搜索过滤功能'),
                  Text('• defaultValue: 设置默认选中值（单选传入SelectData，多选传入List）'),
                  Text('• onSingleSelected: 单选回调函数'),
                  Text('• onMultipleSelected: 多选回调函数'),
                  Text('• showAdd: 显示"去新增"入口'),
                  Text('• onAdd: 点击新增的回调函数'),
                  Text('• 支持自定义样式和交互'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
    );
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF007AFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
