import Foundation

struct ReminderDecision: Equatable {
    enum Action: Equatable {
        case none
        case show(Meeting)
    }

    let action: Action
}

final class ReminderScheduler {
    private var activeMeetingIDs = Set<String>()
    private var postponedUntilByMeetingID: [String: Date] = [:]

    func nextDecision(
        meetings: [Meeting],
        now: Date,
        leadTime: ReminderLeadTime,
        dismissedSyncIds: Set<String> = []
    ) -> ReminderDecision {
        for meeting in meetings where shouldShow(
            meeting,
            now: now,
            leadTime: leadTime,
            dismissedSyncIds: dismissedSyncIds
        ) {
            activeMeetingIDs.insert(meeting.id)
            return ReminderDecision(action: .show(meeting))
        }

        return ReminderDecision(action: .none)
    }

    func markDismissed(_ meeting: Meeting) {
        activeMeetingIDs.remove(meeting.id)
        postponedUntilByMeetingID.removeValue(forKey: meeting.id)
    }

    func markJoined(_ meeting: Meeting) {
        markDismissed(meeting)
    }

    func postpone(_ meeting: Meeting, now: Date, factor: PostponeFactor) -> Date {
        activeMeetingIDs.remove(meeting.id)

        let remaining = max(0, meeting.startDate.timeIntervalSince(now))
        let interval = max(15, remaining * factor.rawValue)
        let nextDate = min(now.addingTimeInterval(interval), meeting.startDate)
        postponedUntilByMeetingID[meeting.id] = nextDate

        return nextDate
    }

    func clearPastState(now: Date) {
        postponedUntilByMeetingID = postponedUntilByMeetingID.filter { _, date in date >= now }
    }

    private func shouldShow(
        _ meeting: Meeting,
        now: Date,
        leadTime: ReminderLeadTime,
        dismissedSyncIds: Set<String>
    ) -> Bool {
        guard !dismissedSyncIds.contains(meeting.id),
              !activeMeetingIDs.contains(meeting.id),
              meeting.endDate > now else {
            return false
        }

        if let postponedUntil = postponedUntilByMeetingID[meeting.id] {
            return now >= postponedUntil
        }

        return now >= meeting.startDate.addingTimeInterval(-leadTime.timeInterval)
    }
}
