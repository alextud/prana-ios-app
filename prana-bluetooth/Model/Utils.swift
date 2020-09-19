//
//  Utils.swift
//  prana-bluetooth
//
//  Created by Alexandru Tudose on 18.09.2020.
//

import Foundation

extension Data {
    private static let hexAlphabet = "0123456789abcdef".unicodeScalars.map { $0 }

    public func hexEncodedString() -> String {
        return String(self.reduce(into: "".unicodeScalars, { (result, value) in
            result.append(Data.hexAlphabet[Int(value/16)])
            result.append(Data.hexAlphabet[Int(value%16)])
        }))
    }
}


extension String {
      enum ExtendedEncoding {
          case hexadecimal
      }

      func data(using encoding:ExtendedEncoding) -> Data? {
          let hexStr = self.dropFirst(self.hasPrefix("0x") ? 2 : 0)

          guard hexStr.count % 2 == 0 else { return nil }

          var newData = Data(capacity: hexStr.count/2)

          var indexIsEven = true
          for i in hexStr.indices {
              if indexIsEven {
                  let byteRange = i...hexStr.index(after: i)
                  guard let byte = UInt8(hexStr[byteRange], radix: 16) else { return nil }
                  newData.append(byte)
              }
              indexIsEven.toggle()
          }
          return newData
      }
}


// Data Extensions:
protocol DataConvertible {
    init(data:Data)
    var data:Data { get }
}

extension DataConvertible {
    init(data:Data) {
        guard data.count == MemoryLayout<Self>.size else {
            fatalError("data size (\(data.count)) != type size (\(MemoryLayout<Self>.size))")
        }
        self = data.withUnsafeBytes { $0.load(as: Self.self) }
    }

    var data:Data {
        return withUnsafeBytes(of: self) { Data($0) }
    }
}

extension UInt8:DataConvertible {}
extension Int8:DataConvertible {}
extension UInt16:DataConvertible {}
extension UInt32:DataConvertible {}
extension Int16:DataConvertible {}
extension Int32:DataConvertible {}
extension Int64:DataConvertible {}
extension Double:DataConvertible {}
extension Float:DataConvertible {}



import Foundation
import Accelerate

//struct Float16: CustomStringConvertible {
//
//    var rawValue: UInt16
//
//    static func float_to_float16(value: Float) -> UInt16 {
//        var input: [Float] = [value]
//        var output: [UInt16] = [0]
//        var sourceBuffer = vImage_Buffer(data: &input, height: 1, width: 1, rowBytes: MemoryLayout<Float>.size)
//        var destinationBuffer = vImage_Buffer(data: &output, height: 1, width: 1, rowBytes: MemoryLayout<UInt16>.size)
//        vImageConvert_PlanarFtoPlanar16F(&sourceBuffer, &destinationBuffer, 0)
//        return output[0]
//    }
//
//    static func float16_to_float(value: UInt16) -> Float {
//        var input: [UInt16] = [value]
//        var output: [Float] = [0]
//        var sourceBuffer = vImage_Buffer(data: &input, height: 1, width: 1, rowBytes: MemoryLayout<UInt16>.size)
//        var destinationBuffer = vImage_Buffer(data: &output, height: 1, width: 1, rowBytes: MemoryLayout<Float>.size)
//        vImageConvert_Planar16FtoPlanarF(&sourceBuffer, &destinationBuffer, 0)
//        return output[0]
//    }
//
//    static func floats_to_float16s(values: [Float]) -> [UInt16] {
//        var inputs = values
//        var outputs = Array<UInt16>(repeating: 0, count: values.count)
//        let width = vImagePixelCount(values.count)
//        var sourceBuffer = vImage_Buffer(data: &inputs, height: 1, width: width, rowBytes: MemoryLayout<Float>.size * values.count)
//        var destinationBuffer = vImage_Buffer(data: &outputs, height: 1, width: width, rowBytes: MemoryLayout<UInt16>.size * values.count)
//        vImageConvert_PlanarFtoPlanar16F(&sourceBuffer, &destinationBuffer, 0)
//        return outputs
//    }
//
//    static func float16s_to_floats(values: [UInt16]) -> [Float] {
//        var inputs: [UInt16] = values
//        var outputs: [Float] = Array<Float>(repeating: 0, count: values.count)
//        let width = vImagePixelCount(values.count)
//        var sourceBuffer = vImage_Buffer(data: &inputs, height: 1, width: width, rowBytes: MemoryLayout<UInt16>.size * values.count)
//        var destinationBuffer = vImage_Buffer(data: &outputs, height: 1, width: width, rowBytes: MemoryLayout<Float>.size * values.count)
//        vImageConvert_Planar16FtoPlanarF(&sourceBuffer, &destinationBuffer, 0)
//        return outputs
//    }
//
//    init(_ value: Float) {
//        self.rawValue = Float16.float_to_float16(value: value)
//    }
//
//    var floatValue: Float {
//        return Float16.float16_to_float(value: self.rawValue)
//    }
//
//    var description: String {
//        return self.floatValue.description
//    }
//
//    static func + (lhs: Float16, rhs: Float16) -> Float16 {
//        return Float16(lhs.floatValue + rhs.floatValue)
//    }
//
//    static func - (lhs: Float16, rhs: Float16) -> Float16 {
//        return Float16(lhs.floatValue - rhs.floatValue)
//    }
//
//    static func * (lhs: Float16, rhs: Float16) -> Float16 {
//        return Float16(lhs.floatValue * rhs.floatValue)
//    }
//
//    static func / (lhs: Float16, rhs: Float16) -> Float16 {
//        return Float16(lhs.floatValue / rhs.floatValue)
//    }
//}
