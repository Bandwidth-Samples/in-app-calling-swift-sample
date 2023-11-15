import Foundation

enum InfoPlistKey: String {
    case connectionHeaderPass = "connection.header.pass"
    case connectionHeaderUser = "connection.header.user"
    case connectionToken = "connection.token"
    case connectionPort = "connection.port"
    case connectionDomain = "connection.domain"
    case accountPassword = "account.password"
    case accountDisplayName = "account.display-name"
    case accountUsername = "account.username"
}

func extractValue(forKey key: InfoPlistKey) -> Any? {
    if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
       let infoDict = NSDictionary(contentsOfFile: path) as? [String: Any] {
        return infoDict[key.rawValue]
    }
    return nil
}

func extractStringValue(forKey key: InfoPlistKey, defaultValue: String = "") -> String {
    if let rawValue = extractValue(forKey: key) as? String {
        return rawValue
    }
    return defaultValue
}

func extractIntValue(forKey key: InfoPlistKey, defaultValue: Int = 0) -> Int {
    if let rawValue = extractValue(forKey: key) as? Int {
        return rawValue
    }
    return defaultValue
}
