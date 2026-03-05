
import SwiftKeychainWrapper
import Foundation

protocol TokenStorageProtocol {
    var token: String? { get }
}

final class OAuth2TokenStorage: TokenStorageProtocol {
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let tokenKey = "oauth2BearerToken"
    
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
