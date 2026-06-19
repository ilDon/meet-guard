import Foundation
import Testing
@testable import MeetGuard

@Suite("ReminderScheduler")
struct ReminderSchedulerTests {
    @Test("shows meeting inside lead time")
    func showsInsideLeadTime() {
        let scheduler = ReminderScheduler()
        let now = Date(timeIntervalSince1970: 1_000)
        let meeting = makeMeeting(start: now.addingTimeInterval(5 * 60))

        let decision = scheduler.nextDecision(meetings: [meeting], now: now, leadTime: .five)
        #expect(decision.action == .show(meeting))
    }

    @Test("does not show meeting before lead time")
    func doesNotShowBeforeLeadTime() {
        let scheduler = ReminderScheduler()
        let now = Date(timeIntervalSince1970: 1_000)
        let meeting = makeMeeting(start: now.addingTimeInterval(6 * 60))

        let decision = scheduler.nextDecision(meetings: [meeting], now: now, leadTime: .five)
        #expect(decision.action == .none)
    }

    @Test("shows meeting already in progress")
    func showsInProgressMeeting() {
        let scheduler = ReminderScheduler()
        let now = Date(timeIntervalSince1970: 1_000)
        let meeting = makeMeeting(
            start: now.addingTimeInterval(-60),
            end: now.addingTimeInterval(29 * 60)
        )

        let decision = scheduler.nextDecision(meetings: [meeting], now: now, leadTime: .five)
        #expect(decision.action == .show(meeting))
    }

    @Test("does not show meeting that already ended")
    func doesNotShowEndedMeeting() {
        let scheduler = ReminderScheduler()
        let now = Date(timeIntervalSince1970: 1_000)
        let meeting = makeMeeting(
            start: now.addingTimeInterval(-30 * 60),
            end: now.addingTimeInterval(-60)
        )

        let decision = scheduler.nextDecision(meetings: [meeting], now: now, leadTime: .five)
        #expect(decision.action == .none)
    }

    @Test("dismiss prevents later alerts")
    func dismissPreventsLaterAlerts() {
        let scheduler = ReminderScheduler()
        let now = Date(timeIntervalSince1970: 1_000)
        let meeting = makeMeeting(start: now.addingTimeInterval(5 * 60))

        let decision = scheduler.nextDecision(
            meetings: [meeting],
            now: now,
            leadTime: .five,
            dismissedSyncIds: [meeting.id]
        )
        #expect(decision.action == .none)
    }

    @Test("postpone waits for percentage of remaining time")
    func postponeWaitsForPercentageOfRemainingTime() {
        let scheduler = ReminderScheduler()
        let now = Date(timeIntervalSince1970: 1_000)
        let meeting = makeMeeting(start: now.addingTimeInterval(8 * 60))

        let nextDate = scheduler.postpone(meeting, now: now, factor: .half)

        #expect(nextDate == now.addingTimeInterval(4 * 60))
        #expect(scheduler.nextDecision(meetings: [meeting], now: now.addingTimeInterval(3 * 60), leadTime: .five).action == .none)
        #expect(scheduler.nextDecision(meetings: [meeting], now: now.addingTimeInterval(4 * 60), leadTime: .five).action == .show(meeting))
    }

    private func makeMeeting(start: Date, end: Date? = nil) -> Meeting {
        Meeting(
            id: "event-1",
            title: "Weekly Product Review",
            startDate: start,
            endDate: end ?? start.addingTimeInterval(30 * 60),
            calendarTitle: "Work",
            url: URL(string: "https://meet.google.com/abc-defg-hij")!
        )
    }
}
