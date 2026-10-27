import UIKit
import Security
import CryptoKit

// MARK: - SD self-destruct lock (L1-L4)
// MARK: - Localization

enum SDStrings {
    // Set from AppDelegate once Telegram's presentation data is available.
    static var languageCode: String = SDStrings.systemLanguageCode()

    static func systemLanguageCode() -> String {
        let preferred = Locale.preferredLanguages.first ?? "en"
        let code = preferred.split(separator: "-").first.map(String.init) ?? "en"
        return code.lowercased()
    }

    private static let table: [String: [String: String]] = [
        "setup": [
            "en": "Set a 6-digit passcode",
            "zh-Hant": "設定 6 位數密碼",
            "zh": "设置 6 位数字密码",
            "ja": "6桁のパスコードを設定",
            "ko": "6자리 암호 설정",
            "es": "Configura un código de 6 dígitos",
            "fr": "Définissez un code à 6 chiffres",
            "de": "6-stelligen Code festlegen",
            "ru": "Задайте 6-значный код-пароль",
            "pt": "Defina um código de 6 dígitos",
            "it": "Imposta un codice di 6 cifre",
            "ar": "عيّن رمزًا من 6 أرقام",
            "id": "Atur kode sandi 6 digit",
            "vi": "Đặt mật mã 6 chữ số",
            "th": "ตั้งรหัสผ่าน 6 หลัก",
            "tr": "6 haneli parola belirleyin",
            "uk": "Встановіть 6-значний код-пароль",
            "nl": "Stel een 6-cijferige code in",
            "pl": "Ustaw 6-cyfrowy kod",
            "sv": "Ange en 6-siffrig kod"
        ],
        "enter": [
            "en": "Enter passcode",
            "zh-Hant": "輸入密碼",
            "zh": "输入密码",
            "ja": "パスコードを入力",
            "ko": "암호 입력",
            "es": "Introduce el código",
            "fr": "Saisissez le code",
            "de": "Code eingeben",
            "ru": "Введите код-пароль",
            "pt": "Digite o código",
            "it": "Inserisci il codice",
            "ar": "أدخل الرمز",
            "id": "Masukkan kode sandi",
            "vi": "Nhập mật mã",
            "th": "ใส่รหัสผ่าน",
            "tr": "Parolayı girin",
            "uk": "Введіть код-пароль",
            "nl": "Voer de code in",
            "pl": "Wpisz kod",
            "sv": "Ange koden"
        ],
        "repeat": [
            "en": "Enter it again to confirm",
            "zh-Hant": "再輸入一次確認",
            "zh": "再输入一次确认",
            "ja": "確認のためもう一度入力",
            "ko": "확인을 위해 다시 입력",
            "es": "Introdúcelo otra vez",
            "fr": "Saisissez-le à nouveau",
            "de": "Zur Bestätigung erneut eingeben",
            "ru": "Введите ещё раз для подтверждения",
            "pt": "Digite novamente para confirmar",
            "it": "Inseriscilo di nuovo",
            "ar": "أدخله مرة أخرى للتأكيد",
            "id": "Masukkan lagi untuk konfirmasi",
            "vi": "Nhập lại để xác nhận",
            "th": "ใส่ซ้ำเพื่อยืนยัน",
            "tr": "Onaylamak için tekrar girin",
            "uk": "Введіть ще раз для підтвердження",
            "nl": "Voer de code opnieuw in",
            "pl": "Wpisz ponownie, aby potwierdzić",
            "sv": "Ange igen för att bekräfta"
        ],
        "mismatch": [
            "en": "Codes didn't match. Try again.",
            "zh-Hant": "兩次輸入不一致，請重新設定",
            "zh": "两次输入不一致，请重新设置",
            "ja": "一致しません。もう一度設定してください",
            "ko": "일치하지 않습니다. 다시 설정하세요",
            "es": "Los códigos no coinciden. Inténtalo de nuevo.",
            "fr": "Les codes ne correspondent pas. Réessayez.",
            "de": "Die Codes stimmen nicht überein. Erneut versuchen.",
            "ru": "Коды не совпадают. Попробуйте снова.",
            "pt": "Os códigos não coincidem. Tente novamente.",
            "it": "I codici non coincidono. Riprova.",
            "ar": "الرموز غير متطابقة. حاول مرة أخرى.",
            "id": "Kode tidak cocok. Coba lagi.",
            "vi": "Mật mã không khớp. Thử lại.",
            "th": "รหัสไม่ตรงกัน ลองอีกครั้ง",
            "tr": "Parolalar eşleşmedi. Tekrar deneyin.",
            "uk": "Коди не збігаються. Спробуйте ще раз.",
            "nl": "Codes komen niet overeen. Probeer opnieuw.",
            "pl": "Kody się nie zgadzają. Spróbuj ponownie.",
            "sv": "Koderna matchar inte. Försök igen."
        ],
        "wrong": [
            "en": "Wrong passcode. %d attempts left",
            "zh-Hant": "密碼錯誤，剩 %d 次",
            "zh": "密码错误，剩 %d 次",
            "ja": "パスコードが違います。残り %d 回",
            "ko": "암호가 틀렸습니다. %d회 남음",
            "es": "Código incorrecto. Quedan %d intentos",
            "fr": "Code incorrect. %d essais restants",
            "de": "Falscher Code. Noch %d Versuche",
            "ru": "Неверный код. Осталось попыток: %d",
            "pt": "Código incorreto. %d tentativas restantes",
            "it": "Codice errato. %d tentativi rimasti",
            "ar": "رمز خاطئ. تبقى %d محاولات",
            "id": "Kode salah. Sisa %d percobaan",
            "vi": "Sai mật mã. Còn %d lần",
            "th": "รหัสผิด เหลืออีก %d ครั้ง",
            "tr": "Hatalı parola. %d deneme kaldı",
            "uk": "Невірний код. Залишилось спроб: %d",
            "nl": "Onjuiste code. Nog %d pogingen",
            "pl": "Błędny kod. Pozostało prób: %d",
            "sv": "Fel kod. %d försök kvar"
        ],
        "erased": [
            "en": "All data erased.\nUninstall the app to start over.",
            "zh-Hant": "已清除資料\n請刪除 App 後重新安裝",
            "zh": "已清除数据\n请删除 App 后重新安装",
            "ja": "データを消去しました\nアプリを削除してやり直してください",
            "ko": "모든 데이터가 삭제되었습니다\n앱을 삭제하고 다시 시작하세요",
            "es": "Todos los datos borrados.\nDesinstala la app para empezar de nuevo.",
            "fr": "Toutes les données ont été effacées.\nRéinstallez l'app pour recommencer.",
            "de": "Alle Daten gelöscht.\nApp deinstallieren und neu starten.",
            "ru": "Все данные удалены.\nУдалите приложение, чтобы начать заново.",
            "pt": "Todos os dados apagados.\nDesinstale o app para recomeçar.",
            "it": "Tutti i dati cancellati.\nDisinstalla l'app per ricominciare.",
            "ar": "تم مسح كل البيانات.\nأعد تثبيت التطبيق للبدء من جديد.",
            "id": "Semua data dihapus.\nHapus instalasi aplikasi untuk memulai ulang.",
            "vi": "Đã xóa toàn bộ dữ liệu.\nGỡ ứng dụng để bắt đầu lại.",
            "th": "ลบข้อมูลทั้งหมดแล้ว\nถอนการติดตั้งแอปเพื่อเริ่มใหม่",
            "tr": "Tüm veriler silindi.\nYeniden başlamak için uygulamayı kaldırın.",
            "uk": "Усі дані видалено.\nВидаліть застосунок, щоб почати заново.",
            "nl": "Alle gegevens gewist.\nVerwijder de app om opnieuw te beginnen.",
            "pl": "Wszystkie dane usunięte.\nOdinstaluj aplikację, aby zacząć od nowa.",
            "sv": "All data har raderats.\nAvinstallera appen för att börja om."
        ]
    ]

    static func t(_ key: String) -> String {
        guard let variants = table[key] else {
            return key
        }
        let lang = self.languageCode
        if let exact = variants[lang] {
            return exact
        }
        if lang.hasPrefix("zh") {
            if lang.contains("hans") || lang.contains("cn") || lang.contains("sg") {
                return variants["zh"] ?? variants["en"] ?? key
            }
            return variants["zh-Hant"] ?? variants["zh"] ?? variants["en"] ?? key
        }
        return variants["en"] ?? key
    }
}


final class SDLockStore {
    static let shared = SDLockStore()

    private let service = "io.xoio.sd.lock"
    private let account = "passcode"
    private let attemptsKey = "io.xoio.sd.lock.attempts"
    private let wipedKey = "io.xoio.sd.lock.wiped"

    var isWiped: Bool {
        return UserDefaults.standard.bool(forKey: self.wipedKey)
    }

    var hasPasscode: Bool {
        return self.load() != nil
    }

    var failedAttempts: Int {
        return UserDefaults.standard.integer(forKey: self.attemptsKey)
    }

    func setPasscode(_ code: String) {
        self.save(self.digest(code))
        UserDefaults.standard.set(0, forKey: self.attemptsKey)
        UserDefaults.standard.set(false, forKey: self.wipedKey)
    }

    func verify(_ code: String) -> Bool {
        guard let stored = self.load() else {
            return false
        }
        return stored == self.digest(code)
    }

    func registerFailure() -> Int {
        let next = self.failedAttempts + 1
        UserDefaults.standard.set(next, forKey: self.attemptsKey)
        return next
    }

    func resetFailures() {
        UserDefaults.standard.set(0, forKey: self.attemptsKey)
    }

    func selfDestruct() {
        // L2: ask the app to revoke the Telegram session while credentials still exist.
        NotificationCenter.default.post(name: Notification.Name("SDRequestTelegramLogout"), object: nil)
        // Give the logout request a moment to reach the network, then wipe locally.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.performWipe()
        }
    }

    func performWipe() {
        UserDefaults.standard.set(true, forKey: self.wipedKey)

        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword]
        SecItemDelete(query as CFDictionary)

        let fileManager = FileManager.default
        let home = NSHomeDirectory()
        for sub in ["Documents", "Library", "tmp"] {
            let path = (home as NSString).appendingPathComponent(sub)
            if let items = try? fileManager.contentsOfDirectory(atPath: path) {
                for item in items {
                    try? fileManager.removeItem(atPath: (path as NSString).appendingPathComponent(item))
                }
            }
        }

        UserDefaults.standard.set(true, forKey: self.wipedKey)
        UserDefaults.standard.synchronize()
    }

    private func digest(_ code: String) -> String {
        let hash = SHA256.hash(data: Data(code.utf8))
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    private func load() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecAttrAccount as String: self.account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    private func save(_ value: String) {
        var base: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecAttrAccount as String: self.account
        ]
        SecItemDelete(base as CFDictionary)
        base[kSecValueData as String] = Data(value.utf8)
        base[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        SecItemAdd(base as CFDictionary, nil)
    }
}

final class SDLockController {
    static let shared = SDLockController()
    static let passcodeLength = 6

    private var window: UIWindow?

    func presentWhenReady(retries: Int = 40) {
        NSLog("SD-FONT-CHECK huninn=%@ family=%@", UIFont(name: "Huninn-Regular", size: 12) != nil ? "YES" : "NO", UIFont(name: "Huninn-Regular", size: 12)?.familyName ?? "-")
        if self.window != nil {
            return
        }
        let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first(where: { $0.activationState == .foregroundActive }) ?? UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first
        guard let scene = scene else {
            if retries > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.presentWhenReady(retries: retries - 1)
                }
            } else {
                NSLog("SDLock: no window scene found")
            }
            return
        }
        self.present(scene: scene)
    }

    private func present(scene: UIWindowScene) {
        guard self.window == nil else {
            return
        }
        if ProcessInfo.processInfo.arguments.contains("--sd-no-lock") {
            return
        }
        if ProcessInfo.processInfo.arguments.contains("--sd-demo") {
            let win = UIWindow(windowScene: scene)
            win.windowLevel = UIWindow.Level.statusBar + 1
            self.window = win
            win.rootViewController = SDDemo.controller()
            win.makeKeyAndVisible()
            return
        }
        let win = UIWindow(windowScene: scene)
        win.windowLevel = UIWindow.Level.statusBar + 1
        win.backgroundColor = UIColor.black
        self.window = win
        if SDLockStore.shared.isWiped {
            win.rootViewController = SDResetViewController()
        } else if SDLockStore.shared.hasPasscode {
            win.rootViewController = SDLockViewController(mode: .unlock)
        } else {
            win.rootViewController = SDLockViewController(mode: .setup)
        }
        win.makeKeyAndVisible()
    }

    func didUnlock() {
        self.window?.isHidden = true
        self.window = nil
    }

    private var foregroundObserver: NSObjectProtocol?

    func startObserving() {
        guard self.foregroundObserver == nil else {
            return
        }
        self.foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else {
                return
            }
            if self.window == nil {
                self.presentWhenReady()
            }
        }
    }

    func didWipe() {
        self.window?.rootViewController = SDResetViewController()
    }
}

final class SDResetViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        let label = UILabel()
        label.text = SDStrings.t("erased")
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 32.0),
            label.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: -32.0)
        ])
    }
}

enum SDLockMode {
    case setup
    case unlock
}

final class SDLockViewController: UIViewController {
    private let mode: SDLockMode
    private var entered = ""
    private var firstEntry: String?
    private var dots: [UIView] = []
    private let titleLabel = UILabel()
    private let dotsView = UIStackView()

    init(mode: SDLockMode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black

        self.titleLabel.textColor = UIColor.white
        self.titleLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
        self.titleLabel.textAlignment = .center
        self.titleLabel.numberOfLines = 0
        self.titleLabel.text = self.mode == .setup ? SDStrings.t("setup") : SDStrings.t("enter")

        self.dotsView.axis = .horizontal
        self.dotsView.spacing = 14.0
        self.dotsView.alignment = .center
        self.dotsView.distribution = .equalSpacing

        for _ in 0 ..< SDLockController.passcodeLength {
            let dot = UIView()
            dot.layer.cornerRadius = 7.0
            dot.layer.borderWidth = 1.0
            dot.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
            dot.backgroundColor = UIColor.clear
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: 14.0).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 14.0).isActive = true
            self.dots.append(dot)
            self.dotsView.addArrangedSubview(dot)
        }

        let keypad = UIStackView()
        keypad.axis = .vertical
        keypad.spacing = 12.0
        keypad.alignment = .center

        let rows: [[String]] = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["", "0", "⌫"]]
        for row in rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 12.0
            rowStack.distribution = .fillEqually
            for key in row {
                if key.isEmpty {
                    let spacer = UIView()
                    spacer.translatesAutoresizingMaskIntoConstraints = false
                    spacer.widthAnchor.constraint(equalToConstant: 72.0).isActive = true
                    spacer.heightAnchor.constraint(equalToConstant: 58.0).isActive = true
                    rowStack.addArrangedSubview(spacer)
                } else {
                    let button = UIButton(type: .system)
                    button.setTitle(key, for: .normal)
                    button.setTitleColor(.white, for: .normal)
                    button.titleLabel?.font = UIFont.systemFont(ofSize: key == "⌫" ? 20.0 : 26.0, weight: key == "⌫" ? UIFont.Weight.regular : UIFont.Weight.light)
                    button.backgroundColor = UIColor.white.withAlphaComponent(0.08)
                    button.layer.cornerRadius = 12.0
                    button.translatesAutoresizingMaskIntoConstraints = false
                    button.widthAnchor.constraint(equalToConstant: 72.0).isActive = true
                    button.heightAnchor.constraint(equalToConstant: 58.0).isActive = true
                    button.addTarget(self, action: #selector(self.keyPressed(_:)), for: .touchUpInside)
                    rowStack.addArrangedSubview(button)
                }
            }
            keypad.addArrangedSubview(rowStack)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dotsView.translatesAutoresizingMaskIntoConstraints = false
        keypad.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.dotsView)
        self.view.addSubview(keypad)

        let demoButton = UIButton(type: .system)
        demoButton.setTitle("查看示範 / View demo", for: .normal)
        demoButton.setTitleColor(UIColor.white.withAlphaComponent(0.75), for: .normal)
        demoButton.titleLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: .medium)
        demoButton.translatesAutoresizingMaskIntoConstraints = false
        demoButton.addTarget(self, action: #selector(self.showDemo), for: .touchUpInside)
        self.view.addSubview(demoButton)

        let tagLabel = UILabel()
        tagLabel.text = "build " + sdBuildTag
        tagLabel.font = UIFont.systemFont(ofSize: 10.0, weight: .medium)
        tagLabel.textColor = UIColor.white.withAlphaComponent(0.35)
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tagLabel)
        NSLayoutConstraint.activate([
            tagLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            tagLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10.0)
        ])

        NSLayoutConstraint.activate([
            demoButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            demoButton.bottomAnchor.constraint(equalTo: keypad.topAnchor, constant: -18.0),
        self.titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 80.0),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24.0),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24.0),
            self.dotsView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.dotsView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 28.0),
            keypad.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            keypad.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -36.0)
        ])
    }

    @objc private func keyPressed(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else {
            return
        }
        if title == "⌫" {
            if !self.entered.isEmpty {
                self.entered.removeLast()
            }
        } else if self.entered.count < SDLockController.passcodeLength {
            self.entered += title
        }
        self.updateDots()

        if self.entered.count == SDLockController.passcodeLength {
            self.handleComplete()
        }
    }

    @objc private func showDemo() {
        let nav = SDDemo.controller()
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }

    private func updateDots() {
        for (index, dot) in self.dots.enumerated() {
            dot.backgroundColor = index < self.entered.count ? UIColor.white : UIColor.clear
        }
    }

    private func handleComplete() {
        let code = self.entered
        self.entered = ""
        self.updateDots()

        let store = SDLockStore.shared
        if self.mode == .setup {
            if let first = self.firstEntry {
                if first == code {
                    store.setPasscode(code)
                    SDLockController.shared.didUnlock()
                } else {
                    self.firstEntry = nil
                    self.titleLabel.text = SDStrings.t("mismatch")
                }
            } else {
                self.firstEntry = code
                self.titleLabel.text = SDStrings.t("repeat")
            }
            return
        }

        if store.verify(code) {
            store.resetFailures()
            SDLockController.shared.didUnlock()
        } else {
            let failures = store.registerFailure()
            if failures >= 3 {
                store.selfDestruct()
                SDLockController.shared.didWipe()
            } else {
                self.titleLabel.text = String(format: SDStrings.t("wrong"), 3 - failures)
                let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
                animation.values = [-10.0, 10.0, -6.0, 6.0, 0.0]
                animation.duration = 0.3
                self.dotsView.layer.add(animation, forKey: "shake")
            }
        }
    }
}
