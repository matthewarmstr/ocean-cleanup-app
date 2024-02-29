//
//  ContentView.swift
//  SubROVControls
//
//  Created by Matthew Armstrong on 2/23/24.
//
// https://youtu.be/n-f0BwxKSD0
// https://medium.com/@bhumitapanara/ble-bluetooth-low-energy-with-ios-swift-7ef0de0dff78

import SwiftUI
import CoreBluetooth

let UUIDdevice = UUID(uuidString:"A6DCBC6F-0021-6BO9-10C1-BDA4S6CV8N68")

class BluetoothModel: NSObject, ObservableObject {
    private var centralManager: CBCentralManager?
    private var connected_device: CBPeripheral?
    private var peripherals: [CBPeripheral] = []
    @Published var peripheralNames: [String] = []
    
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
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard peripheral.services != nil else {
            return
        }
        print("discovered services for \(String(describing: peripheral.name))")
        processServices()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsForService error: Error?) {
        // TO DO
    }
    
//    func processServices() {
//        if let services = connected_device?.services {
//            for service in services {
//                connected_device?.discoverCharacteristics(nil, for: service)
//                print("Service: Discover service \(service)")
//                print("Service: UUID \(service)")
//                
//                if let characts = service.characteristics {
//                    for charact in characts {
//                        let cb_chara: CBCharacteristic = charact as CBCharacteristic
//                        print("Char service \(service.uuid) Discover char \(cb_chara)")
//                        print("Char: UUID \(cb_chara.uuid)")
//                    }
//                }
//            }
//        }
//    }
    
//    func writeValToConnectedDevice(data: Int) {
//        var intvalue:Int = data
//        var intdata = Data(bytes: &intvalue,
//                          count: MemoryLayout.size(ofValue: intvalue))
//        //connected_device.writeValue(intdata, for: CBCharacteristic, type: .withoutResponse)
//    }
}
    // writeValToConnectedDevice(data: THEVALUE )

















struct ContentView: View {
    @ObservedObject private var bluetoothModel = BluetoothModel()
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .black],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)       .edgesIgnoringSafeArea(.all)
            VStack {
                // Forward Button
                Button {
                    print("Action to move forward here")
//                    bluetoothModel.writeValToConnectedDevice(data: 1)
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
                .padding([.bottom, .trailing, .top], 50)
                .rotationEffect(.degrees(90))
                
                HStack {
                    VStack {
                        // Left button
                        Button {
                            print("Action to move left here")
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
                        .tint(Color(red: 237/255, green: 51/255, blue: 78/255))
                        .rotationEffect(.degrees(90))

                        // Right button
                        Button {
                            print("Action to move right here")
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
                        .tint(Color(red: 237/255, green: 51/255, blue: 78/255))
                        .rotationEffect(.degrees(90))

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
                }
                // Display Bluetooth devices
//                List(bluetoothViewModel.peripheralNames, id: \.self) { peripheral in
//                    Text(peripheral)
//                }
//                .navigationTitle("Peripherals")
            }

        }
    }
    
}

#Preview {
    ContentView()
}
