//
//  ContentView.swift
//  SubROVControls
//
//  Created by Matthew Armstrong on 2/23/24.
//

import SwiftUI
import CoreBluetooth

let UUIDdevice = UUID(uuidString:"A6DCBC6F-0021-6BO9-10C1-BDA4S6CV8N68")

class BluetoothModel: NSObject, ObservableObject {
    private var centralManager: CBCentralManager?
    private var connected_device: CBPeripheral?
    private var peripherals: [CBPeripheral] = []
    private var characteristicToWriteTo: CBCharacteristic?
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
        }
        characteristicToWriteTo = characteristics[0];
    }
    
    func writeHex(data: Int) {
        var intData = data
        let hexData = Data(bytes: &intData,
                           count: MemoryLayout.size(ofValue: intData))
        guard let writeCharacteristic = characteristicToWriteTo else {
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
            LinearGradient(colors: [.black, .black],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)       
                                        .edgesIgnoringSafeArea(.all)
            VStack {
                // Forward Button
                Button {
                    print("Action to move forward here")
                    bluetoothModel.writeHex(data: 1)
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
                .gesture(longPress)
                .onLongPressGesture(minimumDuration: 0.5,
                                    maximumDistance: 2.0) {
                    action1()
                } onPressingChanged: { Bool in
                    action1()
                }
                
                HStack {
                    VStack {
                        // Left button
                        Button {
                            print("Action to move left here")
                            bluetoothModel.writeHex(data: 2)
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
                        .gesture(longPress)
                        .onLongPressGesture(minimumDuration: 0.1,
                                            maximumDistance: 0.1) {
                            action1()
                        } onPressingChanged: { Bool in
                            action1()
                        }

                        // Right button
                        Button {
                            print("Action to move right here")
                            bluetoothModel.writeHex(data: 3)
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
                        .gesture(longPress)
                        .onLongPressGesture(minimumDuration: 0.1,
                                            maximumDistance: 2.0) {
                            action1()
                        } onPressingChanged: { Bool in
                            action1()
                        }

                    }
                    .padding([.top], 50)

                    // Trash Collector Button
                    Button {
                        print("Activate Trash Collector")
                        bluetoothModel.writeHex(data: 4)
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

func action1() -> Void{
    print("hi")
}

#Preview {
    ContentView()
}
