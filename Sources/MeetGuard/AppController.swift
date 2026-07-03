import AppKit
import Combine
import Foundation

@MainActor
final class AppController {
    private let settingsStore: SettingsStore
    private let calendarService: CalendarService
    private let scheduler: ReminderScheduler
    private let overlayManager: OverlayManager
    private let launchAtStartupService: LaunchAtStartupService

    private var timer: Timer?
    private var reminderActivity: NSObjectProtocol?
    private var visibleMeeting: Meeting?
    private var cancellables = Set<AnyCancellable>()

    init(
        settingsStore: SettingsStore,
        calendarService: CalendarService = CalendarService(),
        scheduler: ReminderScheduler = ReminderScheduler(),
        overlayManager: OverlayManager = OverlayManager(),
        launchAtStartupService: LaunchAtStartupService = LaunchAtStartupService()
    ) {
        self.settingsStore = settingsStore
        self.calendarService = calendarService
        self.scheduler = scheduler
        self.overlayManager = overlayManager
        self.launchAtStartupService = launchAtStartupService

        settingsStore.$launchAtStartup
            .dropFirst()
            .sink { [weak self] enabled in
                self?.launchAtStartupService.setEnabled(enabled)
            }
            .store(in: &cancellables)

        settingsStore.$reminderLeadTime
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.scan()
            }
            .store(in: &cancellables)

        settingsStore.$refreshInterval
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.installTimer()
                self?.scan()
            }
            .store(in: &cancellables)

        settingsStore.$dismissedEvents
            .dropFirst()
            .sink { [weak self] _ in
                self?.dismissVisibleAlertIfNeeded()
            }
            .store(in: &cancellables)

        NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.didWakeNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.scan()
                }
            }
            .store(in: &cancellables)
    }

    func start() {
        launchAtStartupService.setEnabled(settingsStore.launchAtStartup)
        beginReminderActivity()

        Task {
            let access = await calendarService.requestAccess()
            guard access == .authorized else {
                showPermissionDenied()
                return
            }

            scan()
            installTimer()
        }
    }

    func rescheduleTimer() {
        installTimer()
    }

    private func beginReminderActivity() {
        guard reminderActivity == nil else {
            return
        }

        reminderActivity = ProcessInfo.processInfo.beginActivity(
            options: [.userInitiatedAllowingIdleSystemSleep],
            reason: "MeetGuard needs timely calendar scans for meeting reminders."
        )
    }

    func showOverlayPreview() {
        let meeting: Meeting

        if calendarService.currentAccessState() == .authorized,
           let previewMeeting = calendarService.fetchFirstPreviewMeeting() {
            meeting = previewMeeting
        } else {
            meeting = dummyPreviewMeeting()
        }

        overlayManager.show(
            meeting: meeting,
            onJoin: { [weak self] _ in
                NSWorkspace.shared.open(meeting.joinURL)
                self?.visibleMeeting = nil
                self?.overlayManager.dismiss()
            },
            onPostpone: { [weak self] _ in
                self?.visibleMeeting = nil
                self?.overlayManager.dismiss()
            },
            onDismiss: { [weak self] _ in
                self?.visibleMeeting = nil
                self?.overlayManager.dismiss()
            }
        )
    }

    private func installTimer() {
        timer?.invalidate()
        let timer = Timer(timeInterval: settingsStore.refreshInterval.timeInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.scan()
            }
        }

        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func scan() {
        let now = Date()
        scheduler.clearPastState(now: now)

        let meetings = calendarService.fetchTodaysMeetings(now: now)
        let decision = scheduler.nextDecision(
            meetings: meetings,
            now: now,
            leadTime: settingsStore.reminderLeadTime,
            dismissedSyncIds: Set(settingsStore.dismissedEvents.map(\.syncId))
        )

        if case let .show(meeting) = decision.action {
            visibleMeeting = meeting
            overlayManager.show(
                meeting: meeting,
                onJoin: { [weak self] meeting in
                    guard let self else { return }
                    NSWorkspace.shared.open(meeting.joinURL)
                    settingsStore.markDismissed(meeting)
                    scheduler.markJoined(meeting)
                    visibleMeeting = nil
                    overlayManager.dismiss()
                },
                onPostpone: { [weak self] meeting in
                    guard let self else { return }
                    _ = scheduler.postpone(meeting, now: Date(), factor: settingsStore.postponeFactor)
                    visibleMeeting = nil
                    overlayManager.dismiss()
                },
                onDismiss: { [weak self] meeting in
                    guard let self else { return }
                    settingsStore.markDismissed(meeting)
                    scheduler.markDismissed(meeting)
                    visibleMeeting = nil
                    overlayManager.dismiss()
                }
            )
        }
    }

    private func dismissVisibleAlertIfNeeded() {
        guard let meeting = visibleMeeting, settingsStore.isDismissed(meeting) else {
            return
        }

        scheduler.markDismissed(meeting)
        visibleMeeting = nil
        overlayManager.dismiss()
    }

    private func showPermissionDenied() {
        overlayManager.showPermissionDenied {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    private func dummyPreviewMeeting() -> Meeting {
        let startDate = Date().addingTimeInterval(settingsStore.reminderLeadTime.timeInterval)

        return Meeting(
            id: "meetguard-preview",
            title: "Weekly Product Review",
            startDate: startDate,
            endDate: startDate.addingTimeInterval(30 * 60),
            calendarTitle: "Work Calendar",
            url: URL(string: "https://example.com")!,
            organizer: "organizer@example.com"
        )
    }
}
