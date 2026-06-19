import Foundation

enum PomodoroPhase: String, CaseIterable, Codable {
    case work
    case breakTime

    var title: String {
        switch self {
        case .work:
            return "Work"
        case .breakTime:
            return "Break"
        }
    }

    var completionTitle: String {
        switch self {
        case .work:
            return "Work timer finished"
        case .breakTime:
            return "Break timer finished"
        }
    }

    var next: PomodoroPhase {
        switch self {
        case .work:
            return .breakTime
        case .breakTime:
            return .work
        }
    }

    var systemImage: String {
        switch self {
        case .work:
            return "timer"
        case .breakTime:
            return "cup.and.saucer"
        }
    }
}
