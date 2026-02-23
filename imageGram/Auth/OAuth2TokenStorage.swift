
import SwiftKeychainWrapper
import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let tokenKey = "oauth2BearerToken"
    
//    var token: String? {
//        get {
//            UserDefaults.standard.string(forKey: tokenKey)
//        }
//        set {
//            UserDefaults.standard.setValue(newValue, forKey: tokenKey)
//        }
//    }
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
    
}
