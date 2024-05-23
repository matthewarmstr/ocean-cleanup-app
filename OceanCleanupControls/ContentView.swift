//
//  ContentView.swift
//  OceanCleanupControls
//
//  Created by Matthew Armstrong on 2/23/24.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @ObservedObject private var bluetoothModel = BluetoothModel()

    var body: some View {
        NavigationStack {
            Text("Select a peripheral")
                .font(.system(size: 24, weight: .light, design: .serif))
            List(bluetoothModel.peripheralNames, id: \.self) { peripheral in
                NavigationLink {
                    Peripheral(peripheralName: peripheral, bluetoothModel: bluetoothModel)
                        .navigationBarBackButtonHidden(true)
                } label: {
                    Text(peripheral)
                        .font(.system(size: 18, weight: .light, design: .serif))
                }
            }
        }
    }
}

#Preview {
    ContentView().previewInterfaceOrientation(.landscapeLeft)
}




//class BluetoothModel: NSObject, ObservableObject {
//    private var centralManager: CBCentralManager?
//    private var connected_device: CBPeripheral?
//    private var peripherals: [CBPeripheral] = []
//    private var characteristicToSendControlsTo: CBCharacteristic?
    
    //@Published var peripheralNames: [String] = []
    
//    private var ultrasonicCharacteristic: CBCharacteristic?
//    @Published var ultrasonicDistance: Float32 = 0
//    private var longitudeCharacteristic: CBCharacteristic?
//    @Published var longitude: Float32 = 0
//    private var latitudeCharacteristic: CBCharacteristic?
//    @Published var latitude: Float32 = 0
    
    
//    override init() {
//        super.init()
//        self.centralManager = CBCentralManager(delegate: self, queue: .main)
//    }
//}

//extension BluetoothModel: CBCentralManagerDelegate, CBPeripheralDelegate {
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == .poweredOn {
//            self.centralManager?.scanForPeripherals(withServices: nil)
//        }
//    }
    
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        peripheral.delegate = self
//        if !peripherals.contains(peripheral) {
//            self.peripherals.append(peripheral)
//            self.peripheralNames.append(peripheral.name ?? "unnamed device")
//        }
//
//        // Automatically connect with PSoC
//        if peripheral.name == "SubROV" {
//            centralManager?.stopScan()
//            centralManager?.connect(peripheral, options: nil)
//        }
//    }
    
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        // Successfully connected. Store reference to peripheral if not already done.
//        print("Connected to SubROV \(String(describing: peripheral.name))")
//        connected_device = peripheral
//        peripheral.discoverServices(nil)
//    }
    
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)? ) {
//        print("device disconnected")
//        guard let connected_peripheral = connected_device else {
//            return
//        }
//        self.centralManager?.cancelPeripheralConnection(connected_peripheral)
//        self.centralManager?.scanForPeripherals(withServices: nil)
//    }
    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        guard let services = peripheral.services else {
//            return
//        }
//        for service in services {
//            print("discovered service \(String(describing: service))")
//            peripheral.discoverCharacteristics(nil, for: service)
//        }
//
//    }
    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        guard let characteristics = service.characteristics else {
//            return
//        }
//
//        for characteristic in characteristics {
//            print("discovered characteristic \(String(describing: characteristic))")
//
//            // Assign characteristics for sending/receiving data
//            if (characteristic.properties.rawValue == 0x8) {
//                characteristicToSendControlsTo = characteristic
//                print("ASSIGNED WRITE CHARACTERISTIC")
//            } else if (characteristic.uuid.uuidString == ULTRASONIC_UUID) {
//                ultrasonicCharacteristic = characteristic
//                peripheral.setNotifyValue(true, for: characteristic)
//                peripheral.setNotifyValue(true, for: characteristic)
//            } else if (characteristic.uuid.uuidString == LONGITUDE_UUID) {
//                longitudeCharacteristic = characteristic
//                peripheral.setNotifyValue(true, for: characteristic)
//            } else if (characteristic.uuid.uuidString == LATITUDE_UUID) {
//                latitudeCharacteristic = characteristic
//                peripheral.setNotifyValue(true, for: characteristic)
//            }
//        }
//    }
    
//    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
//        print("Updated notification state for \(String(describing: characteristic))")
//    }
    
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        guard characteristic.value != nil else {
//            return
//        }
//        if (characteristic.uuid.uuidString == ULTRASONIC_UUID) {
//            guard let newValue = characteristic.value else {
//                return
//            }
//            let bytes :[UInt8] = [newValue[0], newValue[1]]
//            let data = NSData(bytes: bytes, length: 2)
//            var pulseWidth : UInt16 = 0; data.getBytes(&pulseWidth, length:2)
//            ultrasonicDistance = Float32(pulseWidth) / 148
//            print("Pulse width: \(pulseWidth)")
//        } else if (characteristic.uuid.uuidString == LATITUDE_UUID) {
//            guard let newValue = characteristic.value else {
//                return
//            }
//            let bytes :[UInt8] = [newValue[0], newValue[1], newValue[2], newValue[3]]
//            let data = NSData(bytes: bytes, length: 4)
//            data.getBytes(&latitude, length:4)
//            print("New latitude value: \(latitude)")
//        } else if (characteristic.uuid.uuidString == LONGITUDE_UUID) {
//            guard let newValue = characteristic.value else {
//                return
//            }
//            let bytes :[UInt8] = [newValue[0], newValue[1], newValue[2], newValue[3]]
//            let data = NSData(bytes: bytes, length: 4)
//            data.getBytes(&longitude, length:4)
//            print("New longitude value: \(longitude)")
//        }
//    }
    
//    func writeHex(data: UInt8) {
//        var intData = data
//        let hexData = Data(bytes: &intData,
//                           count: MemoryLayout.size(ofValue: intData))
//        guard let writeCharacteristic = characteristicToSendControlsTo else {
//            return
//        }
//        connected_device?.writeValue(hexData, for: writeCharacteristic, type: .withResponse)
//    }
//}
