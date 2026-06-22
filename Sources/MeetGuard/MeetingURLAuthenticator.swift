import Foundation

struct MeetingURLAuthenticator: Sendable {
    static func authenticatedURL(_ url: URL, calendarAccountEmail: String?) -> URL {
        guard let calendarAccountEmail,
              !calendarAccountEmail.isEmpty,
              let host = url.host?.lowercased(),
              host == "google.com" || host.hasSuffix(".google.com"),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url
        }

        var queryItems = components.queryItems ?? []
        if let index = queryItems.firstIndex(where: { $0.name == "authuser" }) {
            queryItems[index].value = calendarAccountEmail
        } else {
            queryItems.append(URLQueryItem(name: "authuser", value: calendarAccountEmail))
        }

        components.queryItems = queryItems
        return components.url ?? url
    }
}
