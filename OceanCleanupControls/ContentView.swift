//
//  ContentView.swift
//  OceanCleanupControls
//
//  Created by Matthew Armstrong on 2/23/24.
//

import SwiftUI
import UIKit
import CoreBluetooth

var controlBits: UInt8 = 0

let LEFT_BINARY: UInt8 = 0b00000001
let RIGHT_BINARY: UInt8 = 0b00000010
let TRASH_BINARY: UInt8 = 0b00000100
let FORWARD_BINARY: UInt8 = 0b00001000
let REVERSE_BINARY: UInt8 = 0b00010000

let ULTRASONIC_UUID: String = "48081061-A096-451D-983F-BABFABA3E394"
let LATITUDE_UUID: String = "5B7F4D5B-63AD-42EB-8074-FA3550CC44F8"
let LONGITUDE_UUID: String = "B36AC37E-2DC5-4B2D-8080-C9BBE38A54C1"

class BluetoothModel: NSObject, ObservableObject {
    private var centralManager: CBCentralManager?
    private var connected_device: CBPeripheral?
    private var peripherals: [CBPeripheral] = []
    private var characteristicToSendControlsTo: CBCharacteristic?
    
    @Published var peripheralNames: [String] = []
    
    private var ultrasonicCharacteristic: CBCharacteristic?
    @Published var ultrasonicDistance: Float32 = 0
    private var longitudeCharacteristic: CBCharacteristic?
    @Published var longitude: Float32 = 0
    private var latitudeCharacteristic: CBCharacteristic?
    @Published var latitude: Float32 = 0
    
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
}

extension BluetoothModel: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.centralManager?.scanForPeripherals(withServices: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripheral.delegate = self
        if !peripherals.contains(peripheral) {
            self.peripherals.append(peripheral)
            self.peripheralNames.append(peripheral.name ?? "unnamed device")
        }
        
        // Automatically connect with PSoC
        if peripheral.name == "SubROV" {
            centralManager?.stopScan()
            centralManager?.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Successfully connected. Store reference to peripheral if not already done.
        print("Connected to SubROV \(String(describing: peripheral.name))")
        connected_device = peripheral
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)? ) {
        print("device disconnected")
        guard let connected_peripheral = connected_device else {
            return
        }
        self.centralManager?.cancelPeripheralConnection(connected_peripheral)
        self.centralManager?.scanForPeripherals(withServices: nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            print("discovered service \(String(describing: service))")
            peripheral.discoverCharacteristics(nil, for: service)
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        
        for characteristic in characteristics {
            print("discovered characteristic \(String(describing: characteristic))")
            
            // Assign characteristics for sending/receiving data
            if (characteristic.properties.rawValue == 0x8) {
                characteristicToSendControlsTo = characteristic
                print("ASSIGNED WRITE CHARACTERISTIC")
            } else if (characteristic.uuid.uuidString == ULTRASONIC_UUID) {
                ultrasonicCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.setNotifyValue(true, for: characteristic)
            } else if (characteristic.uuid.uuidString == LONGITUDE_UUID) {
                longitudeCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            } else if (characteristic.uuid.uuidString == LATITUDE_UUID) {
                latitudeCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("Updated notification state for \(String(describing: characteristic))")
    }
    
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
            print("Pulse width: \(pulseWidth)")
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
        }
    }
    
    func writeHex(data: UInt8) {
        var intData = data
        let hexData = Data(bytes: &intData,
                           count: MemoryLayout.size(ofValue: intData))
        guard let writeCharacteristic = characteristicToSendControlsTo else {
            return
        }
        connected_device?.writeValue(hexData, for: writeCharacteristic, type: .withResponse)
    }
}



struct ContentView: View {
    @ObservedObject private var bluetoothModel = BluetoothModel()
    @GestureState private var isDetectingLongPress = false
    @State private var completedLongPress = false
    

    var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .updating($isDetectingLongPress) { currentState, gestureState,
                transaction in gestureState = currentState
                transaction.animation = Animation.easeIn(duration: 0.5)
            }
            .onEnded {
                finished in self.completedLongPress = finished
            }
    }
    
    var body: some View {
        
        ZStack {
            LinearGradient(colors: [Color.black],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)       
                                        .edgesIgnoringSafeArea(.all)
            VStack {
                // Forward Button
                VStack{
                    HStack {
                        Text("Ultrasonic distance: \(bluetoothModel.ultrasonicDistance, specifier: "%.2f") in.").foregroundColor(.white)
                    }
                    HStack {
                        Text("Latitude:  \(bluetoothModel.latitude, specifier: "%.5f")").foregroundColor(.white)
                    }
                    HStack {
                        Text("Longitude: \(bluetoothModel.longitude, specifier: "%.5f")").foregroundColor(.white)
                    }
                }
                
                Button {
                    print("Action to move forward here")
                } label: {
                    Text("FORWARD")
                        .foregroundColor(.black)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        .frame(width: 200, height: 200)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        .font(.title)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .buttonBorderShape(.capsule)
                .tint(Color(red: 98/255, green: 255/255, blue: 152/255))
//                .padding([.bottom, .trailing, .top], -15)
                .rotationEffect(.degrees(90))
                .gesture(longPress)
                .onLongPressGesture(minimumDuration: 0.5,
                                    maximumDistance: 2.0) {
                    updateAndSendNewControls(bit: FORWARD_BINARY)
                } onPressingChanged: { Bool in
                    updateAndSendNewControls(bit: FORWARD_BINARY)
                }
                
                HStack {
                    VStack {
                        // Left button
                        Button {
                            print("Rudder turn left")
                        } label: {
                            Image(systemName: "arrowshape.left.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.black)
                                .frame(width: 75, height: 75)
                                .clipShape(Rectangle())
                        }
                        .controlSize(.large)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle)
                        .padding(.trailing, 100)
                        .tint(Color(red: 150/255, green: 150/255, blue: 230/255))
                        .rotationEffect(.degrees(90))
                        .gesture(longPress)
                        .onLongPressGesture(minimumDuration: 0.1,
                                            maximumDistance: 0.1) {
                            updateAndSendNewControls(bit: LEFT_BINARY)
                        } onPressingChanged: { Bool in
                            updateAndSendNewControls(bit: LEFT_BINARY)
                        }
                        // Right button
                        Button {
                            print("Rudder turn right")
                        } label: {
                            Image(systemName: "arrowshape.right.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.black)
                                .frame(width: 75, height: 75)
                                .clipShape(Rectangle())
                        }
                        .controlSize(.large)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle)
                        .tint(Color(red: 150/255, green: 150/255, blue: 230/255))
                        .rotationEffect(.degrees(90))
                        .gesture(longPress)
                        .onLongPressGesture(minimumDuration: 0.1,
                                            maximumDistance: 2.0) {
                            updateAndSendNewControls(bit: RIGHT_BINARY)
                        } onPressingChanged: { Bool in
                            updateAndSendNewControls(bit: RIGHT_BINARY)
                        }

                    }
                    .padding([.top], 50)

                    // Trash Collector Button
                    Button {
                        print("Activate Trash Collector")
                    } label: {
                        Image(systemName: "trash.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle)
                    .padding([.top], 75)
                    .tint(Color(red: 92/255, green: 189/255, blue: 235/255))
                    .rotationEffect(.degrees(90))
                    .gesture(longPress)
                    .onLongPressGesture(minimumDuration: 0) {
                    } onPressingChanged: { PressDown in
                        if PressDown {
                            updateAndSendNewControls(bit: TRASH_BINARY)
                            controlBits = controlBits ^ TRASH_BINARY
                        }
                    }
                }
            }
        }
    }
    func updateAndSendNewControls(bit: UInt8) -> Void {
        controlBits = controlBits ^ bit
        bluetoothModel.writeHex(data: controlBits)
    }
}

#Preview {
    ContentView().previewInterfaceOrientation(.landscapeLeft)
}
