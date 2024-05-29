//
//  ContentView.swift
//  OceanCleanupControls
//
//  Created by Matthew Armstrong on 2/23/24.
//

import SwiftUI
import UIKit
var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
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
                }.onReceive(timer) { time in
                    for (name, timestamp) in bluetoothModel.peripheralTimestamps {
                        var peripheral_timestamp = timestamp
                        let current_timestamp = Date()
                        peripheral_timestamp = peripheral_timestamp.addingTimeInterval(2)
                        print("Current Timestamp:")
                        print(current_timestamp)
                        print("peripheral_timestamp:")
                        print(peripheral_timestamp)
                        
                        if (peripheral_timestamp < current_timestamp) {
                            bluetoothModel.peripheralNames = bluetoothModel.peripheralNames.filter { $0 != name }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView().previewInterfaceOrientation(.landscapeLeft)
}
