import Foundation
import Testing
@testable import MeetGuard

@Suite("CalendarService")
struct CalendarServiceTests {
    @Test("sync id differentiates recurring event occurrences")
    func syncIdDifferentiatesRecurringEventOccurrences() {
        let firstStart = Date(timeIntervalSince1970: 2_000)
        let secondStart = Date(timeIntervalSince1970: 3_800)

        let firstID = MeetingSyncID.make(
            externalIdentifier: "recurring-series",
            title: "Standup",
            startDate: firstStart,
            endDate: firstStart.addingTimeInterval(30 * 60)
        )
        let secondID = MeetingSyncID.make(
            externalIdentifier: "recurring-series",
            title: "Standup",
            startDate: secondStart,
            endDate: secondStart.addingTimeInterval(30 * 60)
        )

        #expect(firstID != secondID)
    }

    @Test("sync id is stable for the same occurrence")
    func syncIdIsStableForSameOccurrence() {
        let start = Date(timeIntervalSince1970: 2_000)
        let end = start.addingTimeInterval(30 * 60)

        let firstID = MeetingSyncID.make(
            externalIdentifier: "recurring-series",
            title: "Standup",
            startDate: start,
            endDate: end
        )
        let secondID = MeetingSyncID.make(
            externalIdentifier: "recurring-series",
            title: "Renamed Standup",
            startDate: start,
            endDate: end
        )

        #expect(firstID == secondID)
    }
}
