//
//  PVPError.swift
//  PVPMikrotikSSH
//
//  Created by Pavel Popov on 05.05.17.
//  Copyright © 2017 Pavel Popov. All rights reserved.
//

import Foundation

public enum PVPError {
    
    case errorWritingCommand(command: String, error: Error)
    case errorExecutingCommand(command: String, error: Error)
    case noPassword
    case notConnected
    case notAuthorized
    case noSessionChannel
    case shellNotStarted(error: Error)
    
    public var info: String {
        switch self {
        case .errorWritingCommand(let command, let error):
            return "Error writing command \(command)\n\(error.localizedDescription)"
        case .errorExecutingCommand(let command, let error):
            return "Error executing command \(command)\n\(error.localizedDescription)"
        case .noPassword:
            return "Error checking password"
        case .notConnected:
            return "Error establishing connection"
        case .notAuthorized:
            return "Error authenticating user"
        case .noSessionChannel:
            return "Error initiating channel"
        case .shellNotStarted(let error):
            return "Error starting shell\n\(error.localizedDescription)"
        }
    }
}
