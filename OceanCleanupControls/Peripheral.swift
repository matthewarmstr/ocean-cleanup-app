//
//  Peripheral.swift
//  SubROVControls
//
//  Created by William Fitzgerald on 4/23/24.
//

import SwiftUI
import CoreBluetooth
import CoreLocation


//Button code declarations

struct Peripheral: View {
    @State private var isFeet = false
    @Environment(\.presentationMode) var presentationMode
    var peripheralName: String
    var bluetoothModel: BluetoothModel
    @StateObject var locationManager = LocationManager()
    
    // Declarations to allow for message sends on button presses
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
    
    func getUltrasonicDistance() -> String {
        let ultrasonic_distance = bluetoothModel.ultrasonicDistance
        if (isFeet == true) {
            return String(format: "%.2f",(ultrasonic_distance * 0.393701)) + " in."
        } else {
            return String(format: "%.2f", ultrasonic_distance) + " cm."
        }
    }

    func getGPSDistance() -> String {
        let peripheralLatitude = bluetoothModel.latitude
        let peripheralLongitude = bluetoothModel.longitude
        let peripheralLocation : CLLocation =  CLLocation(latitude: Double(peripheralLatitude), longitude: Double(peripheralLongitude))
        let phoneLocation = locationManager.lastLocation

        let distance = phoneLocation?.distance(from: peripheralLocation)
        let distanceMeters = distance ?? 0.0
        print("GPS distance: \(distanceMeters)")
        
        if (isFeet == false) {
            return String(format: "%.2f",(distanceMeters)) + " meters"
        } else {
            return String(format: "%.2f", distanceMeters * 3.281) + " feet"
        }
    }
    
    func get_header_angle() -> Double {
        let peripheral_latitude = Double(bluetoothModel.latitude)
        let peripheral_longitude = Double(bluetoothModel.longitude)
        let phone_location = locationManager.lastLocation
        let phone_latitude = phone_location?.coordinate.latitude ?? 0
        let phone_longitude = phone_location?.coordinate.longitude ?? 0
        print("boat: \(peripheral_latitude), \(peripheral_longitude)")
        print("phone: \(phone_latitude), \(phone_longitude)")
        let final_degrees = atan2((peripheral_latitude - phone_latitude), (peripheral_longitude - phone_longitude))
        return -((final_degrees * 180) / Double.pi + 90)
    }
    
    func updateAndSendNewControls(bit: UInt8) -> Void {
        controlBits = controlBits ^ bit
        bluetoothModel.writeHex(data: controlBits)
    }
    
    func returnFromPeriphal(){
        self.presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        //changeOrientation(to: .landscapeLeft)
        ZStack{
            // OVERALL BACKGROUND COLORS
            LinearGradient(colors: [Color.orange, Color.cyan],startPoint: .topLeading, endPoint: .bottomTrailing).edgesIgnoringSafeArea(.all)
            
             //RETURN BUTTON
            Button {
                print("Action to return here")
                returnFromPeriphal()
            } label: {
                Text("Return").foregroundColor(.black).font(.title).frame(width: 100, height: 50)
            }.buttonStyle(.borderedProminent).buttonBorderShape(.capsule).tint(Color(red: 98/255, green: 200/255, blue: 152/255)).padding([.trailing], 80).rotationEffect(.degrees(90)).position(x:320, y:100)
            
            //FORWARD BUTTON
            Button {
                print("Forward")
            } label: {
                Text("Forward").foregroundColor(.black).font(.title).frame(width: 240, height: 240) }.buttonStyle(.borderedProminent).buttonBorderShape(.capsule).tint(Color(red: 98/255, green: 200/255, blue: 152/255)).gesture(longPress).onLongPressGesture(minimumDuration: 0.5, maximumDistance: 2.0) { updateAndSendNewControls(bit: FORWARD_BINARY) } onPressingChanged: { Bool in updateAndSendNewControls(bit: FORWARD_BINARY)
                }.rotationEffect(.degrees(90)).position(x:170, y:180)

            // RIGHT BUTTON
            Button {
                print("Action to move right here")
            } label: {
                Image(systemName: "arrowshape.right.fill").foregroundColor(.black).font(.title).frame(width: 90, height: 90) }.buttonStyle(.borderedProminent).buttonBorderShape(.roundedRectangle).tint(Color(red: 98/255, green: 200/255, blue: 152/255)).gesture(longPress).onLongPressGesture(minimumDuration: 0.5, maximumDistance: 2.0) { updateAndSendNewControls(bit: RIGHT_BINARY) } onPressingChanged: { Bool in updateAndSendNewControls(bit: RIGHT_BINARY) }.rotationEffect(.degrees(90)).position(x:100, y:690)
            // LEFT BUTTON
            Button {
                print("Action to move left here")
            } label: {
                Image(systemName: "arrowshape.left.fill").foregroundColor(.black).font(.title).frame(width: 90, height: 90) }.buttonStyle(.borderedProminent).buttonBorderShape(.roundedRectangle).tint(Color(red: 98/255, green: 200/255, blue: 152/255)).gesture(longPress).onLongPressGesture(minimumDuration: 0.5, maximumDistance: 2.0) { updateAndSendNewControls(bit: LEFT_BINARY) } onPressingChanged: { Bool in updateAndSendNewControls(bit: LEFT_BINARY) }.rotationEffect(.degrees(90)).position(x:100, y:560)
            
            //TRASH BUTTON
            Button {
                print("Action to open trash door")
            } label: {
                Image(systemName: "trash.circle.fill") .foregroundColor(.black).font(.title).frame(width: 90, height: 90) }.buttonStyle(.borderedProminent).buttonBorderShape(.roundedRectangle).tint(Color(red: 98/255, green: 200/255, blue: 152/255)).gesture(longPress).onLongPressGesture(minimumDuration: 0.5, maximumDistance: 2.0) { updateAndSendNewControls(bit: TRASH_BINARY) } onPressingChanged: { Bool in updateAndSendNewControls(bit: TRASH_BINARY) }.rotationEffect(.degrees(90)).position(x:100, y:430)

            //Toggle Switch
            Toggle("", isOn: $isFeet).buttonStyle(.borderedProminent).toggleStyle(.switch).frame(width: 300, height:300).tint(.gray).rotationEffect(.degrees(90)).position(x:350, y:436)
            Text("metric").rotationEffect(.degrees(90)).position(x:350, y:500).font(.system(size: 24))
            Text("imperial").rotationEffect(.degrees(90)).position(x:350, y:630).font(.system(size: 24))
            //DATA VALUES
            RoundedRectangle(cornerRadius: 20).fill(Color(hue: Double(min(bluetoothModel.ultrasonicDistance/(450),0.3)), saturation: 1, brightness: 1)).frame(width: 180, height: 150).rotationEffect(.degrees(90)).position(x:250, y:465)
            Text("Object ahead in:").rotationEffect(.degrees(90)).position(x:300, y:465).font(.system(size: 24))
            Text(getUltrasonicDistance()).rotationEffect(.degrees(90)).position(x:240, y:465).font(.system(size: 24)).foregroundStyle(.white)
            RoundedRectangle(cornerRadius: 20).fill(.gray ).frame(width: 180, height: 150).rotationEffect(.degrees(90)).position(x:250, y:660)
            Text("Distance Away:").rotationEffect(.degrees(90)).position(x:300, y:660).font(.system(size: 24))
            Text(getGPSDistance()).rotationEffect(.degrees(90)).position(x:240, y:660).font(.system(size: 24)).foregroundStyle(.white)
            
            
            //Heading Compas
            Image(.simpleCompassRose).resizable().frame(width: 100, height: 100).rotationEffect(.degrees(90)).position(x:320, y:310)
            Image(.arrow).resizable().frame(width: 70, height: 25).rotationEffect(.degrees(get_header_angle())).position(x:320, y:311)
        }.onAppear {
            timer.upstream.connect().cancel()
            bluetoothModel.ultrasonicDistance = 0.0
            
            bluetoothModel.connectPeripheral(peripheral_name: peripheralName)
        }.onDisappear {
            timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            bluetoothModel.disconnectPeripheral()
        }
    }
}

#Preview {
    ContentView()
}
