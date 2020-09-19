//
//  BluetoothController.swift
//  prana-bluetooth
//
//  Created by Alexandru Tudose on 18.09.2020.
//

import Foundation
import CoreBluetooth

class BluetoothController: NSObject, ObservableObject {
    
    @Published var prana: Prana?
    @Published var pranaPacket: PranaPacket?
    var previousPacket: PranaPacket?
    
    var bluetootManager:CBCentralManager!
    var updateTimer: Timer?
    let updateInterval: TimeInterval = 5 // seconds
    var isLoading = false
    
    override init() {
        super.init()
        
        isLoading = true
        bluetootManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BluetoothController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state change:", central.state.rawValue)
        if [.unauthorized, .unsupported, .poweredOff].contains(central.state) {
            print("could not start")
        }
        
        if central.state == .poweredOn {
            bluetootManager.scanForPeripherals(withServices: nil, options: .none)
        } else {
            isLoading = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("discover: ", peripheral.name ?? "", "data:", advertisementData, "rssi:", RSSI)

        
        if peripheral.name?.hasPrefix("PRANA RECUPERATOR") == true {
            prana = Prana(peripheral: peripheral)
            bluetootManager.stopScan()
        }
        
        peripheral.delegate = self
        bluetootManager.connect(peripheral, options: .none)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected")
        peripheral.discoverServices(nil)
    }
}


extension BluetoothController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print(#function)
        
        for service in peripheral.services ?? [] {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics ?? [] {
            print(characteristic)
            
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify ... subscribing")
                peripheral.setNotifyValue(true, for: characteristic)
                
                prana?.characteristic = characteristic
            }
         }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print(#function)
        for descriptor in characteristic.descriptors ?? [] {
            print(descriptor)
            peripheral.readValue(for: descriptor)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print(#function)
        switch characteristic.uuid {
            case CBUUID(string: PranaUUID.characteristics):
                print("notifying: ", characteristic.isNotifying, "data: ", characteristic.value ?? "null")

                updateTimer?.invalidate()
                updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { (_) in
                    self.prana?.deviceUpdate()
                }
                self.prana?.deviceUpdate()
            default:
                print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
          switch characteristic.uuid {
          case CBUUID(string: PranaUUID.characteristics):
            print(characteristic.value ?? "no value")
//            let byteArray = [UInt8](characteristic.value!)
//            let newResponse = newData.hexEncodedString()
//            print(newResponse)
            
            let newData = characteristic.value!
            let previousData = previousPacket?.data ?? Data()
            let count = min(previousData.count-1, newData.count-1)
            if (count > 0) {
                let difference = (0...count-1).map{( $0, previousData[$0], newData[$0])}.filter{ $1 != $2 }
                print("difference:", difference)
                
//                decodeData(newData, indexes: difference.map({$0.0}))
            }
            
            previousPacket = pranaPacket
            pranaPacket = PranaPacket(data: newData)
            prana?.isWorking = pranaPacket?.isWorking == true
          default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }

    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
//        print(#function, characteristic, "error: ", error);
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print(#function,  descriptor);
    }
}

extension BluetoothController {
    func decodeData(_ data: Data, indexes: [Int]) {
        guard data.count > 158 else {
            return
        }
        
        let mask:Int8 = 0b011_1111     //
        
        let index = 52
        let a = Int8(data: data.subdata(in: index-1..<index)).bigEndian & mask
        let b = Int8(data: data.subdata(in: index..<index+1)).bigEndian & mask
        print(index, " a a", a);
        print(index, " b", b);
    }
}
