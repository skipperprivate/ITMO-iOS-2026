import Foundation

enum JwtDecoder {

    static func decodeUserId(_ jwtToken: String) -> String? {
        let parts = jwtToken.split(separator: ".")
        guard parts.count == 3 else { return nil }

        var payload = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        switch payload.count % 4 {
        case 2: payload += "=="
        case 3: payload += "="
        default: break
        }

        guard let data = Data(base64Encoded: payload),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let sub = json["sub"] as? String
        else { return nil }

        return sub
    }
}
