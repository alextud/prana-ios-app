//
//  Prana.swift
//  prana-bluetooth
//
//  Created by Alexandru Tudose on 18.09.2020.
//

import Foundation
import CoreBluetooth

struct PranaUUID {
    static let characteristics = "CCCC"
    static let service = "CCCC"
}

enum PranaActions: String {
    case deviceStatus = "BEEF0501000000005A"
    case deviceDetals = "BEEF0502000000005A"
    
    case powerOff     = "BEEF0401"
    case luminosity   = "BEEF0402"
    // unknown
    // unknown
    case heater       = "BEEF0405"
    case nightMode    = "BEEF0406"
    case maxLevel     = "BEEF0407"
    // unknown
    case lockSpeed    = "BEEF0409"
    case powerOn      = "BEEF040A"
    case levelDown    = "BEEF040B"
    case levelUp      = "BEEF040C"
    case airInOn      = "BEEF040D"
    case levelInUp    = "BEEF040E"
    case levelInDown  = "BEEF040F"
    case airOutOn     = "BEEF0410"
    case levelOutUp   = "BEEF0411"
    case levelOutDown = "BEEF0412"
    // unknown ....
    case thaw         = "BEEF0416"
    case auto         = "BEEF0418"
    
    func send(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        let data = self.rawValue.data(using: .hexadecimal)!
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
}

struct PranaIndex {
    static let isOn = 10 // [0, 1
    static let nightMode = 16 // [0, 1]
    static let auto = 20 // [0, 1]
    static let isSpeedLocked = 22 // [0, 1]
    static let level = 26// x / 10
    static let levelIn = 30 // x / 10
    static let levelOut = 34 // x / 10
    static let airInOn = 28 // [0, 1]
    static let airOutOn = 32 // [0, 1]
    
    static let CO2 = (index: 62, mask: UInt16(0b0011_1111_1111_1111))
    static let VOC = (index: 64, mask: UInt16(0b0011_1111_1111_1111))
    
    static let thaw = 42
    static let heater = 14
    static let maxLevel = 111
    static let luminosity = 111
}

struct PranaPacket {
    let data: Data
    
    let level: UInt8
    let levelOut: UInt8
    let levelIn: UInt8
    let isOn: UInt8
    
    let voc: UInt16
    let co2: UInt16
    let auto: UInt8
    let isSpeedLocked: UInt8
    let isHeaterOn: UInt8
    let isThawOn: UInt8
    
    let airInOn: UInt8
    let airOutOn: UInt8
    
    var isWorking: Bool {
        return isOn == 1
    }
    
    
    init (data: Data) {
        guard data.count > 158 else {
            abort()
        }
        self.data = data
        
        level = data[PranaIndex.level] / 10
        levelOut = data[34] / 10
        levelIn = data[30] / 10
        isOn = data[PranaIndex.isOn]
        
        voc = UInt16(data: data.subdata(in: PranaIndex.VOC.index-1..<PranaIndex.VOC.index+1)).bigEndian & PranaIndex.VOC.mask
        co2 = UInt16(data: data.subdata(in: PranaIndex.CO2.index-1..<PranaIndex.CO2.index+1)).bigEndian & PranaIndex.CO2.mask
        auto = data[PranaIndex.auto]
        isSpeedLocked = data[PranaIndex.isSpeedLocked]
        isHeaterOn = data[PranaIndex.heater]
        isThawOn = data[PranaIndex.thaw]
        
        airInOn = data[PranaIndex.airInOn]
        airOutOn = data[PranaIndex.airOutOn]
    }
}


struct Prana {
    let peripheral: CBPeripheral
    var characteristic: CBCharacteristic? = nil
    var isWorking: Bool = false
    
    var name: String? {
        return peripheral.name
    }
    
    func send(action: PranaActions) {
        print("sending: \(action)")
        action.send(peripheral: peripheral, characteristic: characteristic!)
    }
    
    func deviceUpdate() {
        send(action: .deviceStatus)
    }
    
    func plusPowerAction() {
        send(action: .levelUp)
    }
    
    func minusPowerAction() {
        send(action: .levelDown)
    }
    
    func plusInAction() {
        send(action: .levelInUp)
    }
    
    func minusInAction() {
        send(action: .levelInDown)
    }
    
    func plusOutAction() {
        send(action: .levelOutUp)
    }
    
    func minusOutAction() {
        send(action: .levelOutDown)
    }
    
    func autoAction() {
        send(action: .auto)
    }
    
    func powerAction() {
        send(action: isWorking ? .powerOff : .powerOn)
    }
    
    func heaterAction() {
        send(action: .heater)
    }
    
    func thawAction() {
        send(action: .thaw)
    }
    
    func toogleSpeedIn() {
        send(action: .airInOn)
    }
    
    func toogleSpeedOut() {
        send(action: .airOutOn)
    }
}

