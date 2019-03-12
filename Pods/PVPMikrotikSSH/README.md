# PVPMikrotikSSH

Simple SSH manager that uses NMSSH library for making SSH connection to MikroTik routers or any other router that use RouterOS

## Installing

`pod 'PVPMikrotikSSH', :git => 'https://github.com/BlindDev/PVPMikrotikSSH.git’`

## Usage

Here is an example of using PVPSSHManager 

Crate custom class to use with PVPSSHManager

Import framework first

`import PVPMikrotikSSH`

Add basic initialization
```
class SSHManager {

    private var pvpManager: PVPSSHManager
    static let defaultHost = "192.168.88.1"

    init(host: String, userName: String, password: String?) {

        pvpManager = PVPSSHManager(host: host, userName: userName, password: password)
    }

    convenience init() {
        self.init(host: SSHManager.defaultHost, userName: "admin", password: "")
    }
} 
```

To start outhentication, add function to the SSHManager:
```
func initiateConnection(completion: ((_ success: Bool) -> Void)?) {

        pvpManager.connectSessionAndAuthorize {(error) in

            if let sessionError = error {
                switch sessionError {
                case .noPassword:
                    print("Session not connected: No password")

                    completion?(false)
                case .notConnected:
                    print("Session not connected")

                    completion?(false)

                case .notAuthorized:
                    print("Session not authorized")

                    completion?(false)

                default:
                    //there are few more types of errors just use them if you need
                    print("Session is not connected")
                    completion?(false)
                }
            }else{
                print("Session connected")
                completion?(true)
            }
        }
    }
```

## Sending commands API
```
    public func sendCommand(command: String, completionHandler: @escaping (PVPMikrotikSSH.PVPError?) -> Swift.Void)

    public func executeCommand(command: String, completionHandler: @escaping (PVPMikrotikSSH.PVPError?, String?) -> Swift.Void)

    public func writeBunch(commands: [String], completionHandler: @escaping (PVPMikrotikSSH.PVPError?, [String]?) -> Swift.Void)

    public func executeBunch(commands: [String], completionHandler: @escaping (PVPMikrotikSSH.PVPError?, [String]?) -> Swift.Void)

```
## Delegate methods
```
@objc public protocol PVPSSHManagerDelegate {

    @objc optional public func sessionDidDisconnectWithError(error: Error)

    @objc optional public func channelDidReadData(message: String)

    @objc optional public func channelDidReadError(error: String)

    @objc optional public func channelShellDidClose()

    @objc optional public func additionalErrorReceived(error: Error)
}
```
## Built With

NMSSH - An Objective-C SSH library

## Versioning

For the versions available, see the tags on this repository.

## Authors

Pavel Popov - Initial work

## License

This project is licensed under the MIT License - see the LICENSE.md file for details
