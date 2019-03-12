//
//  PVPConnectionManager.swift
//  PVPMikrotikSSH
//
//  Created by Pavel Popov on 22.04.17.
//  Copyright © 2017 Pavel Popov. All rights reserved.
//

import Foundation

@objc public protocol PVPSSHManagerDelegate {
    @objc optional func sessionDidDisconnectWithError(error: Error)
    @objc optional func channelDidReadData(message: String)
    @objc optional func channelDidReadError(error: String)
    @objc optional func channelShellDidClose()
    @objc optional func additionalErrorReceived(error: Error)
}

open class PVPSSHManager {
    
    fileprivate let pvpSecure: PVPSSHSecureObject
    
    //public stored vars
    public var delegate: PVPSSHManagerDelegate?
    
    //initialization
    public init(host: String, userName: String, password: String? = nil) {
        pvpSecure = PVPSSHSecureObject(host: host, userName: userName, password: password)
        pvpSecure.delegate = self
    }
    
    //public computed vars
    public var isConnected: Bool {
        return pvpSecure.isConnected
    }
    
    public var isAuthorized: Bool {
        return pvpSecure.isAuthorized
    }
}

//MARK: - Commands methods
extension PVPSSHManager{
    //send command
    public func sendCommand(command: String, completionHandler: @escaping (_ error: PVPError?) -> Void) {
        
        pvpSecure.sendCommand(command: command, completionHandler: completionHandler)
    }
    
    //execute command
    public func executeCommand(command: String, completionHandler: @escaping (_ error: PVPError?, _ string: String?) -> Void) {
        
        pvpSecure.executeCommand(command: command, completionHandler: completionHandler)
    }
    
    //write bunch of commands
    //If session channel is exist, then the handler will return only errors with sending commands
    //an empty results array means that there was not any error writnig commands
    public func writeBunch(commands: [String], completionHandler: @escaping (_ error: PVPError?, _ results: [String]?) -> Void) {
        
        pvpSecure.writeBunch(commands: commands, completionHandler: completionHandler)
        
    }
    
    //execute bunch of commands
    //If session channel is exist, then the handler will send an array of answers.
    //An empty string in the results array means that there is no error with this command
    public func executeBunch(commands: [String], completionHandler: @escaping (_ error: PVPError?, _ results: [String]?) -> Void) {
        
        pvpSecure.executeBunch(commands: commands, completionHandler: completionHandler)
    }
}

//MARK: - Session public methods
extension PVPSSHManager {
    
    //connecting session and authorizing
    public func connectSessionAndAuthorize(completionHandler: @escaping (_ error: PVPError?) -> Void) {
        pvpSecure.connectSessionAndAuthorize(completionHandler: completionHandler)
    }
    
    public func checkAuthentication() -> Bool {
        
        return pvpSecure.checkAuthentication()
    }
    
    //initiating session with existing username and host
    public func initiateSession() {
        return pvpSecure.initiateSession()
    }
    
    public func disconnect() {
        pvpSecure.disconnect()
    }
    
    public func connect() {
        pvpSecure.connect()
    }
    
    public func authenticate() {
        pvpSecure.authenticate()
    }
    
    public func startShell(completionHandler: @escaping (_ error: PVPError?) -> Void) {
       pvpSecure.startShell(completionHandler: completionHandler)
    }
    
    public func closeShell() {
        pvpSecure.closeShell()
    }
}

extension PVPSSHManager: PVPSSHManagerSecureDelegate {
    func secureSessionDidDisconnectWithError(error: Error) {
        delegate?.sessionDidDisconnectWithError?(error: error)
    }
    func secureChannelDidReadData(message: String){
        delegate?.channelDidReadData?(message: message)
    }
    func secureChannelDidReadError(error: String){
        delegate?.channelDidReadError?(error: error)
    }
    func secureChannelShellDidClose(){
        delegate?.channelShellDidClose?()
    }
    func secureAdditionalErrorReceived(error: Error){
        delegate?.additionalErrorReceived?(error: error)
    }
}
