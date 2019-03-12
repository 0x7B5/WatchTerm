//
//  PVPSSHSecure.swift
//  PVPMikrotikSSH
//
//  Created by Pavel Popov on 14.10.17.
//  Copyright © 2017 Pavel Popov. All rights reserved.
//

import Foundation
import NMSSH

internal protocol PVPSSHManagerSecureDelegate {
    func secureSessionDidDisconnectWithError(error: Error)
    func secureChannelDidReadData(message: String)
    func secureChannelDidReadError(error: String)
    func secureChannelShellDidClose()
    func secureAdditionalErrorReceived(error: Error)
}

class PVPSSHSecureObject: NSObject {
    
    //log-in variables
    let host: String
    let userName: String
    var password: String?
    
    init(host: String, userName: String, password: String? = nil) {
        self.host = host
        self.userName = userName
        self.password = password
    }
    
    //NMSSH vars
    var session: NMSSHSession?
    var channel: NMSSHChannel? {
        return session?.channel
    }
    
    var delegate: PVPSSHManagerSecureDelegate?
    
    //computed vars
    var isConnected: Bool {
        return session?.isConnected ?? false
    }
    
    var isAuthorized: Bool {
        return session?.isAuthorized ?? false
    }
    
    //Queues
    let sshQueue = DispatchQueue(label: "SSH Queue", qos: .default)
    let mainQueue = DispatchQueue.main
}
//MARK: - Commands methods
extension PVPSSHSecureObject{
    //send command
    func sendCommand(command: String, completionHandler: @escaping (_ error: PVPError?) -> Void) {
        
        if let channel = channel {
            sshQueue.async {
                self.sendCommand(channel: channel, command: command, completionHandler: completionHandler)
            }
        }else{
            completionHandler(PVPError.noSessionChannel)
        }
    }
    
    //func send command inside ssh queue
    fileprivate func sendCommand(channel: NMSSHChannel, command: String, completionHandler: @escaping (_ error: PVPError?) -> Void) {
        do {
            
            try channel.write(command)
            
        }catch let error {
            
            mainQueue.async {
                completionHandler(PVPError.errorWritingCommand(command: command, error: error))
            }
        }
    }
    
    //execute command
    func executeCommand(command: String, completionHandler: @escaping (_ error: PVPError?, _ string: String?) -> Void) {
        
        if let channel = channel {
            sshQueue.async {
                self.executeCommand(channel: channel, command: command, completionHandler: completionHandler)
            }
        }else{
            completionHandler(PVPError.noSessionChannel, nil)
        }
    }
    
    //execute command inside ssh queue
    fileprivate func executeCommand(channel: NMSSHChannel, command: String, completionHandler: @escaping (_ error: PVPError?, _ string: String?) -> Void) {
        do {
            
            let response = try channel.execute(command)
            
            mainQueue.async {
                completionHandler(nil, response)
            }
        }catch let error {
            
            mainQueue.async {
                completionHandler(PVPError.errorExecutingCommand(command: command, error: error), nil)
            }
        }
    }
    
    //write bunch of commands
    //If session channel is exist, then the handler will return only errors with sending commands
    //an empty results array means that there was not any error writnig commands
    func writeBunch(commands: [String], completionHandler: @escaping (_ error: PVPError?, _ results: [String]?) -> Void) {
        
        
        //writing bunch of commands. Each command will have one second delay
        //checking channel
        if let channel = channel {
            //entering ssh queue
            sshQueue.async { [weak self] in
                
                var answers: [String] = []
                //creating dispatch group
                let dispatchGroup = DispatchGroup()
                
                //executing command one-by-one
                for command in commands {
                    
                    //entering dispatch group
                    dispatchGroup.enter()
                    
                    let deadLine = DispatchTime.now() + 1.0
                    
                    //sending async command with delay
                    self?.sshQueue.asyncAfter(deadline: deadLine, execute: {
                        
                        //leave dispatch group in any case
                        
                        //trying send command
                        do {
                            try channel.write(command)
                            
                            dispatchGroup.leave()
                            
                        }catch let error {
                            
                            answers.append("Error: \(error.localizedDescription)")
                            
                            dispatchGroup.leave()
                        }
                    })
                    
                }
                
                //making notification in the main queue when all commands will be sent
                dispatchGroup.notify(queue: self?.mainQueue ?? DispatchQueue.main, execute: {
                    completionHandler(nil, answers)
                })
            }
        }else{
            //complete when there is no channel
            completionHandler(PVPError.noSessionChannel, nil)
        }
    }
    
    //execute bunch of commands
    //If session channel is exist, then the handler will send an array of answers.
    //An empty string in the results array means that there is no error with this command
    func executeBunch(commands: [String], completionHandler: @escaping (_ error: PVPError?, _ results: [String]?) -> Void) {
        
        //executing bunch of commands. Each command will have one second delay
        //checking channel
        if let channel = channel {
            //entering ssh queue
            sshQueue.async { [weak self] in
                
                var answers: [String] = []
                //creating dispatch group
                let dispatchGroup = DispatchGroup()
                
                //executing command one-by-one
                for command in commands {
                    
                    //entering dispatch group
                    dispatchGroup.enter()
                    
                    let deadLine = DispatchTime.now() + 1.0
                    
                    //sending async command with delay
                    self?.sshQueue.asyncAfter(deadline: deadLine, execute: {
                        //trying send command
                        
                        //leave dispatch group in any case
                        
                        do {
                            let response = try channel.execute(command)
                            
                            answers.append(response)
                            dispatchGroup.leave()
                        }catch let error {
                            answers.append("Error: \(error.localizedDescription)")
                            dispatchGroup.leave()
                        }
                    })
                    
                }
                
                //making notification in the main queue when all commands will be sent
                dispatchGroup.notify(queue: self?.mainQueue ?? DispatchQueue.main, execute: {
                    completionHandler(nil, answers)
                })
            }
        }else{
            //complete when there is no channel
            completionHandler(PVPError.noSessionChannel, nil)
        }
        
    }
}

//MARK: - Session public methods
extension PVPSSHSecureObject {
    
    //connecting session and authorizing
    func connectSessionAndAuthorize(completionHandler: @escaping (_ error: PVPError?) -> Void) {
        
        guard password != nil else {
            
            completionHandler(PVPError.noPassword)
            return
        }
        
        //if we already have a session, disconnect then
        if isConnected {
            disconnect()
            session = nil
        }
        
        //all methods should call inside ssh queue
        sshQueue.async {
            
            //initiating session
            self.session = NMSSHSession.connect(toHost: self.host, withUsername: self.userName)
            self.session?.delegate = self
            
            //check if session is not connected
            if self.isConnected == false {
                self.mainQueue.async {
                    completionHandler(PVPError.notConnected)
                }
                return
            }
            
            //authenticating
            let authorized = self.checkAuthentication()
            
            //check if session is not authenticated
            if authorized == false {
                self.mainQueue.async {
                    completionHandler(PVPError.notAuthorized)
                }
                return
            }
            
            //all is ok, go back to main queue
            self.mainQueue.async {
                completionHandler(nil)
            }
            
        }
    }
    
    func checkAuthentication() -> Bool {
        
        if isAuthorized {
            return true
        }
        
        guard let pass = password else {
            return false
        }
        
        var authorized: Bool
        
        //check that password cold be not sent in the router
        if pass.isEmpty {
            //execute simple command to check the result of the session
            do {
                
                //this line will need to open the session, but it will always return false for an empty pass
                _ = self.session?.authenticate(byPassword: "")
                
                let response = try self.channel?.execute("/put check")
                
                authorized = response?.contains("check") ?? false
                
            }catch {
                authorized = false
            }
            
            
        }else{
            authorized = self.session?.authenticate(byPassword: pass) ?? false
        }
        
        return authorized
    }
    
    //initiating session with existing username and host
    func initiateSession() {
        //if we already have a session, disconnect then
        if isConnected {
            disconnect()
            session = nil
        }
        
        session = NMSSHSession(host: self.host, andUsername: self.userName)
        session?.delegate = self
    }
    
    func disconnect() {
        if let session = session {
            sshQueue.async {
                session.disconnect()
            }
        }else{
            NMSSHLogger.shared().logError("Session is nil")
        }
    }
    
    func connect() {
        if let session = session {
            sshQueue.async {
                session.connect()
            }
        }else{
            NMSSHLogger.shared().logError("Session is nil")
        }
    }
    
    func authenticate() {
        if let session = session, let pass = password {
            sshQueue.async {
                session.authenticate(byPassword: pass)
            }
        }else{
            NMSSHLogger.shared().logError("Session is nil")
        }
    }
    
    func startShell(completionHandler: @escaping (_ error: PVPError?) -> Void) {
        if let channel = channel {
            channel.delegate = self
            channel.requestPty = true
            
            //trying to start
            sshQueue.async {
                do {
                    try channel.startShell()
                    
                    let deadLine = DispatchTime.now() + 2.0
                    
                    self.mainQueue.asyncAfter(deadline: deadLine) {
                        completionHandler(nil)
                    }
                }catch let error {
                    self.mainQueue.async {
                        completionHandler(PVPError.shellNotStarted(error: error))
                    }
                }
                
            }
        }else{
            NMSSHLogger.shared().logError("Channel is nil")
            completionHandler(PVPError.noSessionChannel)
        }
    }
    
    func closeShell() {
        if let channel = channel {
            
            sshQueue.async {
                channel.closeShell()
            }
        }else{
            NMSSHLogger.shared().logError("Channel is nil")
        }
    }
}

//MARK: - NMSSH Session Delegate
extension PVPSSHSecureObject: NMSSHSessionDelegate {
    
    public func session(_ session: NMSSHSession!, didDisconnectWithError error: Error!) {
        //use main queue to use this code for an interface
        mainQueue.async {
            self.delegate?.secureSessionDidDisconnectWithError(error: error)
        }
    }
}

//MARK: - NMSSH Channel Delegate
extension PVPSSHSecureObject: NMSSHChannelDelegate {
    
    public func channel(_ channel: NMSSHChannel!, didReadError error: String!) {
        //use main queue to use this code for an interface
        mainQueue.async {
            self.delegate?.secureChannelDidReadError(error: error)
        }
    }
    
    public func channel(_ channel: NMSSHChannel!, didReadData message: String!) {
        //use main queue to use this code for an interface
        mainQueue.async {
            self.delegate?.secureChannelDidReadData(message: message)
        }
    }
    
    public func channelShellDidClose(_ channel: NMSSHChannel!) {
        //use main queue to use this code for an interface
        mainQueue.async {
            self.delegate?.secureChannelShellDidClose()
        }
        
    }
}
