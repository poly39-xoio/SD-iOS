import UIKit

// MARK: - SD demo mode (reviewer preview, no Telegram account required)

final class SDDemo {
    static let accent = UIColor(red: 0x3F/255.0, green: 0x4A/255.0, blue: 0x54/255.0, alpha: 1.0)
    static let panel = UIColor(red: 0xE1/255.0, green: 0xEB/255.0, blue: 0xF1/255.0, alpha: 1.0)
    static let panel2 = UIColor(red: 0xCE/255.0, green: 0xD9/255.0, blue: 0xE1/255.0, alpha: 1.0)
    static let bgTop = UIColor(red: 0x8A/255.0, green: 0x9B/255.0, blue: 0xA8/255.0, alpha: 1.0)
    static let bgBottom = UIColor(red: 0x6B/255.0, green: 0x7A/255.0, blue: 0x87/255.0, alpha: 1.0)
    static let ink = UIColor(red: 0x16/255.0, green: 0x1B/255.0, blue: 0x1D/255.0, alpha: 1.0)

    static func controller() -> UIViewController {
        let nav = UINavigationController(rootViewController: SDDemoChatListController())
        if ProcessInfo.processInfo.arguments.contains("--sd-demo-chat") {
            nav.pushViewController(SDDemoChatController(name: "Alex Chen"), animated: false)
        }
        return nav
    }
}

final class SDDemoChatListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let table = UITableView(frame: .zero, style: .plain)
    private let items: [(String, String, String)] = [
        ("Alex Chen", "The build is ready, check TestFlight", "09:41"),
        ("Design Team", "New palette looks great", "09:12"),
        ("Mira", "Voice message", "Yesterday"),
        ("Ops", "Deploy finished ✓", "Yesterday")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chats"
        self.view.backgroundColor = SDDemo.bgTop

        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = SDDemo.accent
        nav?.tintColor = .white
        nav?.titleTextAttributes = [.foregroundColor: UIColor.white]
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = SDDemo.accent
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            nav?.standardAppearance = appearance
            nav?.scrollEdgeAppearance = appearance
        }

        self.table.dataSource = self
        self.table.delegate = self
        self.table.backgroundColor = .clear
        self.table.separatorStyle = .none
        self.table.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.table)
        NSLayoutConstraint.activate([
            self.table.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.table.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.table.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.table.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        let banner = UILabel()
        banner.text = "示範模式 · 不需要登入\nDemo mode · no account needed"
        banner.numberOfLines = 2
        banner.textAlignment = .center
        banner.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        banner.textColor = UIColor.white.withAlphaComponent(0.85)
        banner.frame = CGRect(x: 0, y: 0, width: 320, height: 48)
        self.table.tableHeaderView = banner
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let item = self.items[indexPath.row]
        cell.textLabel?.text = item.0
        cell.detailTextLabel?.text = item.1
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0)
        cell.textLabel?.textColor = SDDemo.ink
        cell.detailTextLabel?.textColor = SDDemo.ink.withAlphaComponent(0.6)
        cell.backgroundColor = SDDemo.panel
        cell.selectionStyle = .none
        cell.accessoryType = .none

        let avatar = UILabel(frame: CGRect(x: 0, y: 0, width: 44.0, height: 44.0))
        avatar.text = String(item.0.prefix(1))
        avatar.textAlignment = .center
        avatar.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        avatar.textColor = .white
        avatar.backgroundColor = SDDemo.accent
        avatar.layer.cornerRadius = 12.0
        avatar.clipsToBounds = true
        cell.imageView?.image = SDDemoChatListController.image(from: avatar)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = SDDemoChatController(name: self.items[indexPath.row].0)
        self.navigationController?.pushViewController(chat, animated: true)
    }

    static func image(from view: UIView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        return renderer.image { _ in
            view.layer.render(in: UIGraphicsGetCurrentContext()!)
        }
    }
}

final class SDDemoChatController: UIViewController {
    private let name: String
    private let scroll = UIScrollView()
    private let stack = UIStackView()
    private let messages: [(Bool, String)] = [
        (false, "Hey — this is what SD looks like without logging in."),
        (true, "Nice. The bubbles are different from Telegram."),
        (false, "Passcode + self destruct are the core feature."),
        (true, "So three wrong codes wipe everything?"),
        (false, "Yes. Local data and the session are revoked.")
    ]

    init(name: String) {
        self.name = name
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.name
        self.view.backgroundColor = SDDemo.bgTop

        self.scroll.translatesAutoresizingMaskIntoConstraints = false
        self.scroll.alwaysBounceVertical = true
        self.view.addSubview(self.scroll)

        self.stack.axis = .vertical
        self.stack.spacing = 8.0
        self.stack.alignment = .fill
        self.stack.translatesAutoresizingMaskIntoConstraints = false
        self.scroll.addSubview(self.stack)

        let bar = UIView()
        bar.backgroundColor = SDDemo.panel
        bar.layer.cornerRadius = 12.0
        bar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(bar)

        let placeholder = UILabel()
        placeholder.text = "Message (demo)"
        placeholder.font = UIFont.systemFont(ofSize: 14.0)
        placeholder.textColor = SDDemo.ink.withAlphaComponent(0.5)
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(placeholder)

        NSLayoutConstraint.activate([
            self.scroll.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.scroll.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scroll.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scroll.bottomAnchor.constraint(equalTo: bar.topAnchor, constant: -6.0),

            self.stack.topAnchor.constraint(equalTo: self.scroll.topAnchor, constant: 12.0),
            self.stack.leadingAnchor.constraint(equalTo: self.scroll.leadingAnchor, constant: 12.0),
            self.stack.trailingAnchor.constraint(equalTo: self.scroll.trailingAnchor, constant: -12.0),
            self.stack.bottomAnchor.constraint(equalTo: self.scroll.bottomAnchor, constant: -12.0),
            self.stack.widthAnchor.constraint(equalTo: self.scroll.widthAnchor, constant: -24.0),

            bar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 12.0),
            bar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12.0),
            bar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -6.0),
            bar.heightAnchor.constraint(equalToConstant: 38.0),
            placeholder.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 12.0),
            placeholder.centerYAnchor.constraint(equalTo: bar.centerYAnchor)
        ])

        for item in self.messages {
            self.appendBubble(text: item.1, outgoing: item.0)
        }
    }

    private func appendBubble(text: String, outgoing: Bool) {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let bubble = UIView()
        bubble.backgroundColor = outgoing ? SDDemo.accent : SDDemo.panel
        bubble.layer.cornerRadius = 14.0
        bubble.clipsToBounds = true
        bubble.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(bubble)

        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.textColor = outgoing ? UIColor.white : SDDemo.ink
        label.translatesAutoresizingMaskIntoConstraints = false
        bubble.addSubview(label)

        // padding inside the bubble
        label.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 9.0).isActive = true
        label.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -9.0).isActive = true
        label.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 12.0).isActive = true
        label.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -12.0).isActive = true

        // bubble never spans the full width: max 72%
        bubble.widthAnchor.constraint(lessThanOrEqualTo: row.widthAnchor, multiplier: 0.72).isActive = true
        bubble.topAnchor.constraint(equalTo: row.topAnchor).isActive = true
        bubble.bottomAnchor.constraint(equalTo: row.bottomAnchor).isActive = true
        if outgoing {
            bubble.trailingAnchor.constraint(equalTo: row.trailingAnchor).isActive = true
            bubble.leadingAnchor.constraint(greaterThanOrEqualTo: row.leadingAnchor).isActive = true
        } else {
            bubble.leadingAnchor.constraint(equalTo: row.leadingAnchor).isActive = true
            bubble.trailingAnchor.constraint(lessThanOrEqualTo: row.trailingAnchor).isActive = true
        }

        self.stack.addArrangedSubview(row)
    }
}
