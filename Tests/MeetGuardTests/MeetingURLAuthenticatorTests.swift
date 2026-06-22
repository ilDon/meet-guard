import Foundation
import Testing
@testable import MeetGuard

@Suite("MeetingURLAuthenticator")
struct MeetingURLAuthenticatorTests {
    @Test("adds authuser to Google Meet links")
    func addsAuthuserToGoogleMeetLinks() throws {
        let url = try #require(URL(string: "https://meet.google.com/abc-defg-hij"))

        let authenticatedURL = MeetingURLAuthenticator.authenticatedURL(
            url,
            calendarAccountEmail: "user@company.com"
        )

        let components = try #require(URLComponents(url: authenticatedURL, resolvingAgainstBaseURL: false))
        #expect(components.scheme == "https")
        #expect(components.host == "meet.google.com")
        #expect(components.path == "/abc-defg-hij")
        #expect(components.queryItems?.contains(URLQueryItem(name: "authuser", value: "user@company.com")) == true)
    }

    @Test("replaces existing authuser on Google links")
    func replacesExistingAuthuserOnGoogleLinks() throws {
        let url = try #require(URL(string: "https://calendar.google.com/calendar/event?eid=123&authuser=old@example.com"))

        let authenticatedURL = MeetingURLAuthenticator.authenticatedURL(
            url,
            calendarAccountEmail: "user@company.com"
        )

        let components = try #require(URLComponents(url: authenticatedURL, resolvingAgainstBaseURL: false))
        #expect(components.queryItems?.filter { $0.name == "authuser" } == [
            URLQueryItem(name: "authuser", value: "user@company.com")
        ])
        #expect(components.queryItems?.contains(URLQueryItem(name: "eid", value: "123")) == true)
    }

    @Test("leaves Google links unchanged without an account")
    func leavesGoogleLinksUnchangedWithoutAccount() throws {
        let url = try #require(URL(string: "https://meet.google.com/abc-defg-hij"))

        #expect(MeetingURLAuthenticator.authenticatedURL(url, calendarAccountEmail: nil) == url)
        #expect(MeetingURLAuthenticator.authenticatedURL(url, calendarAccountEmail: "") == url)
    }

    @Test("leaves non Google links unchanged")
    func leavesNonGoogleLinksUnchanged() throws {
        let url = try #require(URL(string: "https://company.zoom.us/j/123456789?pwd=test"))

        #expect(MeetingURLAuthenticator.authenticatedURL(url, calendarAccountEmail: "user@company.com") == url)
    }
}
