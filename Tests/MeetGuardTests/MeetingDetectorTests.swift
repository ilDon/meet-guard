import Foundation
import Testing
@testable import MeetGuard

@Suite("MeetingDetector")
struct MeetingDetectorTests {
    @Test("detects Google Meet links")
    func detectsGoogleMeet() throws {
        let detector = MeetingDetector()
        let url = try #require(detector.firstMeetingURL(in: "Join https://meet.google.com/abc-defg-hij now"))
        #expect(url.absoluteString == "https://meet.google.com/abc-defg-hij")
    }

    @Test("detects Zoom subdomains")
    func detectsZoomSubdomains() throws {
        let detector = MeetingDetector()
        let url = try #require(detector.firstMeetingURL(in: "https://company.zoom.us/j/123456789?pwd=test"))
        #expect(url.host == "company.zoom.us")
    }

    @Test("detects Teams and strips punctuation")
    func detectsTeamsAndStripsPunctuation() throws {
        let detector = MeetingDetector()
        let url = try #require(detector.firstMeetingURL(in: "Link: https://teams.microsoft.com/l/meetup-join/abc)."))
        #expect(url.absoluteString == "https://teams.microsoft.com/l/meetup-join/abc")
    }

    @Test("detects generic join URL")
    func detectsGenericJoinURL() throws {
        let detector = MeetingDetector()
        let url = try #require(detector.firstMeetingURL(in: "https://example.com/join/room-42"))
        #expect(url.absoluteString == "https://example.com/join/room-42")
    }

    @Test("ignores non-meeting URLs")
    func ignoresNonMeetingURLs() {
        let detector = MeetingDetector()
        #expect(detector.firstMeetingURL(in: "https://example.com/blog") == nil)
    }
}
