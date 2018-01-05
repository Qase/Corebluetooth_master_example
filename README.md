# CoreBluetooth Example (Master Mode)

Proof of Concept app to test behavior of CoreBluetooth on iOS. App contains State restoration, so app will be relaunched by system if dealloced from memory.

Peripheral app from [BLE_Prototype_iOS project](https://github.com/Qase/BLE_Prototype_iOS) can be used as bluetooth device, that this app would automatically scan and connect to.

## Application behavior on foreground

| Bluetooth powered On | Application state                   |  |  |  | 
|----------------------|-------------------------------------|--|--|--| 
| FALSE                | Works after bluetooth is Powered On |  |  |  | 
| TRUE                 | Works                               |  |  |  | 


## Application behavior on background

| State                      | Application works | Notes                                                                                                                                    | 
|----------------------------|-------------------|------------------------------------------------------------------------------------------------------------------------------------------| 
| Application quit by system | TRUE              |                                                                                                                                          | 
| Application quit by user   | FALSE             |                                                                                                                                          | 
| Application crashed        | TRUE              |                                                                                                                                          | 
| Bluetooth power toggled    | FALSE             | Toggle Bluetooth power either through Settings, or via Airplane mode                                                                     | 
| Airplane mode toogled      | TRUE              | Only if bluetooth power is not toggled                                                                                                   | 
| Device restarted           | TRUE              | If the device requires a passcode to unlock, apps will not be relaunched until the device is unlocked for the first time after a restart | 


## Bluetooth States
| State        | Application state                                     | Notes                                                                | Control Center |  | 
|--------------|-------------------------------------------------------|----------------------------------------------------------------------|----------------|--| 
| Powered off  | Works only if App remains in memory (suspended state) | Toggle Bluetooth power either through Settings, or via Airplane mode |                |  | 
| Partially on | Works after bluetooth state is changed to Powered On  | Toggled in Control Center                                            |                |  | 
| Powered on   | Works                                                 |                                                                      |                |  | 


## Application restoration on background (IF App WAS removed from memory)

| State                      | Application works | Notes                                                                                                                                    | 
|----------------------------|-------------------|------------------------------------------------------------------------------------------------------------------------------------------| 
| Application quit by system | TRUE              |                                                                                                                                          | 
| Application quit by user   | FALSE             |                                                                                                                                          | 
| Application crashed        | TRUE              |                                                                                                                                          | 
| Bluetooth power toggled    | FALSE             | Toggle Bluetooth power either through Settings, or via Airplane mode                                                                     | 
| Airplane mode toogled      | TRUE              | Only if bluetooth power is not toggled                                                                                                   | 
| Device restarted           | TRUE              | If the device requires a passcode to unlock, apps will not be relaunched until the device is unlocked for the first time after a restart | 



## Known issues

| Issue                                                                                    | State             | 
|------------------------------------------------------------------------------------------|-------------------| 
| App bluetooth state might be incorrectly set to Powered Off after toggling Airplane mode | Reported to Apple | 


## References

|                                                                         | Link                                                                                                                                                   | 
|-------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------| 
| Use Airplane Mode on your iPhone, iPad, iPod touch, and Apple Watch     | https://support.apple.com/en-us/HT204234                                                                                                               | 
| iOS 11 Beta bluetooth state issue                                       | https://forums.developer.apple.com/thread/83852                                                                                                        | 
| Conditions Under Which Bluetooth State Restoration Will Relaunch An App | https://developer.apple.com/library/content/qa/qa1962/_index.html                                                                                      | 
| Core Bluetooth Programming Guide                                        | https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/AboutCoreBluetooth/Introduction.html | 
