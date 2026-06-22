import CryptoKit
import EventKit
import Foundation

@MainActor
final class CalendarService {
    private let eventStore: EKEventStore
    private let detector: MeetingDetector
    private let calendar: Calendar

    init(
        eventStore: EKEventStore = EKEventStore(),
        detector: MeetingDetector = MeetingDetector(),
        calendar: Calendar = .current
    ) {
        self.eventStore = eventStore
        self.detector = detector
        self.calendar = calendar
    }

    func currentAccessState() -> CalendarAccessState {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized, .fullAccess:
            return .authorized
        case .denied, .restricted, .writeOnly:
            return .denied
        case .notDetermined:
            return .unknown
        @unknown default:
            return .unknown
        }
    }

    func requestAccess() async -> CalendarAccessState {
        if currentAccessState() == .authorized {
            return .authorized
        }

        do {
            let granted: Bool
            if #available(macOS 14.0, *) {
                granted = try await eventStore.requestFullAccessToEvents()
            } else {
                granted = try await eventStore.requestAccess(to: .event)
            }

            return granted ? .authorized : .denied
        } catch {
            return .denied
        }
    }

    func fetchTodaysMeetings(now: Date = Date()) -> [Meeting] {
        let startOfDay = calendar.startOfDay(for: now)
        guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) else {
            return []
        }

        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        return eventStore.events(matching: predicate)
            .filter { !$0.isAllDay && $0.endDate > now }
            .compactMap(makeMeeting(from:))
            .sorted { $0.startDate < $1.startDate }
    }

    func fetchFirstPreviewMeeting(now: Date = Date(), daysAhead: Int = 10) -> Meeting? {
        let startOfToday = calendar.startOfDay(for: now)
        guard let searchEndDay = calendar.date(byAdding: .day, value: daysAhead, to: startOfToday),
              let searchEnd = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: searchEndDay) else {
            return nil
        }

        let predicate = eventStore.predicateForEvents(withStart: startOfToday, end: searchEnd, calendars: nil)
        return eventStore.events(matching: predicate)
            .filter { !$0.isAllDay }
            .compactMap(makeMeeting(from:))
            .sorted { $0.startDate < $1.startDate }
            .first
    }

    private func makeMeeting(from event: EKEvent) -> Meeting? {
        let values = [
            event.url?.absoluteString,
            event.notes,
            event.location,
            event.title
        ]

        guard let url = detector.firstMeetingURL(in: values) else {
            return nil
        }

        return Meeting(
            id: syncId(for: event),
            title: event.title.isEmpty ? "Untitled Meeting" : event.title,
            startDate: event.startDate,
            endDate: event.endDate,
            calendarTitle: event.calendar.title,
            url: url,
            calendarAccountEmail: calendarAccountEmail(for: event),
            organizer: organizerDisplayName(for: event)
        )
    }

    private func calendarAccountEmail(for event: EKEvent) -> String? {
        [
            event.calendar.source.title,
            event.calendar.source.sourceIdentifier,
            event.calendar.title
        ]
        .compactMap(emailAddress(in:))
        .first
    }

    private func emailAddress(in value: String?) -> String? {
        guard let value else {
            return nil
        }

        let pattern = #"[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}"#
        guard let expression = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
              let match = expression.firstMatch(in: value, range: NSRange(value.startIndex..<value.endIndex, in: value)),
              let range = Range(match.range, in: value) else {
            return nil
        }

        return String(value[range])
    }

    private func organizerDisplayName(for event: EKEvent) -> String? {
        guard let organizer = event.organizer else {
            return nil
        }

        if let name = organizer.name, !name.isEmpty {
            return name
        }

        let url = organizer.url
        if url.scheme == "mailto" {
            let email = url.absoluteString.replacingOccurrences(of: "mailto:", with: "")
            return email.removingPercentEncoding ?? email
        }

        return url.absoluteString
    }

    private func syncId(for event: EKEvent) -> String {
        let externalIdentifier = event.calendarItemExternalIdentifier ?? ""
        if !externalIdentifier.isEmpty {
            return externalIdentifier
        }

        let raw = "\(event.title ?? "")|\(event.startDate.timeIntervalSince1970)|\(event.endDate.timeIntervalSince1970)"
        return SHA256.hash(data: Data(raw.utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
}
