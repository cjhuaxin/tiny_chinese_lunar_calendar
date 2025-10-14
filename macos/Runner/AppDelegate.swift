import Cocoa
import FlutterMacOS

@main
@objc class AppDelegate: FlutterAppDelegate {
  var statusItem: NSStatusItem?
  var popover: NSPopover?
  var mainWindow: NSWindow?
  var isWindowVisible = false
  var eventMonitor: Any?
  var contextMenu: NSMenu?
  var settingsWindow: NSWindow?

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

        // Setup method channel after window is available
        self.setupMethodChannel()
      } else {
        NSLog("No main window found")
      }
    }
  }

  func setupMethodChannel() {
    guard let flutterViewController = mainWindow?.contentViewController as? FlutterViewController else {
      NSLog("Failed to get FlutterViewController for method channel setup")
      return
    }

    let channel = FlutterMethodChannel(name: "calendar_settings", binaryMessenger: flutterViewController.engine.binaryMessenger)

    channel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "getSettings":
        let sundayFirst = UserDefaults.standard.bool(forKey: "SundayFirstColumn")
        result(["sundayFirst": sundayFirst])
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    NSLog("Method channel setup completed")
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

    // 设置右键菜单
    button.sendAction(on: [.leftMouseUp, .rightMouseUp])

    // 强制显示
    statusItem.isVisible = true

    // 创建右键菜单
    setupContextMenu()

    NSLog("Status bar item created with calendar icon")
  }
  func setupContextMenu() {
    contextMenu = NSMenu()

    // App Settings menu item
    let settingsItem = NSMenuItem(title: "App Settings...", action: #selector(showAppSettings), keyEquivalent: "")
    settingsItem.target = self
    contextMenu?.addItem(settingsItem)

    // Separator
    contextMenu?.addItem(NSMenuItem.separator())

    // About menu item
    let aboutItem = NSMenuItem(title: "About Tiny Chinese Lunar Calendar", action: #selector(showAbout), keyEquivalent: "")
    aboutItem.target = self
    contextMenu?.addItem(aboutItem)

    // Separator
    contextMenu?.addItem(NSMenuItem.separator())

    // Quit menu item
    let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApplication), keyEquivalent: "q")
    quitItem.target = self
    contextMenu?.addItem(quitItem)
  }

  @objc func statusBarButtonClicked() {
    NSLog("Status bar button clicked")

    guard let event = NSApp.currentEvent else {
      NSLog("No current event found")
      return
    }

    // Check if it's a right-click
    if event.type == .rightMouseUp {
      NSLog("Right-click detected, showing context menu")
      showContextMenu()
    } else {
      NSLog("Left-click detected, toggling window")
      // 切换窗口显示状态
      if isWindowVisible {
        hideMainWindow()
      } else {
        showMainWindow()
      }
    }
  }

  func showContextMenu() {
    guard let statusItem = statusItem,
          let button = statusItem.button,
          let menu = contextMenu else {
      NSLog("Failed to get components for context menu")
      return
    }

    statusItem.menu = menu
    button.performClick(nil)
    statusItem.menu = nil
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

  // MARK: - Context Menu Actions

  @objc func showAppSettings() {
    NSLog("App Settings menu item clicked")

    // Create settings window
    let settingsWindow = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
      styleMask: [.titled, .closable],
      backing: .buffered,
      defer: false
    )

    settingsWindow.title = "App Settings"
    settingsWindow.center()
    settingsWindow.isReleasedWhenClosed = false

    // Create content view
    let contentView = NSView(frame: settingsWindow.contentRect(forFrameRect: settingsWindow.frame))
    settingsWindow.contentView = contentView

    // Create checkbox for Sunday first column
    let checkbox = NSButton(checkboxWithTitle: "Start week on Sunday", target: self, action: #selector(sundayFirstChanged(_:)))
    checkbox.frame = NSRect(x: 20, y: 120, width: 200, height: 20)

    // Load current setting
    let sundayFirst = UserDefaults.standard.bool(forKey: "SundayFirstColumn")
    checkbox.state = sundayFirst ? .on : .off

    contentView.addSubview(checkbox)

    // Create explanatory label
    let label = NSTextField(labelWithString: "Choose whether the calendar week starts on Sunday or Monday.")
    label.frame = NSRect(x: 20, y: 90, width: 360, height: 20)
    label.font = NSFont.systemFont(ofSize: 12)
    label.textColor = .secondaryLabelColor
    contentView.addSubview(label)

    // Create OK button
    let okButton = NSButton(title: "OK", target: self, action: #selector(closeSettingsWindow(_:)))
    okButton.frame = NSRect(x: 310, y: 20, width: 70, height: 30)
    okButton.bezelStyle = .rounded
    okButton.keyEquivalent = "\r"
    contentView.addSubview(okButton)

    // Create Cancel button
    let cancelButton = NSButton(title: "Cancel", target: self, action: #selector(closeSettingsWindow(_:)))
    cancelButton.frame = NSRect(x: 230, y: 20, width: 70, height: 30)
    cancelButton.bezelStyle = .rounded
    cancelButton.keyEquivalent = "\u{1b}" // Escape key
    contentView.addSubview(cancelButton)

    // Store reference to window for closing
    self.settingsWindow = settingsWindow
    settingsWindow.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  @objc func sundayFirstChanged(_ sender: NSButton) {
    let sundayFirst = sender.state == .on
    UserDefaults.standard.set(sundayFirst, forKey: "SundayFirstColumn")
    NSLog("Sunday first column setting changed to: \(sundayFirst)")

    // Notify Flutter about the setting change
    if let flutterViewController = mainWindow?.contentViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "calendar_settings", binaryMessenger: flutterViewController.engine.binaryMessenger)
      channel.invokeMethod("settingsChanged", arguments: ["sundayFirst": sundayFirst])
    }
  }

  @objc func closeSettingsWindow(_ sender: NSButton) {
    settingsWindow?.close()
    settingsWindow = nil
  }

  @objc func showAbout() {
    NSLog("About menu item clicked")
    // TODO: Implement about dialog

    let alert = NSAlert()
    alert.messageText = "About Tiny Chinese Lunar Calendar"
    alert.informativeText = "A compact lunar calendar application for macOS.\n\nVersion 1.0\nBuilt with Flutter"
    alert.alertStyle = .informational
    alert.addButton(withTitle: "OK")
    alert.runModal()
  }

  @objc func quitApplication() {
    NSLog("Quit menu item clicked")
    NSApplication.shared.terminate(nil)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false  // 不要在窗口关闭时退出应用
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
