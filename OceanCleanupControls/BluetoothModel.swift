
import CoreBluetooth

//##### DECLARATIONS
var controlBits: UInt8 = 0
let LEFT_BINARY: UInt8 = 0b00000001
let RIGHT_BINARY: UInt8 = 0b00000010
let TRASH_BINARY: UInt8 = 0b00000100
let FORWARD_BINARY: UInt8 = 0b00001000
let REVERSE_BINARY: UInt8 = 0b00010000

let ULTRASONIC_UUID: String = "48081061-A096-451D-983F-BABFABA3E394"
let LATITUDE_UUID: String = "5B7F4D5B-63AD-42EB-8074-FA3550CC44F8"
let LONGITUDE_UUID: String = "B36AC37E-2DC5-4B2D-8080-C9BBE38A54C1"
let SERVICE_UUID: [CBUUID]? = [CBUUID(string : "AE702E79-39EB-4993-B8DF-BE1718623C82")]
let HEADING_UUID: String = "59EDD414-7B19-417D-8264-C49F3C7E9929"

class BluetoothModel: NSObject, ObservableObject {
    //Bluetooth Model objects
    private var centralManager: CBCentralManager?
    private var peripherals: [CBPeripheral] = []
    @Published var peripheralNames: [String] = []
    var peripheralTimestamps : [String: Date] = [:]
    
    //Connection Objects and Values
    private var keepConnectionAlive : Bool = false
    private var connected_device: CBPeripheral?
    private var connected_device_name: String = ""
    private var characteristicToSendControlsTo: CBCharacteristic?

    //Sensor Data variables and objects
    private var ultrasonicCharacteristic: CBCharacteristic?
    @Published var ultrasonicDistance: Float32 = 0
    private var longitudeCharacteristic: CBCharacteristic?
    @Published var longitude: Float32 = 38.547012136671114
    private var latitudeCharacteristic: CBCharacteristic?
    @Published var latitude: Float32 = -121.76641854885486
    private var headingCharacteristic: CBCharacteristic?
    @Published var heading: Float32 = 0
    
    var scan_options = [CBCentralManagerScanOptionAllowDuplicatesKey: true]

    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
}


//##### CALLED ON STARTUP
extension BluetoothModel: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.centralManager?.scanForPeripherals(withServices: SERVICE_UUID, options: scan_options)
        }
    }
    
    //###### CALLED ON PERIPHERAL DISCOVERY
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let time = Date()
        //let time_formatting = DateFormatter()
        //time_formatting.dateFormat = "hh:mm:ss"
        //let timeString = time_formatting.string(from: time)
        //print(timeString)
        
        // if the peripheral does not have a valid name, return
        guard let name = peripheral.name else {
            return
        }
        
        peripheral.delegate = self
        if !peripherals.contains(peripheral) {
            // first check if its a valid peripheral
            //peripheral.discoverServices(nil)
            self.peripherals.append(peripheral)
            self.peripheralNames.append(name)
            
            // in the special case that we were disconnected on accident, reconnect immediately
            print(keepConnectionAlive)
            if ((keepConnectionAlive == true) && (name == connected_device_name)){
                print(connected_device_name)
                centralManager?.stopScan()
                centralManager?.connect(peripheral, options: nil)
            }
        }
        self.peripheralTimestamps[name] = time
        
    }

    //##### Triggered when discovering service
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            if(service.uuid.uuidString != SERVICE_UUID?[0].uuidString) {
                return
            }
            self.peripherals.append(peripheral)
            self.peripheralNames.append(peripheral.name!)
            print("discovered service \(String(describing: service))")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    
    }
    
    //##### Triggered when discovering characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        
        for characteristic in characteristics {
            // Assign characteristics for sending/receiving data
            if (characteristic.properties.rawValue == 0x8) {
                characteristicToSendControlsTo = characteristic
            } else if (characteristic.uuid.uuidString == ULTRASONIC_UUID) {
                ultrasonicCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            } else if (characteristic.uuid.uuidString == LONGITUDE_UUID) {
                longitudeCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            } else if (characteristic.uuid.uuidString == LATITUDE_UUID) {
                latitudeCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }   else if (characteristic.uuid.uuidString == HEADING_UUID) {
                headingCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    // Triggered when characteristic state updated
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("Updated notification state for \(String(describing: characteristic))")
    }
    
    // Triggered when Characteristic value is updated
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard characteristic.value != nil else {
            return
        }
        if (characteristic.uuid.uuidString == ULTRASONIC_UUID) {
            guard let newValue = characteristic.value else {
                return
            }
            let bytes :[UInt8] = [newValue[0], newValue[1]]
            let data = NSData(bytes: bytes, length: 2)
            var pulseWidth : UInt16 = 0; data.getBytes(&pulseWidth, length:2)
            ultrasonicDistance = Float32(pulseWidth) / 148
            //print("Pulse width: \(pulseWidth)")
        } else if (characteristic.uuid.uuidString == LATITUDE_UUID) {
            guard let newValue = characteristic.value else {
                return
            }
            let bytes :[UInt8] = [newValue[0], newValue[1], newValue[2], newValue[3]]
            let data = NSData(bytes: bytes, length: 4)
            data.getBytes(&latitude, length:4)
            print("New latitude value: \(latitude)")
        } else if (characteristic.uuid.uuidString == LONGITUDE_UUID) {
            guard let newValue = characteristic.value else {
                return
            }
            let bytes :[UInt8] = [newValue[0], newValue[1], newValue[2], newValue[3]]
            let data = NSData(bytes: bytes, length: 4)
            data.getBytes(&longitude, length:4)
            print("New longitude value: \(longitude)")
        } else if (characteristic.uuid.uuidString == HEADING_UUID) {
            guard let newValue = characteristic.value else {
                return
            }
            let bytes :[UInt8] = [newValue[0], newValue[1], newValue[2], newValue[3]]
            let data = NSData(bytes: bytes, length: 4)
            data.getBytes(&heading, length:4)
            //print("New heading value: \(heading)")
        }
    }
    
    // Writes a hex value to the connected device
    func writeHex(data: UInt8) {
        var intData = data
        let hexData = Data(bytes: &intData,
                           count: MemoryLayout.size(ofValue: intData))
        guard let writeCharacteristic = characteristicToSendControlsTo else {
            return
        }
        connected_device?.writeValue(hexData, for: writeCharacteristic, type: .withResponse)
    }

    
    //############################################### Statements to connect a peripheral
    func connectPeripheral(peripheral_name : String){
        // Set the connection type to keep alive
        keepConnectionAlive = true
        
        // Stop the scan and connect to the peripheral
        for peripheral in peripherals {
            if(peripheral_name == peripheral.name) {
                centralManager?.stopScan()
                centralManager?.connect(peripheral, options: nil)
                return
            }
        }
    }
    
    // Triggered after a connection
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //Store the name and the peripheral, have the manager keep the connection alive
        connected_device = peripheral
        connected_device_name = peripheral.name!
        peripherals = []
        peripheralNames = []
        peripheral.discoverServices(nil)
    }
    
    //############################################### Statements to disconnect a peripheral
    func disconnectPeripheral(){
        // set the connection keep alive status to false
        keepConnectionAlive = false
        // call the manager to disconnect
        centralManager?.cancelPeripheralConnection(connected_device!)
        return
    }

    //##### CALLED ON PERIPHERAL DISCONNECT
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)? ) {
        print("device disconnected")
        //Ensure there was a connected device
        guard let connected_peripheral = connected_device else {
            return
        }
        
        // If we want to keep the connection alive, immediately try to reconnect
        if keepConnectionAlive == true {
            print("unintentional disconnect")
            peripherals = []
            peripheralNames = []
            self.centralManager?.cancelPeripheralConnection(connected_peripheral)
            self.centralManager?.scanForPeripherals(withServices: SERVICE_UUID)
            
        // otherwise dont try to reconnect, just scan
        } else {
            print("intentional disconnect")
            connected_device_name = ""
            peripherals = []
            peripheralNames = []
            self.centralManager?.cancelPeripheralConnection(connected_peripheral)
            self.centralManager?.scanForPeripherals(withServices: SERVICE_UUID)
        }
    }
    
}
