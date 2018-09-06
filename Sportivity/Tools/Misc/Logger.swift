//
//  Logger.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 21/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation

struct LoggerConstants {
    static let defualtMinLevel = LogLevel.verbose
}

public enum LogLevel: Int, CustomStringConvertible {
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
    case severe = 5
    
    public var description: String {
        switch self {
        case .verbose:
            return "VERBOSE"
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .warning:
            return "WARNING"
        case .error:
            return "ERROR"
        case .severe:
            return "SEVERE"
        }
    }
}

protocol LoggerType {
    func log(_ level: LogLevel, className: String, function: String, file: String, line: Int, message: String)
}

class Logger {
    public static var shared = Logger()
    
    var minLevel = LoggerConstants.defualtMinLevel
    
    func log(_ level: LogLevel, className: String? = nil, function: String = #function, file: String = #file, line: Int = #line, message: String) {
//        let dateFormat = DateFormat.custom("yyyy-MM-dd'T'HH:mm:ss")
//        let datePrefix = Date().string(format: dateFormat)
//        let datePrefix = ""
        
        guard level.rawValue >= self.minLevel.rawValue else  { return }
        
        let level = level.description
        var log = "\(level) - \(message)"
        if let className = className {
            log = "\(level) \(className).\(function):\(line) - \(message)"
        }
        print(log)
    }
}
