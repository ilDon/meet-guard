import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsStore: SettingsStore
    let onPreview: () -> Void

    var body: some View {
        TabView {
            GeneralSettingsView(settingsStore: settingsStore, onPreview: onPreview)
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            AboutSettingsView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 590, height: 390)
    }
}

private struct GeneralSettingsView: View {
    @ObservedObject var settingsStore: SettingsStore
    let onPreview: () -> Void

    var body: some View {
        Form {
            Section("General") {
                SettingsRow(
                    icon: "clock",
                    tint: .blue,
                    title: "Alert timing",
                    subtitle: "Choose when MeetGuard appears before your meeting."
                ) {
                    Picker("Alert timing", selection: $settingsStore.reminderLeadTime) {
                        ForEach(ReminderLeadTime.allCases) { value in
                            Text(value.label).tag(value)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .frame(width: 128, alignment: .trailing)
                }

                SettingsRow(
                    icon: "power",
                    tint: .green,
                    title: "Launch at startup",
                    subtitle: "Start MeetGuard automatically when you log in."
                ) {
                    Toggle("", isOn: $settingsStore.launchAtStartup)
                        .labelsHidden()
                        .toggleStyle(.switch)
                }
            }

            Section("Preview") {
                HStack(spacing: 12) {
                    Text("Preview meeting overlay")
                        .font(.body)

                    Spacer(minLength: 20)

                    Button("Preview Overlay", action: onPreview)
                        .frame(width: 132)
                }
                .frame(minHeight: 36)
                .padding(.trailing, 12)
            }
        }
        .formStyle(.grouped)
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }
}

private struct AboutSettingsView: View {
    private let repositoryURL = URL(string: "https://github.com/ilDon/meet-guard")!

    var body: some View {
        Form {
            Section("About") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("MeetGuard")
                        .font(.headline)

                    Text(versionText)
                        .font(.callout)
                        .foregroundStyle(.secondary)

                    Link("GitHub Repository", destination: repositoryURL)
                        .font(.callout)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
            }
        }
        .formStyle(.grouped)
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    private var versionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

        if let build, !build.isEmpty {
            return "Version: \(version) (\(build))"
        }

        return "Version: \(version)"
    }
}

private struct SettingsRow<Control: View>: View {
    let icon: String
    let tint: Color
    let title: String
    let subtitle: String
    @ViewBuilder let control: () -> Control

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .regular))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(tint.opacity(0.75))
                .frame(width: 22, height: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 28)

            control()
                .frame(width: 150, alignment: .trailing)
        }
        .frame(minHeight: 46)
        .padding(.trailing, 12)
    }
}
