//
//  SecurityTokenService.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 18/4/25.
//

import Foundation
import Vapor
import Crypto

struct SecurityTokenService {
    let secret: String
    
    
    func generateActivationToken(datosAdicionales: String) -> String {
        // 1. Formato de fecha correcto: ssnnhhddmmyyyy
        let formatter = DateFormatter()
        //formatter.timeZone = TimeZone(secondsFromGMT: 0)
        //formatter.dateFormat = "ssmmhhddMMyyyy" // minuto = mm, mes = MM
        formatter.dateFormat = "ssmmHHddMMyyyy"

        let baseTime = formatter.string(from: Date())
        print("🕓 baseTime (fecha del token):", baseTime)

        // 2. Convertir a hex la información adicional (lowercase)
        print("📬 Info adicional usada:", datosAdicionales)
        let hexInfo = datosAdicionales.lowercased().data(using: .utf8)!
            .map { String(format: "%02x", $0) }
            .joined()
        print("📬 HEX info:", hexInfo)

        // 3. Longitud XOR con 0xAD4A
        let xorLength = String(format: "%04x", hexInfo.count ^ 0xAD4A)

        // 4. Generar 10 bytes aleatorios
        let randomHex = (0..<10).map { _ in String(format: "%02x", Int.random(in: 0...255)) }.joined()

        // 5. Cadena origen del token
        let datosOrigen = (baseTime + xorLength + hexInfo + randomHex).lowercased()
        print("🧱 datosOrigen:", datosOrigen)
        
        // 6. Calcular firma
        let firma = calcularFirmaTokenSeguridad(datos: datosOrigen)

        // 7. Token final = datosOrigen + firma
        print("🔐 Token final:", datosOrigen + firma)
        return datosOrigen + firma
    }

    private func calcularFirmaTokenSeguridad(datos: String) -> String {
        let hash1 = Insecure.MD5.hash(data: Data(datos.utf8))
        let paso1 = hash1.map { String(format: "%02x", $0) }
            .joined()
            .uppercased()
        let paso2 = String(paso1.reversed())
        let paso3 = paso2.replacingOccurrences(of: "6", with: "9")
        let clave_correo: String = String(UnicodeScalar(27)) + secret
        //print("🔐 Clave_correo fija: \(clave_correo.utf8.map { $0 })")
        let paso4 = paso3 + clave_correo
        let firma = Insecure.MD5.hash(data: Data(paso4.utf8))
            .map { String(format: "%02x", $0) }.joined().lowercased()
        return firma
    }
    
    func extractInfoFromToken(token: String) -> String? {
        guard token.count > 34 else { return nil }

        // Paso 1: Extraer la longitud codificada en XOR (caracteres del 15 al 18)
        let lengthHex = String(token[token.index(token.startIndex, offsetBy: 14)..<token.index(token.startIndex, offsetBy: 18)])
        guard let xorLength = Int(lengthHex, radix: 16) else { return nil }

        // Paso 2: Decodificar longitud original
        let infoLength = xorLength ^ 0xAD4A

        // Paso 3: Extraer los datos hexadecimales de información adicional
        let hexInfoStart = token.index(token.startIndex, offsetBy: 18)
        let hexInfoEnd = token.index(hexInfoStart, offsetBy: infoLength)
        let hexInfo = String(token[hexInfoStart..<hexInfoEnd])

        // Paso 4: Convertir hex en String
        var bytes = [UInt8]()
        var index = hexInfo.startIndex
        while index < hexInfo.endIndex {
            let nextIndex = hexInfo.index(index, offsetBy: 2)
            if nextIndex <= hexInfo.endIndex {
                let byteString = hexInfo[index..<nextIndex]
                if let byte = UInt8(byteString, radix: 16) {
                    bytes.append(byte)
                }
            }
            index = nextIndex
        }

        return String(bytes: bytes, encoding: .utf8)
    }
}
