import Foundation
import NSWatchLogger
import NSWatchLoggerDirect

@Observable
final class LoggerManager {
    var connectionStatus: ConnectionStatus = .disconnected
    var minimumLevel: WatchLogLevel = .debug {
        didSet { WatchLogger.minimumLevel = minimumLevel }
    }
    var isEnabled: Bool = true {
        didSet { WatchLogger.isEnabled = isEnabled }
    }

    private var transport: DirectLogTransport?

    func start(host: String) {
        transport?.disconnect()

        let transport = DirectLogTransport.create(host: host)
        transport.onConnectionStatusChanged = { [weak self] status in
            print("[LoggerManager] status changed: \(status)")
            Task { @MainActor in
                self?.connectionStatus = status
            }
        }
        self.transport = transport
        connectionStatus = transport.connectionStatus
        WatchLogger.configure(
            transport: transport,
            enabled: isEnabled,
            minimumLevel: minimumLevel
        )
    }

    func stop() {
        transport?.disconnect()
        transport = nil
        connectionStatus = .disconnected
    }
}
