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
  var settingsEventMonitor: Any?
  var iconUpdateTimer: Timer?


  override func applicationWillFinishLaunching(_ notification: Notification) {
    super.applicationWillFinishLaunching(notification)

    NSLog("AppDelegate applicationWillFinishLaunching called")

    // 立即隐藏 Dock 图标，防止窗口显示
    NSApp.setActivationPolicy(.accessory)

    // 立即创建状态栏项目
    setupStatusBar()
    setupMainMenu()

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

    channel.setMethodCallHandler { (call, result) in
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
    updateTrayIcon() // Use dynamic icon
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

    // Setup timer to update icon daily
    setupIconUpdateTimer()
  }
  func setupContextMenu() {
    contextMenu = NSMenu()

    // App Settings menu item
    let settingsItem = NSMenuItem(title: "设置", action: #selector(showAppSettings), keyEquivalent: ",")
    settingsItem.target = self
    contextMenu?.addItem(settingsItem)

    // Separator
    contextMenu?.addItem(NSMenuItem.separator())

    // About menu item
    let aboutItem = NSMenuItem(title: "关于", action: #selector(showAbout), keyEquivalent: "")
    aboutItem.target = self
    contextMenu?.addItem(aboutItem)

    // Separator
    contextMenu?.addItem(NSMenuItem.separator())

    // Quit menu item
    let quitItem = NSMenuItem(title: "退出", action: #selector(quitApplication), keyEquivalent: "q")
    quitItem.target = self
    contextMenu?.addItem(quitItem)
  }

  // MARK: - Dynamic Icon Generation

  func updateTrayIcon() {
    guard let statusItem = statusItem,
          let button = statusItem.button else {
      NSLog("Failed to get status item button for icon update")
      return
    }

    let icon = generateCalendarIcon()
    button.image = icon
    button.title = "" // Clear any text title

    NSLog("Tray icon updated with current date")
  }

  func generateCalendarIcon() -> NSImage {
    let iconSize = NSSize(width: 22, height: 22) // Increased size for clarity
    let image = NSImage(size: iconSize)

    image.lockFocus()

    // Get current date components
    let calendar = Calendar.current
    let now = Date()
    let day = calendar.component(.day, from: now)

    // Get weekday abbreviation (e.g., "周二" for Tuesday)
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "zh_CN")
    formatter.dateFormat = "E"
    let weekdayText = formatter.string(from: now)

    // Define a rounded rectangle path for the icon background
    let cornerRadius: CGFloat = 4.0
    let backgroundPath = NSBezierPath(roundedRect: NSRect(origin: .zero, size: iconSize), xRadius: cornerRadius, yRadius: cornerRadius)

    // Draw background
    NSColor.white.setFill()
    backgroundPath.fill()

    // Draw weekday text (at the top, in red) - smaller and less prominent
    let weekdayFont: NSFont = NSFont.systemFont(ofSize: 7, weight: .semibold)
    let weekdayAttributes: [NSAttributedString.Key: Any] = [
        .font: weekdayFont,
        .foregroundColor: NSColor.systemRed
    ]
    let weekdayString = NSAttributedString(string: weekdayText, attributes: weekdayAttributes)
    let weekdaySize = weekdayString.size()
    let weekdayRect = NSRect(
        x: (iconSize.width - weekdaySize.width) / 2,
        y: iconSize.height - weekdaySize.height - 1, // Position closer to top
        width: weekdaySize.width,
        height: weekdaySize.height
    )
    weekdayString.draw(in: weekdayRect)

    // Draw day number (larger, bold, with more spacing from weekday)
    let dayFont = NSFont.systemFont(ofSize: 13, weight: .medium)
    let dayAttributes: [NSAttributedString.Key: Any] = [
        .font: dayFont,
        .foregroundColor: NSColor.black
    ]
    let dayString = NSAttributedString(string: "\(day)", attributes: dayAttributes)
    let daySize = dayString.size()
    let dayRect = NSRect(
        x: (iconSize.width - daySize.width) / 2,
        y: (iconSize.height - daySize.height) / 2 - 3, // More spacing from weekday
        width: daySize.width,
        height: daySize.height
    )
    dayString.draw(in: dayRect)

    image.unlockFocus()

    return image
  }

  func setupIconUpdateTimer() {
    // Calculate time until next midnight
    let calendar = Calendar.current
    let now = Date()
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
    let midnight = calendar.startOfDay(for: tomorrow)

    // Create timer to fire at midnight
    iconUpdateTimer = Timer(fireAt: midnight, interval: 24 * 60 * 60, target: self, selector: #selector(updateTrayIconTimer), userInfo: nil, repeats: true)

    if let timer = iconUpdateTimer {
      RunLoop.main.add(timer, forMode: .common)
      NSLog("Icon update timer scheduled for midnight: \(midnight)")
    }
  }

  @objc func updateTrayIconTimer() {
    updateTrayIcon()
  }

  func setupMainMenu() {
    // The application menu is connected via an @IBOutlet from the MainMenu.xib
    guard let appMenu = applicationMenu else {
        NSLog("Application menu outlet not connected.")
        return
    }

    // Find the "Preferences..." menu item, update its title, and connect it to our action.
    if let settingsItem = appMenu.item(withTitle: "Preferences…") {
      settingsItem.title = "Settings..."
      settingsItem.target = self
      settingsItem.action = #selector(showPreferences(_:))
      NSLog("System Settings menu item updated and connected.")
    } else {
        NSLog("Could not find 'Preferences...' menu item to update.")
    }
  }

  @objc func statusBarButtonClicked() {
    NSLog("Status bar button clicked")

    guard let event = NSApp.currentEvent else {
      NSLog("No current event found")
      return
    }

    // Check if it's a right-click
    if event.type == .rightMouseUp {
      NSLog("Right-click detected")
      // 如果窗口可见，则先隐藏
      if isWindowVisible {
        hideMainWindow()
      }
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

    // Update menu item states before showing
    updateMenuItemStates()

    statusItem.menu = menu
    button.performClick(nil)
    statusItem.menu = nil
  }

  func updateMenuItemStates() {
    guard let menu = contextMenu else { return }

    // Find the settings menu item and update its enabled state
    for item in menu.items {
      if item.action == #selector(showAppSettings) {
        // Settings should be enabled when calendar window is visible
        item.isEnabled = isWindowVisible
        break
      }
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

    settingsWindow.title = "偏好设置"
    settingsWindow.center()
    settingsWindow.isReleasedWhenClosed = false

    // Create content view
    let contentView = NSView(frame: settingsWindow.contentRect(forFrameRect: settingsWindow.frame))
    settingsWindow.contentView = contentView

    // Create checkbox for Sunday first column
    let checkbox = NSButton(checkboxWithTitle: "从周日开始", target: self, action: #selector(sundayFirstChanged(_:)))
    checkbox.frame = NSRect(x: 20, y: 120, width: 200, height: 20)

    // Load current setting
    let sundayFirst = UserDefaults.standard.bool(forKey: "SundayFirstColumn")
    checkbox.state = sundayFirst ? .on : .off

    contentView.addSubview(checkbox)

    // Create explanatory label
    let label = NSTextField(labelWithString: "每周从周日还是周一开始")
    label.frame = NSRect(x: 20, y: 90, width: 360, height: 20)
    label.font = NSFont.systemFont(ofSize: 12)
    label.textColor = .secondaryLabelColor
    contentView.addSubview(label)

    // Store reference to window for closing
    self.settingsWindow = settingsWindow
    settingsWindow.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)

    // Add click-outside-to-close functionality
    setupSettingsWindowClickOutsideHandler()
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

  func setupSettingsWindowClickOutsideHandler() {
    // Remove previous monitor if exists
    if let monitor = settingsEventMonitor {
      NSEvent.removeMonitor(monitor)
    }

    // Monitor global mouse clicks
    settingsEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
      guard let self = self, let settingsWindow = self.settingsWindow else { return }

      // Get click location in screen coordinates
      let clickLocation = NSEvent.mouseLocation
      let windowFrame = settingsWindow.frame

      // If click is outside settings window, close it
      if !windowFrame.contains(clickLocation) {
        self.closeSettingsWindow()
      }
    }
  }

  @objc func closeSettingsWindow(_ sender: NSButton? = nil) {
    // Remove event monitor
    if let monitor = settingsEventMonitor {
      NSEvent.removeMonitor(monitor)
      settingsEventMonitor = nil
    }

    settingsWindow?.close()
    settingsWindow = nil
  }

  @objc func showAbout() {
    NSLog("About menu item clicked")

    // Use the system's standard about panel for consistency
    let options: [NSApplication.AboutPanelOptionKey: Any] = [
      .applicationName: "Tiny Chinese Lunar Calendar",
      .applicationVersion: "1.0",
      .version: "Build 1.0.0",
      NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): "© 2024 Tiny Chinese Lunar Calendar",
      .credits: NSAttributedString(string: "A compact lunar calendar application for macOS.\n\nBuilt with Flutter and Swift."),
      .applicationIcon: (NSApp.applicationIconImage ?? NSImage(named: "AppIcon")) as Any
    ]

    NSApp.orderFrontStandardAboutPanel(options: options)
  }

  @objc func quitApplication() {
    NSLog("Quit menu item clicked")
    NSApplication.shared.terminate(nil)
  }

  @IBAction func showPreferences(_ sender: Any?) {
    NSLog("System Preferences menu item clicked")
    showAppSettings()
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false  // 不要在窗口关闭时退出应用
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
