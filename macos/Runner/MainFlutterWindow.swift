import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  let winWidth: Int = 500
  let winHeight: Int = 450

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()

    // 设置固定窗口大小 - 您可以在这里修改width和height
    let fixedSize = NSSize(width: winWidth, height: winHeight)  // 调整高度为700

    // 计算居中位置
    let screenFrame = NSScreen.main?.frame ?? NSRect.zero
    let windowX = (screenFrame.width - fixedSize.width) / 2
    let windowY = (screenFrame.height - fixedSize.height) / 2
    let windowFrame = NSRect(
      x: windowX, y: windowY, width: fixedSize.width, height: fixedSize.height)

    self.contentViewController = flutterViewController

    // 强制设置窗口大小和位置
    self.setFrame(windowFrame, display: true)

    // 设置固定窗口尺寸，禁用窗口大小调整
    self.minSize = fixedSize
    self.maxSize = fixedSize

    // 移除窗口大小调整功能
    self.styleMask.remove(.resizable)

    // 确保窗口不能被调整大小
    self.isRestorable = false

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  // 重写这个方法以防止窗口大小被外部更改
  override func setFrame(_ frameRect: NSRect, display flag: Bool) {
    let fixedSize = NSSize(width: winWidth, height: winHeight)  // 确保与上面的值一致
    let constrainedFrame = NSRect(
      x: frameRect.origin.x, y: frameRect.origin.y, width: fixedSize.width, height: fixedSize.height
    )
    super.setFrame(constrainedFrame, display: flag)
  }
}
