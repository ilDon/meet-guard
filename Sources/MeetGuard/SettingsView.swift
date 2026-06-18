import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsStore: SettingsStore
    let onPreview: () -> Void

    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                header
                settingsGroup
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 22)
            .padding(.top, 54)
            .padding(.bottom, 22)
        }
        .frame(minWidth: 520, minHeight: 320)
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(nsImage: NSImage.meetGuardAppIcon())
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                .frame(width: 48, height: 48)
                .shadow(color: .black.opacity(0.16), radius: 3, y: 1)

            Text("MeetGuard")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var settingsGroup: some View {
        VStack(spacing: 0) {
            alertTimingRow

            Divider()
                .padding(.leading, 46)

            launchAtStartupRow

            Divider()
                .padding(.leading, 46)

            previewRow
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var alertTimingRow: some View {
        HStack(alignment: .top, spacing: 12) {
            settingIcon(systemName: "clock", color: .systemBlue)

            VStack(alignment: .leading, spacing: 4) {
                Text("Alert timing")
                    .font(.system(size: 13))
                    .foregroundStyle(.primary)

                Text("Show alert before meeting")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 16)

            Picker("", selection: $settingsStore.reminderLeadTime) {
                ForEach(ReminderLeadTime.allCases) { value in
                    Text(value.label).tag(value)
                }
            }
            .labelsHidden()
            .pickerStyle(.radioGroup)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }

    private var launchAtStartupRow: some View {
        HStack(spacing: 12) {
            settingIcon(systemName: "power", color: .systemGreen)

            Text("Launch at startup")
                .font(.system(size: 13))
                .foregroundStyle(.primary)

            Spacer(minLength: 16)

            Toggle("", isOn: $settingsStore.launchAtStartup)
                .labelsHidden()
                .toggleStyle(.switch)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var previewRow: some View {
        HStack(spacing: 12) {
            settingIcon(systemName: "eye", color: .systemPurple)

            VStack(alignment: .leading, spacing: 4) {
                Text("Preview")
                    .font(.system(size: 13))
                    .foregroundStyle(.primary)

                Text("Show the meeting overlay")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 16)

            Button("Preview", action: onPreview)
                .controlSize(.regular)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private func settingIcon(systemName: String, color: NSColor) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Color(nsColor: color))

            Image(systemName: systemName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: 22, height: 22)
    }

    private var cardBackground: some ShapeStyle {
        Color(nsColor: .controlBackgroundColor)
    }
}
