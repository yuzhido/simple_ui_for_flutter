# LoadingData 加载指示器组件

一个功能丰富的Flutter加载指示器组件，支持多种加载动画类型、尺寸、颜色自定义和覆盖层模式。

## 示例展示

<img src="Snipaste_2025-10-15_14-29-10.png" width="300" alt="圆形加载器" />
<img src="Snipaste_2025-10-15_14-29-25.png" width="300" alt="线性进度条" />
<img src="Snipaste_2025-10-15_14-29-40.png" width="300" alt="点状动画加载" />

## 功能特性

- 🔄 **多种加载类型**：圆形、线性、点状、旋转器四种动画效果
- 📏 **三种尺寸规格**：小、中、大三种预设尺寸
- 🎨 **完全自定义样式**：支持颜色、背景色、描边宽度等自定义
- 📊 **进度指示**：支持显示具体的加载进度
- 💬 **消息显示**：可显示加载状态文字，支持自定义样式
- 🎭 **覆盖层模式**：全屏覆盖层加载效果
- ⚡ **流畅动画**：基于Flutter动画系统，性能优异

## 基础使用

### 简单加载器

```dart
import 'package:simple_ui/simple_ui.dart';

// 基础圆形加载器
LoadingData(
  message: '正在加载...',
)
```

### 不同类型的加载器

```dart
// 圆形加载器
LoadingData(
  type: LoadingType.circular,
  message: '圆形加载',
)

// 线性进度条
LoadingData(
  type: LoadingType.linear,
  message: '线性加载',
)

// 点状动画
LoadingData(
  type: LoadingType.dots,
  message: '点状加载',
)

// 旋转器动画
LoadingData(
  type: LoadingType.spinner,
  message: '旋转加载',
)
```

### 不同尺寸

```dart
// 小尺寸
LoadingData(
  size: LoadingSize.small,
  message: '小尺寸加载',
)

// 中尺寸（默认）
LoadingData(
  size: LoadingSize.medium,
  message: '中尺寸加载',
)

// 大尺寸
LoadingData(
  size: LoadingSize.large,
  message: '大尺寸加载',
)
```

## 高级用法

### 自定义颜色和样式

```dart
LoadingData(
  color: Colors.blue,
  backgroundColor: Colors.blue.withOpacity(0.1),
  strokeWidth: 3.0,
  message: '自定义颜色',
  messageStyle: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
)
```

### 进度指示器

```dart
class _MyWidgetState extends State<MyWidget> {
  double _progress = 0.0;
  
  void _startProgress() {
    // 模拟进度更新
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress += 0.05;
      });
      if (_progress >= 1.0) {
        timer.cancel();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 圆形进度指示器
        LoadingData(
          type: LoadingType.circular,
          progress: _progress,
          message: '进度: ${(_progress * 100).toInt()}%',
        ),
        
        // 线性进度指示器
        LoadingData(
          type: LoadingType.linear,
          progress: _progress,
          message: '上传进度: ${(_progress * 100).toInt()}%',
        ),
        
        ElevatedButton(
          onPressed: _startProgress,
          child: Text('开始进度演示'),
        ),
      ],
    );
  }
}
```

### 覆盖层加载

```dart
class _MyWidgetState extends State<MyWidget> {
  bool _isLoading = false;
  
  void _showOverlayLoading() {
    setState(() {
      _isLoading = true;
    });
    
    // 模拟异步操作
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 主要内容
          Center(
            child: ElevatedButton(
              onPressed: _showOverlayLoading,
              child: Text('显示覆盖层加载'),
            ),
          ),
          
          // 覆盖层加载
          if (_isLoading)
            LoadingData(
              overlay: true,
              message: '正在处理，请稍候...',
              overlayColor: Colors.black54,
              color: Colors.white,
              messageStyle: TextStyle(color: Colors.white),
            ),
        ],
      ),
    );
  }
}
```

### 自定义布局

```dart
LoadingData(
  message: '数据加载中...',
  padding: EdgeInsets.all(20),
  mainAxisAlignment: MainAxisAlignment.start,
  crossAxisAlignment: CrossAxisAlignment.start,
)
```

### 无消息显示

```dart
LoadingData(
  showMessage: false,
  color: Colors.grey,
)
```

## 实际应用场景

### 页面加载

```dart
class DataPage extends StatefulWidget {
  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  bool _isLoading = true;
  List<String> _data = [];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    // 模拟网络请求
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _data = ['数据1', '数据2', '数据3'];
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('数据页面')),
      body: _isLoading
          ? LoadingData(
              message: '正在加载数据...',
              color: Theme.of(context).primaryColor,
            )
          : ListView.builder(
              itemCount: _data.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(_data[index]));
              },
            ),
    );
  }
}
```

### 文件上传进度

```dart
class FileUploadWidget extends StatefulWidget {
  @override
  _FileUploadWidgetState createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  double _uploadProgress = 0.0;
  bool _isUploading = false;
  
  Future<void> _uploadFile() async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });
    
    // 模拟文件上传进度
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(Duration(milliseconds: 100));
      setState(() {
        _uploadProgress = i / 100.0;
      });
    }
    
    setState(() {
      _isUploading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isUploading)
          LoadingData(
            type: LoadingType.linear,
            progress: _uploadProgress,
            message: '上传进度: ${(_uploadProgress * 100).toInt()}%',
            color: Colors.green,
          ),
        
        ElevatedButton(
          onPressed: _isUploading ? null : _uploadFile,
          child: Text(_isUploading ? '上传中...' : '开始上传'),
        ),
      ],
    );
  }
}
```

## API 参考

### LoadingData 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `message` | `String?` | `null` | 加载提示消息 |
| `type` | `LoadingType` | `LoadingType.circular` | 加载器类型 |
| `size` | `LoadingSize` | `LoadingSize.medium` | 加载器尺寸 |
| `color` | `Color?` | `null` | 主要颜色，默认使用主题色 |
| `backgroundColor` | `Color?` | `null` | 背景颜色 |
| `strokeWidth` | `double?` | `null` | 描边宽度 |
| `showMessage` | `bool` | `true` | 是否显示消息 |
| `messageStyle` | `TextStyle?` | `null` | 消息文字样式 |
| `padding` | `EdgeInsetsGeometry?` | `null` | 内边距 |
| `mainAxisAlignment` | `MainAxisAlignment` | `MainAxisAlignment.center` | 主轴对齐方式 |
| `crossAxisAlignment` | `CrossAxisAlignment` | `CrossAxisAlignment.center` | 交叉轴对齐方式 |
| `overlay` | `bool` | `false` | 是否显示为覆盖层 |
| `overlayColor` | `Color?` | `null` | 覆盖层背景色 |
| `progress` | `double?` | `null` | 进度值（0.0-1.0） |

### 枚举类型

#### LoadingType 加载类型
- `LoadingType.circular` - 圆形加载器
- `LoadingType.linear` - 线性进度条
- `LoadingType.dots` - 点状动画
- `LoadingType.spinner` - 旋转器动画

#### LoadingSize 尺寸规格
- `LoadingSize.small` - 小尺寸（20px）
- `LoadingSize.medium` - 中尺寸（40px）
- `LoadingSize.large` - 大尺寸（60px）

## 尺寸规格详情

| 尺寸 | 指示器大小 | 间距 | 适用场景 |
|------|------------|------|----------|
| Small | 20px | 8px | 按钮内、小组件 |
| Medium | 40px | 16px | 一般页面加载 |
| Large | 60px | 24px | 全屏加载、重要操作 |

## 动画效果说明

- **Circular**: 经典的圆形旋转动画，支持进度显示
- **Linear**: 水平进度条，适合显示具体进度
- **Dots**: 三个点的波浪动画，轻量级效果
- **Spinner**: 自定义旋转器，现代化设计

## 最佳实践

1. **选择合适的类型**: 
   - 不确定时长用 `circular` 或 `dots`
   - 有具体进度用 `linear` 或带 `progress` 的 `circular`

2. **合理使用覆盖层**: 
   - 重要操作或防止用户操作时使用 `overlay: true`
   - 注意覆盖层的颜色对比度

3. **消息提示**: 
   - 提供有意义的加载消息
   - 避免过长的文字

4. **性能考虑**: 
   - 组件会自动管理动画生命周期
   - 不需要时及时移除加载器

## 注意事项

- 组件内部自动管理动画控制器的生命周期
- 覆盖层模式会阻止用户交互，请谨慎使用
- 进度值应在 0.0 到 1.0 之间
- 自定义颜色时注意与背景的对比度
- 点状和旋转器动画不支持进度显示