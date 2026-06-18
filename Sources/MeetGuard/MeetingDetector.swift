import Foundation

struct MeetingDetector: Sendable {
    private let expressions: [NSRegularExpression]

    init() {
        let patterns = [
            #"https?://[^\s<>"']*meet\.google\.com[^\s<>"']*"#,
            #"https?://[^\s<>"']*(?:^|[./])zoom\.us[^\s<>"']*"#,
            #"https?://[^\s<>"']*teams\.microsoft\.com[^\s<>"']*"#,
            #"https?://[^\s<>"']*teams\.live\.com[^\s<>"']*"#,
            #"https?://[^\s<>"']*webex\.com[^\s<>"']*"#,
            #"https?://[^\s<>"']*/join[^\s<>"']*"#,
            #"https?://[^\s<>"']*/meeting[^\s<>"']*"#
        ]

        expressions = patterns.compactMap {
            try? NSRegularExpression(pattern: $0, options: [.caseInsensitive])
        }
    }

    func firstMeetingURL(in values: [String?]) -> URL? {
        for value in values.compactMap({ $0 }) {
            if let url = firstMeetingURL(in: value) {
                return url
            }
        }

        return nil
    }

    func firstMeetingURL(in value: String) -> URL? {
        let range = NSRange(value.startIndex..<value.endIndex, in: value)

        for expression in expressions {
            guard let match = expression.firstMatch(in: value, range: range),
                  let swiftRange = Range(match.range, in: value) else {
                continue
            }

            let candidate = String(value[swiftRange]).trimmingCharacters(in: .meetGuardURLTerminators)
            if let url = URL(string: candidate), url.scheme?.hasPrefix("http") == true {
                return url
            }
        }

        return nil
    }
}

private extension CharacterSet {
    static let meetGuardURLTerminators = CharacterSet(charactersIn: ".,);]\n\r\t ")
}
