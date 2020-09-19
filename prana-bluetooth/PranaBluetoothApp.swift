//
//  PranaBluetoothApp.swift
//  prana-bluetooth
//
//  Created by Alexandru Tudose on 18.09.2020.
//

import SwiftUI

@main
struct PranaBluetoothApp: App {
    @ObservedObject var bluetooth = BluetoothController()
    
    var body: some Scene {
        WindowGroup {
            VStack {
                Spacer().frame(height: 20)
                HStack(spacing: 20) {
                    Button("POWER") { bluetooth.prana?.powerAction() }
                    Button("AUTO") { bluetooth.prana?.autoAction() }
                    Button("HEATER") { bluetooth.prana?.heaterAction() }
                    Button("THAW") { bluetooth.prana?.thawAction() }
                }
                Spacer().frame(height: 30)
                HStack(spacing: 20) {
                    Button("IN to 0") { bluetooth.prana?.toogleSpeedIn() }
                    Button("OUT to 0") { bluetooth.prana?.toogleSpeedIn() }
                }
                Spacer().frame(height: 30)
                HStack(spacing: 20) {
                    Button("+") { bluetooth.prana?.plusPowerAction() }
                    Text("LEVEL - \(bluetooth.pranaPacket?.level ?? 0)").padding([.leading, .trailing], 20)
                    Button("-") { bluetooth.prana?.minusPowerAction() }
                }
                Spacer().frame(height: 30)
                HStack(spacing: 20) {
                    Button("+") { bluetooth.prana?.plusInAction() }
                    Text("Level IN - \(bluetooth.pranaPacket?.levelIn ?? 0)").padding([.leading, .trailing], 20)
                    Button("-") { bluetooth.prana?.minusInAction() }
                }
                VStack {
                    Spacer().frame(height: 30)
                    HStack(spacing: 20) {
                        Button("+") { bluetooth.prana?.plusOutAction() }
                        Text("Level OUT -  \(bluetooth.pranaPacket?.levelOut ?? 0)").padding([.leading, .trailing], 20)
                        Button("-") { bluetooth.prana?.minusOutAction() }
                    }
                    Spacer(minLength: 20)
                    HStack() {
                        Text(description()).padding(.leading, 20)
                        Spacer()
                    }
                    Spacer(minLength: 20)
                }

            }
        }
    }
    
    func description() -> String {
        return
            """
             Power: \(bluetooth.pranaPacket?.isOn == 1 ? "ON" : "OFF")
             VOC: \(bluetooth.pranaPacket?.voc ??  0)
             CO2: \(bluetooth.pranaPacket?.co2 ??  0)
             AUTO: \(bluetooth.pranaPacket?.auto ??  0)
             Is Speed Locked: \(bluetooth.pranaPacket?.isSpeedLocked ??  0)
             Is heater on: \(bluetooth.pranaPacket?.isHeaterOn ??  0)
             Is thaw on: \(bluetooth.pranaPacket?.isThawOn ??  0)
             Air in on: \(bluetooth.pranaPacket?.airInOn ??  0)
             Air out on: \(bluetooth.pranaPacket?.airOutOn ??  0)
             """
    }
}
