import Cocoa
import FlutterMacOS

@main
@objc class AppDelegate: FlutterAppDelegate {
  var statusItem: NSStatusItem?
  var popover: NSPopover?
  var mainWindow: NSWindow?
  var isWindowVisible = false
  var eventMonitor: Any?

  override func applicationWillFinishLaunching(_ notification: Notification) {
    super.applicationWillFinishLaunching(notification)

    NSLog("AppDelegate applicationWillFinishLaunching called")

    // 立即隐藏 Dock 图标，防止窗口显示
    NSApp.setActivationPolicy(.accessory)

    // 立即创建状态栏项目
    setupStatusBar()

    // 延迟获取窗口引用并确保隐藏
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      // 获取主窗口引用并立即隐藏
      if let window = NSApp.windows.first {
        self.mainWindow = window
        window.orderOut(nil)  // 立即隐藏，不显示动画
        self.isWindowVisible = false
        NSLog("Main window found and hidden immediately")
      } else {
        NSLog("No main window found")
      }
    }
  }

  func setupStatusBar() {
    // 创建状态栏项目
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    guard let statusItem = statusItem else {
      NSLog("Failed to create status item")
      return
    }

    guard let button = statusItem.button else {
      NSLog("Failed to get status item button")
      return
    }

    // 设置按钮属性
    button.title = "🗓️"  // 使用日历图标
    button.font = NSFont.systemFont(ofSize: 16)
    button.action = #selector(statusBarButtonClicked)
    button.target = self
    button.toolTip = "Tiny Chinese Lunar Calendar - Click to show/hide"

    // 强制显示
    statusItem.isVisible = true

    NSLog("Status bar item created with calendar icon")
  }
  @objc func statusBarButtonClicked() {
    NSLog("Status bar button clicked")

    // 切换窗口显示状态
    if isWindowVisible {
      hideMainWindow()
    } else {
      showMainWindow()
    }
  }

  func hideMainWindow() {
    if let window = mainWindow {
      window.orderOut(nil)
      isWindowVisible = false

      // 移除事件监听器
      if let monitor = eventMonitor {
        NSEvent.removeMonitor(monitor)
        eventMonitor = nil
      }

      NSLog("Main window hidden")
    }
  }

  func showMainWindow() {
    guard let window = mainWindow else {
      NSLog("No main window to show")
      return
    }

    // 定位窗口到菜单栏图标下方
    positionWindowBelowStatusItem(window)

    // 显示窗口
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
    isWindowVisible = true

    // 添加点击外部隐藏窗口的功能
    setupWindowClickOutsideHandler()

    NSLog("Main window shown")
  }

  func positionWindowBelowStatusItem(_ window: NSWindow) {
    guard let statusItem = statusItem,
          let button = statusItem.button,
          let buttonWindow = button.window else {
      NSLog("Failed to get status item components for positioning")
      return
    }

    // 获取状态栏按钮的位置（屏幕坐标）
    let buttonFrame = buttonWindow.convertToScreen(button.frame)

    // 找到包含状态栏按钮的屏幕
    let targetScreen = findScreenContaining(point: buttonFrame.origin) ?? NSScreen.main

    guard let screen = targetScreen else {
      NSLog("No screen found for positioning")
      return
    }

    let screenFrame = screen.frame
    let windowSize = window.frame.size

    // 计算窗口应该显示的位置（在按钮下方，居中对齐）
    let newX = buttonFrame.midX - windowSize.width / 2
    let newY = buttonFrame.minY - windowSize.height - 5  // 5像素间距

    // 确保窗口不会超出当前屏幕边界
    let adjustedX = max(screenFrame.minX, min(newX, screenFrame.maxX - windowSize.width))
    let adjustedY = max(screenFrame.minY, min(newY, screenFrame.maxY - windowSize.height))

    // 设置窗口位置
    window.setFrameOrigin(NSPoint(x: adjustedX, y: adjustedY))

    NSLog("Window positioned at (\(adjustedX), \(adjustedY)) below status item at (\(buttonFrame.midX), \(buttonFrame.minY)) on screen \(screenFrame)")
  }

  func findScreenContaining(point: NSPoint) -> NSScreen? {
    for screen in NSScreen.screens {
      if screen.frame.contains(point) {
        return screen
      }
    }
    return nil
  }

  func setupWindowClickOutsideHandler() {
    // 移除之前的监听器
    if let monitor = eventMonitor {
      NSEvent.removeMonitor(monitor)
    }

    // 监听全局鼠标点击事件
    eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
      guard let self = self, self.isWindowVisible else { return }

      // 获取点击位置（屏幕坐标）
      let clickLocation = NSEvent.mouseLocation

      // 获取窗口框架（屏幕坐标）
      guard let window = self.mainWindow else { return }
      let windowFrame = window.frame

      // 获取状态栏按钮框架（屏幕坐标）
      var statusButtonFrame = NSRect.zero
      if let statusItem = self.statusItem,
         let button = statusItem.button,
         let buttonWindow = button.window {
        statusButtonFrame = buttonWindow.convertToScreen(button.frame)
      }

      // 如果点击在窗口外部且不在状态栏按钮上，隐藏窗口
      if !windowFrame.contains(clickLocation) && !statusButtonFrame.contains(clickLocation) {
        self.hideMainWindow()
      }
    }
  }


  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false  // 不要在窗口关闭时退出应用
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
