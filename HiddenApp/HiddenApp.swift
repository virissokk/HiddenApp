import SwiftUI
import AppKit
import ApplicationServices
import ServiceManagement

@main
struct HiddenApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    var toggleItem: NSStatusItem!      // значок-стрелочка
    var separatorItem: NSStatusItem!   // значок-палочка: всё левее неё прячется

    // true = значки скрыты, false = значки показаны
    var isCollapsed = false

    // Активное «ограничение строки меню». nil = ничего не скрыто.
    var assertion: NSObject?

    var autoHideTask: Task<Void, Never>?

    // Приложение должно лежать в «Программах», иначе macOS спрячет и его собственные значки
    var isInApplicationsFolder: Bool {
        Bundle.main.bundlePath.hasPrefix("/Applications/")
    }

    // ─────────────────────────────────────────────
    // Настройки
    // ─────────────────────────────────────────────

    // Варианты для выпадающего списка: название и число секунд (0 = никогда).
    // String(localized:) берёт текст из каталога строк на языке системы.
    let timerChoices: [(title: String, seconds: Int)] = [
        (String(localized: "Never"), 0),
        (String(localized: "5 seconds"), 5),
        (String(localized: "8 seconds"), 8),
        (String(localized: "15 seconds"), 15),
        (String(localized: "30 seconds"), 30),
        (String(localized: "1 minute"), 60)
    ]

    // Через сколько секунд после показа значки прячутся сами (0 = никогда)
    var autoHideSeconds: Int {
        get { UserDefaults.standard.object(forKey: "autoHideSeconds") as? Int ?? 8 }
        set { UserDefaults.standard.set(newValue, forKey: "autoHideSeconds") }
    }

    // ─────────────────────────────────────────────
    // Запуск программы
    // ─────────────────────────────────────────────
    func applicationDidFinishLaunching(_ notification: Notification) {

        toggleItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        separatorItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        toggleItem.autosaveName = "HiddenApp.toggle"
        separatorItem.autosaveName = "HiddenApp.separator"

        if let button = toggleItem.button {
            button.image = NSImage(systemSymbolName: "chevron.right",
                                   accessibilityDescription: String(localized: "Hide icons"))
            button.target = self
            button.action = #selector(toggleTapped)
        }

        separatorItem.button?.title = "|"

        // Меню настроек. Его пункты собираются заново при каждом открытии (см. menuNeedsUpdate).
        let menu = NSMenu()
        menu.delegate = self
        separatorItem.menu = menu

        // При запуске значки видны, и через несколько секунд программа их спрячет
        expand()
    }

    func applicationWillTerminate(_ notification: Notification) {
        releaseRestriction()
    }

    // ─────────────────────────────────────────────
    // Меню настроек
    // ─────────────────────────────────────────────

    // macOS вызывает эту функцию каждый раз перед показом меню
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()

        // 1. Автозапуск (галочка, если включён)
        let launchItem = NSMenuItem(title: String(localized: "Launch at login"),
                                    action: #selector(toggleLaunchAtLogin),
                                    keyEquivalent: "")
        launchItem.target = self
        launchItem.state = (SMAppService.mainApp.status == .enabled) ? .on : .off
        menu.addItem(launchItem)

        // 2. Выпадающий список с таймером
        let timerItem = NSMenuItem(title: String(localized: "Hide automatically"),
                                   action: nil, keyEquivalent: "")
        let timerMenu = NSMenu()
        for choice in timerChoices {
            let item = NSMenuItem(title: choice.title,
                                  action: #selector(timerChosen(_:)),
                                  keyEquivalent: "")
            item.target = self
            item.tag = choice.seconds                       // прячем в пункте число секунд
            item.state = (choice.seconds == autoHideSeconds) ? .on : .off
            timerMenu.addItem(item)
        }
        timerItem.submenu = timerMenu
        menu.addItem(timerItem)

        // 3. Выход
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: String(localized: "Quit"),
                                action: #selector(NSApplication.terminate(_:)),
                                keyEquivalent: "q"))
    }

    // Нажали на «Launch at login»
    @objc func toggleLaunchAtLogin() {
        let service = SMAppService.mainApp
        do {
            if service.status == .enabled {
                try service.unregister()
            } else {
                try service.register()
                if service.status == .requiresApproval {
                    showAlert(String(localized: "Allow launch at login in System Settings: General → Login Items."))
                    SMAppService.openSystemSettingsLoginItems()
                }
            }
        } catch {
            showAlert(String(localized: "Could not change launch at login. Make sure the app is in the Applications folder.")
                      + "\n\n" + error.localizedDescription)
        }
    }

    // Выбрали вариант в списке таймера
    @objc func timerChosen(_ sender: NSMenuItem) {
        autoHideSeconds = sender.tag
        scheduleAutoHide()      // сразу применяем новое время
    }

    func showAlert(_ text: String) {
        NSApp.activate()
        let alert = NSAlert()
        alert.messageText = text
        alert.runModal()
    }

    // ─────────────────────────────────────────────
    // Показать / спрятать
    // ─────────────────────────────────────────────

    // Нажатие на стрелочку: если значки скрыты — показываем, если показаны — прячем
    @objc func toggleTapped() {
        if isCollapsed {
            expand()
        } else {
            collapse()
        }
    }

    // ПРЯЧЕМ значки
    func collapse() {
        autoHideTask?.cancel()

        guard isInApplicationsFolder else {
            showAlert(String(localized: "To hide icons, launch the app from the Applications folder, not from Xcode."))
            return
        }

        // Если скрыть не получилось (например, нет разрешения), остаёмся в «показано»
        guard hideAppsLeftOfSeparator() else { return }

        isCollapsed = true
        toggleItem.button?.image = NSImage(systemSymbolName: "chevron.left",
                                           accessibilityDescription: String(localized: "Show icons"))
    }

    // ПОКАЗЫВАЕМ значки и запускаем таймер автоскрытия
    func expand() {
        releaseRestriction()

        isCollapsed = false
        toggleItem.button?.image = NSImage(systemSymbolName: "chevron.right",
                                           accessibilityDescription: String(localized: "Hide icons"))
        scheduleAutoHide()
    }

    // Запускаем (или перезапускаем) таймер автоскрытия
    func scheduleAutoHide() {
        autoHideTask?.cancel()

        let seconds = autoHideSeconds
        guard seconds > 0, !isCollapsed else { return }   // 0 = «Никогда»

        autoHideTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(seconds) * 1_000_000_000)
            if !Task.isCancelled && !self.isCollapsed {
                self.collapse()
            }
        }
    }

    // ─────────────────────────────────────────────
    // Прячем приложения, чьи значки левее палочки.
    // Возвращает true, если всё получилось.
    // ─────────────────────────────────────────────
    func hideAppsLeftOfSeparator() -> Bool {
        releaseRestriction()

        // Проверяем разрешение Accessibility (если его нет, macOS покажет окно с просьбой)
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        guard AXIsProcessTrustedWithOptions(options) else {
            print("MenuBar: no Accessibility permission.")
            return false
        }

        guard let ownID = Bundle.main.bundleIdentifier else {
            print("MenuBar: no bundle identifier")
            return false
        }

        // Где стоит наша палочка? Берём самый левый из двух наших значков.
        let ownPositions = statusItemPositions(of: ProcessInfo.processInfo.processIdentifier).sorted()
        guard let separatorX = ownPositions.first else {
            print("MenuBar: could not find own status items")
            return false
        }

        // Какие приложения прятать: у кого есть значок левее палочки
        var hiddenApps = Set<String>()
        var allowedApps = Set<String>()
        for app in NSWorkspace.shared.runningApplications {
            guard let id = app.bundleIdentifier else { continue }
            if id == ownID { continue }
            let xs = statusItemPositions(of: app.processIdentifier)
            if xs.contains(where: { $0 < separatorX }) {
                hiddenApps.insert(id)
            } else {
                allowedApps.insert(id)
            }
        }
        allowedApps.insert(ownID)
        print("MenuBar: separator at x=\(separatorX), hiding: \(hiddenApps)")

        // Включаем ограничение
        let path = "/System/Library/PrivateFrameworks/MenuBarClientCore.framework/MenuBarClientCore"
        guard dlopen(path, RTLD_NOW) != nil else {
            print("MenuBar: could not load MenuBarClientCore")
            return false
        }
        guard let assertionClass = NSClassFromString("MBAssessmentModeAssertion") as? NSObject.Type,
              let configClass = NSClassFromString("MBAssessmentModeConfiguration") else {
            print("MenuBar: required classes not found (Apple may have removed them)")
            return false
        }

        // Разрешаем системные значки с номерами 0...30 (часы, звук, Wi-Fi, батарея и т. д.)
        let systemItems = (0...30).map { NSNumber(value: $0) } as NSArray
        let allowedList = Array(allowedApps) as NSArray

        let allocated = (configClass as AnyObject)
            .perform(NSSelectorFromString("alloc"))?.takeUnretainedValue()
        guard let config = allocated?.perform(
                NSSelectorFromString("initWithAllowedSystemItems:allowedBundleIdentifiers:"),
                with: systemItems, with: allowedList)?.takeUnretainedValue() else {
            print("MenuBar: could not create configuration")
            return false
        }

        let newAssertion = assertionClass.init()
        let completion: @convention(block) (NSError?) -> Void = { error in
            if let error = error {
                print("MenuBar: activation error: \(error)")
            }
        }
        let block = unsafeBitCast(completion, to: AnyObject.self)
        _ = newAssertion.perform(
            NSSelectorFromString("activateWithConfiguration:completionHandler:"),
            with: config, with: block)

        assertion = newAssertion
        return true
    }

    // Возвращает «координаты X» всех значков приложения в строке меню
    func statusItemPositions(of pid: pid_t) -> [CGFloat] {
        let app = AXUIElementCreateApplication(pid)
        AXUIElementSetMessagingTimeout(app, 0.2)

        var extras: CFTypeRef?
        guard AXUIElementCopyAttributeValue(app, "AXExtrasMenuBar" as CFString, &extras) == .success,
              let extrasBar = extras else { return [] }
        let bar = extrasBar as! AXUIElement

        var childrenValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(bar, "AXChildren" as CFString, &childrenValue) == .success,
              let children = childrenValue as? [AXUIElement] else { return [] }

        var result: [CGFloat] = []
        for child in children {
            var positionValue: CFTypeRef?
            if AXUIElementCopyAttributeValue(child, "AXPosition" as CFString, &positionValue) == .success,
               let positionValue = positionValue {
                var point = CGPoint.zero
                if AXValueGetValue(positionValue as! AXValue, .cgPoint, &point) {
                    result.append(point.x)
                }
            }
        }
        return result
    }

    // Снимаем ограничение: все значки возвращаются
    func releaseRestriction() {
        if let current = assertion {
            _ = current.perform(NSSelectorFromString("invalidate"))
            assertion = nil
        }
    }
}

