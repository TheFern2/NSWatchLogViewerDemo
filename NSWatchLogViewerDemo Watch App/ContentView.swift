import SwiftUI
import NSWatchLogger
import NSWatchLoggerDirect

struct ContentView: View {
    @Environment(LoggerManager.self) private var manager
    @State private var selectedTag: DemoTag = .network
    var onDisconnect: (() -> Void)?

    var body: some View {
        TabView {
            sendTab
            filterTab
            burstTab
            settingsTab
        }
    }

    // MARK: - Send Tab

    private var sendTab: some View {
        NavigationStack {
            List {
                statusRow

                Picker("Tag", selection: $selectedTag) {
                    ForEach(DemoTag.allCases, id: \.self) { tag in
                        Text(tag.rawValue.capitalized).tag(tag)
                    }
                }

                Button("Debug") { sendLog(.debug) }

                Button("Info") { sendLog(.info) }
                    .tint(.blue)

                Button("Warning") { sendLog(.warning) }
                    .tint(.yellow)

                Button("Error") { sendLog(.error) }
                    .tint(.red)
            }
            .navigationTitle("Send")
        }
    }

    // MARK: - Filter Tab

    private var filterTab: some View {
        @Bindable var manager = manager

        return NavigationStack {
            List {
                statusRow

                Picker("Min Level", selection: $manager.minimumLevel) {
                    Text("Debug").tag(WatchLogLevel.debug)
                    Text("Info").tag(WatchLogLevel.info)
                    Text("Warning").tag(WatchLogLevel.warning)
                    Text("Error").tag(WatchLogLevel.error)
                }

                Toggle("Enabled", isOn: $manager.isEnabled)
            }
            .navigationTitle("Filter")
        }
    }

    // MARK: - Burst Tab

    private var burstTab: some View {
        NavigationStack {
            List {
                statusRow

                Button("Send 20 Mixed") { sendBurst() }
                    .tint(.purple)

            }
            .navigationTitle("Burst")
        }
    }

    // MARK: - Settings Tab

    private var settingsTab: some View {
        NavigationStack {
            List {
                statusRow

                Button("Change Host") {
                    onDisconnect?()
                }
                .tint(.orange)
            }
            .navigationTitle("Settings")
        }
    }

    // MARK: - Shared

    private var statusRow: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
            Text(statusText)
                .font(.caption)
        }
    }

    private var statusColor: Color {
        switch manager.connectionStatus {
        case .connected: return .green
        case .connecting, .reconnecting, .discovering: return .orange
        case .disconnected: return .red
        }
    }

    private var statusText: String {
        switch manager.connectionStatus {
        case .connected: return "Connected"
        case .connecting: return "Connecting..."
        case .reconnecting: return "Reconnecting..."
        case .discovering: return "Discovering..."
        case .disconnected: return "Disconnected"
        }
    }

    private func sendLog(_ level: WatchLogLevel) {
        WatchLogger.log(
            selectedTag.watchTag,
            level,
            "Demo \(level.rawValue) from \(selectedTag.rawValue)"
        )
    }

    private func sendBurst() {
        let tags = DemoTag.allCases
        let levels: [WatchLogLevel] = [.debug, .info, .warning, .error]
        for i in 1...20 {
            let tag = tags[(i - 1) % tags.count]
            let level = levels[(i - 1) % levels.count]
            WatchLogger.log(
                tag.watchTag,
                level,
                "Burst #\(i): \(level.rawValue) in \(tag.rawValue)"
            )
        }
    }
}

enum DemoTag: String, CaseIterable {
    case network, workout, service, debug

    var watchTag: WatchLogTag {
        switch self {
        case .network: return .network
        case .workout: return .workout
        case .service: return .service
        case .debug: return .debug
        }
    }
}

#Preview {
    ContentView()
        .environment(LoggerManager())
}
