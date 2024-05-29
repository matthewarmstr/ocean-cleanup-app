//
//  ContentView.swift
//  OceanCleanupControls
//
//  Created by Wsfitzge on 4/18/24.
//

import SwiftUI


struct ContentView: View {
    @ObservedObject var BluetoothModel : BluetoothModelDummy = BluetoothModelDummy()

    
    var body: some View {
        NavigationStack {
            Text("Select a peripheral")
                .font(.system(size: 24, weight: .light, design: .serif))
            List(BluetoothModel.peripheralNameList, id: \.self) { peripheral in
                NavigationLink {
                    Peripheral(peripheralName: peripheral, bluetoothModel: BluetoothModel)
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
    ContentView()
}

//import CoreBluetooth
//
//class BluetoothModel: NSObject, ObservableObject {
//    private var count: Int = 0
//    private var centralManager: CBCentralManager?
//    private var connected_device: CBPeripheral?
//    @Published var peripherals: [CBPeripheral] = []
//    private var characteristicToWriteTo: CBCharacteristic?
//    @Published var peripheralNames: [String] = []
//    
//    override init() {
//        super.init()
//        self.centralManager = CBCentralManager(delegate: self, queue: .main)
//    }
//}
//
//extension BluetoothModel: CBCentralManagerDelegate, CBPeripheralDelegate {
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == .poweredOn {
//            self.centralManager?.scanForPeripherals(withServices: nil)
//        }
//    }
//    
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        peripheral.delegate = self
//        if !peripherals.contains(peripheral) {
//            self.peripherals.append(peripheral)
//            guard let name = peripheral.name else {
//                return
//            }
//            self.peripheralNames.append(name)
//        }
//        count = count + 1
//        self.peripheralNames.append(String(count))
//        if (count > 20) {
//            count = 0
//            peripheralNames = []
////            self.centralManager?.scanForPeripherals(withServices: nil)
//            //centralManager?.stopScan()
//        }
//        // Automatically connect with PSoC
////        if peripheral.name == selectedPeripheral {
////            centralManager?.stopScan()
////            centralManager?.connect(peripheral, options: nil)
////        }
//    }
//    
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        // Successfully connected. Store reference to peripheral if not already done.
//        print("Connected to device \(String(describing: peripheral.name))")
//        connected_device = peripheral
//        peripheral.discoverServices(nil)
//    }
//    
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)? ) {
//        print("device disconnected")
//        guard let connected_peripheral = connected_device else {
//            return
//        }
//        self.centralManager?.cancelPeripheralConnection(connected_peripheral)
//        self.centralManager?.scanForPeripherals(withServices: nil)
//    }
//    
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
//    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        guard let characteristics = service.characteristics else {
//            return
//        }
//        for characteristic in characteristics {
//            print("discovered characteristic \(String(describing: characteristic))")
//        }
//        characteristicToWriteTo = characteristics[0];
//    }
//    
//    func writeHex(data: UInt8) {
//        var intData = data
//        let hexData = Data(bytes: &intData,
//                           count: MemoryLayout.size(ofValue: intData))
//        guard let writeCharacteristic = characteristicToWriteTo else {
//            return
//        }
//        connected_device?.writeValue(hexData, for: writeCharacteristic, type: .withResponse)
//    }
//    
//    func connectToPeripheral(selectedDevice: String) {
//        for peripheral in peripherals {
//            if peripheral.name == selectedDevice {
//                centralManager?.stopScan()
//                centralManager?.connect(peripheral, options: nil)
//            }
//        }
//    }
//}
//
//struct ContentView: View {
//    @ObservedObject var btModel : BluetoothModel = BluetoothModel()
//    
//    init() {
//        // Print the first peripheral name when the view is initialized
//        if let firstPeripheralName = btModel.peripheralNames.first {
//            print(firstPeripheralName)
//        }
//    }
//
//    var body: some View {
//        NavigationStack {
//            Text("Select a peripheral")
//                .font(.system(size: 24, weight: .light, design: .serif))
//            List(btModel.peripheralNames, id: \.self) { peripheral in
//                NavigationLink {
//                    Peripheral(peripheralName: peripheral, bluetoothModel: btModel)
//                        .navigationBarBackButtonHidden(true)
//                } label: {
//                    Text(peripheral)
//                        .font(.system(size: 18, weight: .light, design: .serif))
//                }
//            }
//        }
//    }
//}
//#Preview {
//    ContentView()
//}
