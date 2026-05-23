import SwiftUI

struct HostEntryView: View {
    @Environment(LoggerManager.self) private var manager
    @AppStorage("octet0") private var octet0: Int = 192
    @AppStorage("octet1") private var octet1: Int = 168
    @AppStorage("octet2") private var octet2: Int = 0
    @AppStorage("octet3") private var octet3: Int = 1
    @State private var selectedOctet: Int = 0
    @State private var crownValue: Double = 192
    @State private var isConnected = false

    private var hostString: String {
        "\(octet0).\(octet1).\(octet2).\(octet3)"
    }

    var body: some View {
        if isConnected {
            ContentView(onDisconnect: {
                manager.stop()
                isConnected = false
            })
        } else {
            pickerView
                .onAppear {
                    crownValue = Double(octetValue(selectedOctet))
                }
        }
    }

    private var pickerView: some View {
        VStack(spacing: 4) {
            HStack(spacing: 2) {
                ForEach(0..<4) { i in
                    octetLabel(i)
                    if i < 3 {
                        Text(".")
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Text("\(octetValue(selectedOctet))")
                .font(.system(.largeTitle, design: .monospaced))
                .focusable()
                .digitalCrownRotation(
                    $crownValue,
                    from: 0,
                    through: 255,
                    by: 1,
                    sensitivity: .medium,
                    isContinuous: true,
                    isHapticFeedbackEnabled: true
                )
                .onChange(of: crownValue) { _, newValue in
                    let clamped = Int(newValue.rounded()) % 256
                    let val = clamped < 0 ? clamped + 256 : clamped
                    setOctet(selectedOctet, to: val)
                }

            HStack(spacing: 8) {
                ForEach(0..<4) { i in
                    Button {
                        selectedOctet = i
                        crownValue = Double(octetValue(i))
                    } label: {
                        Text("\(i + 1)")
                            .font(.caption2)
                            .frame(width: 28, height: 24)
                    }
                    .buttonStyle(.bordered)
                    .tint(selectedOctet == i ? .blue : .gray)
                }
            }

            Button("Connect") {
                manager.start(host: hostString)
                isConnected = true
            }
            .font(.caption)
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
    }

    private func octetLabel(_ index: Int) -> some View {
        Text("\(octetValue(index))")
            .font(.system(.body, design: .monospaced))
            .foregroundStyle(selectedOctet == index ? .primary : .secondary)
            .onTapGesture {
                selectedOctet = index
                crownValue = Double(octetValue(index))
            }
    }

    private func octetValue(_ index: Int) -> Int {
        switch index {
        case 0: return octet0
        case 1: return octet1
        case 2: return octet2
        default: return octet3
        }
    }

    private func setOctet(_ index: Int, to value: Int) {
        switch index {
        case 0: octet0 = value
        case 1: octet1 = value
        case 2: octet2 = value
        default: octet3 = value
        }
    }
}

#Preview {
    HostEntryView()
        .environment(LoggerManager())
}
