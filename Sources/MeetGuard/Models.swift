import Foundation

struct Meeting: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let calendarTitle: String
    let url: URL
    var calendarAccountEmail: String? = nil
    var organizer: String? = nil

    var joinURL: URL {
        MeetingURLAuthenticator.authenticatedURL(url, calendarAccountEmail: calendarAccountEmail)
    }
}

struct DismissedEvent: Codable, Equatable, Sendable {
    let syncId: String
    let timestamp: TimeInterval
}

enum CalendarAccessState: Equatable, Sendable {
    case unknown
    case authorized
    case denied
}

enum ReminderLeadTime: Int, CaseIterable, Identifiable, Sendable {
    case one = 1
    case two = 2
    case five = 5
    case ten = 10
    case fifteen = 15
    case thirty = 30

    var id: Int { rawValue }
    var label: String { "\(rawValue) minute\(rawValue == 1 ? "" : "s")" }
    var timeInterval: TimeInterval { TimeInterval(rawValue * 60) }
}

enum RefreshInterval: Int, CaseIterable, Identifiable, Sendable {
    case one = 1
    case two = 2
    case five = 5

    var id: Int { rawValue }
    var label: String { "\(rawValue) minute\(rawValue == 1 ? "" : "s")" }
    var timeInterval: TimeInterval { TimeInterval(rawValue * 60) }
}

enum PostponeFactor: Double, CaseIterable, Identifiable, Sendable {
    case quarter = 0.25
    case half = 0.5
    case threeQuarters = 0.75

    var id: Double { rawValue }
    var label: String {
        switch self {
        case .quarter:
            "25% of remaining time"
        case .half:
            "50% of remaining time"
        case .threeQuarters:
            "75% of remaining time"
        }
    }
}
