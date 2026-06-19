import Foundation

enum TimeFormatter {
    static let short: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()

    static let long: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()

    static func shortString(from seconds: Int) -> String {
        short.string(from: TimeInterval(seconds)) ?? "00:00"
    }

    static func longString(from seconds: Int) -> String {
        long.string(from: TimeInterval(seconds)) ?? "00:00"
    }
}
