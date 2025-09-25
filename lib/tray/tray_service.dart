import 'dart:io';

class TrayService {
  factory TrayService() => _instance;
  TrayService._internal();

  static final TrayService _instance = TrayService._internal();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 在 macOS 上，我们使用原生实现，所以这里只是标记为已初始化
    if (Platform.isMacOS) {
      _isInitialized = true;
      // TrayService initialized for macOS (using native implementation)
    }
  }

  void dispose() {
    _isInitialized = false;
  }
}
