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
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
                        var last_timestamp = timestamp
                        var current_timestamp = Date()
                        last_timestamp = last_timestamp.addingTimeInterval(2)
                        
                        if (last_timestamp < current_timestamp) {
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
