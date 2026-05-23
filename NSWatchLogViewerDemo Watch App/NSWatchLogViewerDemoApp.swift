import SwiftUI

@main
struct NSWatchLogViewerDemo_Watch_AppApp: App {
    @State private var manager = LoggerManager()

    var body: some Scene {
        WindowGroup {
            HostEntryView()
                .environment(manager)
        }
    }
}
