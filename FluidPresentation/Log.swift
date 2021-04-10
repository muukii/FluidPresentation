
import os.log

enum Log {

  static func debug(_ log: OSLog, _ object: Any...) {
    os_log(.debug, log: log, "%@", object.map { "\($0)" }.joined(separator: " "))
  }

  static func error(_ log: OSLog, _ object: Any...) {
    os_log(.error, log: log, "%@", object.map { "\($0)" }.joined(separator: " "))
  }
}

extension OSLog {

  static let generic: OSLog = {
    #if DEBUG
    return OSLog.init(subsystem: "FluidViewController", category: "general")
    #else
    return .disabled
    #endif
  }()

}

