import WebKit
import Foundation

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    init() {}
    
    func logout() {
        cleanCookies()
        ProfileService.shared.cleanProfile()
        ProfileImageService.shared.cleanProfileImage()
        ImagesListService.shared.cleanImagesList()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
