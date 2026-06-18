import SwiftUI

struct PermissionDeniedOverlayView: View {
    let onOpenSettings: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.82)
                .ignoresSafeArea()

            VStack(spacing: 26) {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(.white)

                Text("MeetGuard requires access to Calendar\nto detect upcoming meetings.")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Button(action: onOpenSettings) {
                    Label("Open System Settings", systemImage: "gear")
                        .font(.system(size: 20, weight: .bold))
                        .frame(minWidth: 280, minHeight: 58)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(42)
            .frame(width: 640)
            .frame(minHeight: 360)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}
