import SwiftUI

struct MeetingOverlayView: View {
    let meeting: Meeting
    let onJoin: () -> Void
    let onPostpone: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let cardWidth = min(1_136, max(720, proxy.size.width - 180))

            ZStack {
                overlayBackground

                VStack(spacing: 28) {
                    header
                    datePill
                    infoPanel
                    actions
                    footer
                }
                .padding(.horizontal, 68)
                .padding(.top, 30)
                .padding(.bottom, 34)
                .frame(width: cardWidth)
                .background(cardBackground)
                .overlay(cardStroke)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: .black.opacity(0.55), radius: 48, y: 28)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private var overlayBackground: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.52)
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color(red: 0.015, green: 0.03, blue: 0.055).opacity(0.39),
                    Color(red: 0.025, green: 0.035, blue: 0.075).opacity(0.35),
                    Color.black.opacity(0.46)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [
                    Color(red: 0.05, green: 0.33, blue: 0.95).opacity(0.30),
                    Color.clear
                ],
                center: .leading,
                startRadius: 40,
                endRadius: 520
            )

            RadialGradient(
                colors: [
                    Color.white.opacity(0.08),
                    Color.clear
                ],
                center: .top,
                startRadius: 10,
                endRadius: 560
            )

            Color.black.opacity(0.21)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(spacing: 18) {
            Image(nsImage: NSImage.meetGuardAppIcon())
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.58), lineWidth: 2)
                )
                .shadow(color: Color(red: 0.16, green: 0.49, blue: 1).opacity(0.35), radius: 18)

            VStack(spacing: 10) {
                Text("UPCOMING MEETING")
                    .font(.system(size: 16, weight: .medium))
                    .tracking(9)
                    .foregroundStyle(Color(red: 0.26, green: 0.55, blue: 1))

                Text(meeting.title)
                    .font(.system(size: 58, weight: .heavy))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.58)
                    .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
            }
        }
    }

    private var datePill: some View {
        Label(datePillText, systemImage: "calendar")
            .font(.system(size: 24, weight: .medium))
            .foregroundStyle(Color(red: 0.24, green: 0.55, blue: 1))
            .padding(.horizontal, 22)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.035))
                    .overlay(Capsule(style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
            )
    }

    private var infoPanel: some View {
        HStack(spacing: 0) {
            InfoTile(
                icon: "clock",
                title: countdownTitle,
                value: countdownValue,
                iconSize: 28,
                valueColor: Color(red: 0.22, green: 0.55, blue: 1)
            )

            verticalDivider

            InfoTile(
                icon: "calendar",
                title: "CALENDAR",
                value: meeting.calendarTitle,
                iconSize: 26
            )

            verticalDivider

            InfoTile(
                icon: "person",
                title: "ORGANIZER",
                value: meeting.organizer ?? "Not specified",
                iconSize: 28
            )
        }
        .frame(height: 86)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.055))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 66)
    }

    private var verticalDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(width: 1)
            .padding(.vertical, 1)
    }

    private var actions: some View {
        VStack(spacing: 24) {
            PrimaryOverlayAction(title: "JOIN MEETING", action: onJoin)

            HStack(spacing: 24) {
                SecondaryOverlayAction(
                    icon: "clock.arrow.circlepath",
                    title: "POSTPONE",
                    subtitle: "Remind me later",
                    action: onPostpone
                )

                SecondaryOverlayAction(
                    icon: "xmark.circle",
                    title: "DISMISS",
                    subtitle: "No more reminders",
                    action: onDismiss
                )
            }
            .frame(height: 84)
        }
    }

    private var footer: some View {
        Label("This window will stay until you choose an action.", systemImage: "lock.fill")
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(Color.white.opacity(0.44))
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.10, green: 0.13, blue: 0.20).opacity(0.92),
                        Color(red: 0.045, green: 0.06, blue: 0.11).opacity(0.94)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var cardStroke: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        Color(red: 0.28, green: 0.58, blue: 1).opacity(0.62),
                        Color.white.opacity(0.18),
                        Color(red: 0.28, green: 0.58, blue: 1).opacity(0.34)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.2
            )
    }

    private var datePillText: String {
        let calendar = Calendar.current
        let time = meeting.startDate.formatted(date: .omitted, time: .shortened)

        if calendar.isDateInToday(meeting.startDate) {
            return "Today at \(time)"
        }

        if calendar.isDateInTomorrow(meeting.startDate) {
            return "Tomorrow at \(time)"
        }

        let date = meeting.startDate.formatted(.dateTime.month(.abbreviated).day())
        return "\(date) at \(time)"
    }

    private var countdownTitle: String {
        meeting.startDate >= Date() ? "STARTS IN" : "STARTED"
    }

    private var countdownValue: String {
        let remaining = abs(meeting.startDate.timeIntervalSince(Date()))
        let hours = Int(remaining) / 3_600
        let minutes = (Int(remaining) % 3_600) / 60
        let value = String(format: "%dh %02dm", hours, minutes)

        if meeting.startDate < Date() {
            return "\(value) ago"
        }

        return value
    }
}

private struct InfoTile: View {
    let icon: String
    let title: String
    let value: String
    let iconSize: CGFloat
    var valueColor: Color = .white.opacity(0.88)

    var body: some View {
        HStack(spacing: 18) {
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .regular))
                .foregroundStyle(Color(red: 0.20, green: 0.47, blue: 0.9))
                .frame(width: 34)

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(1.4)
                    .foregroundStyle(Color.white.opacity(0.56))

                Text(value)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(valueColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct PrimaryOverlayAction: View {
    let title: String
    let action: () -> Void
    @State private var isHovered = false
    @FocusState private var isFocused: Bool

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer(minLength: 0)
                Text(title)
                    .font(.system(size: 39, weight: .heavy))
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 98, maxHeight: 98)
            .contentShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
        }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 44, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isHovered ? [
                                Color(red: 0.04, green: 0.48, blue: 0.88),
                                Color(red: 0.05, green: 0.10, blue: 0.84)
                            ] : [
                                Color(red: 0.05, green: 0.58, blue: 1),
                                Color(red: 0.07, green: 0.13, blue: 0.96)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(red: 0.05, green: 0.33, blue: 1).opacity(0.45), radius: 22, y: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 44, style: .continuous)
                    .strokeBorder(Color.white.opacity(isFocused ? 0.78 : 0), lineWidth: 3)
                    .shadow(color: Color.white.opacity(isFocused ? 0.44 : 0), radius: 6)
            )
            .focused($isFocused)
            .onHover { isHovered = $0 }
            .onAppear(perform: focusJoinButton)
            .animation(.easeOut(duration: 0.12), value: isHovered)
            .animation(.easeOut(duration: 0.12), value: isFocused)
    }

    private func focusJoinButton() {
        DispatchQueue.main.async {
            isFocused = true
        }
    }
}

private struct SecondaryOverlayAction: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    @State private var isHovered = false
    @FocusState private var isFocused: Bool

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .regular))
                    .frame(width: 38)

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                    Text(subtitle)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.58))
                }

                Spacer()
            }
            .padding(.horizontal, 44)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isHovered ? [
                                Color.white.opacity(0.10),
                                Color.white.opacity(0.035)
                            ] : [
                                Color.white.opacity(0.14),
                                Color.white.opacity(0.055)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.white.opacity(isFocused ? 0.58 : 0.22), lineWidth: isFocused ? 2 : 1)
                    )
            )
            .focused($isFocused)
            .onHover { isHovered = $0 }
            .animation(.easeOut(duration: 0.12), value: isHovered)
            .animation(.easeOut(duration: 0.12), value: isFocused)
    }
}
