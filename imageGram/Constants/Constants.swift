
import UIKit

enum Constants {
    static let accessKey = "RrOjkySKSrtj124O3Xd_scEmAjeZg6MnmXZQoWDJUm8"
    static let secretKey = "63YpApbRNlGq0FzG2fyXkj_vZoMcc_vVefkq5_8bVkc"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURLString = URL(string: "https://api.unsplash.com")
}

enum MagicConstants {
    static let vectorLogo = UIImage(named: "Vector")
    static let personInCircle = UIImage(systemName: "person.crop.circle.fill")
    static let profileimage = UIImage(named: "image_photo")
    static let logoutButton = UIImage(systemName: "ipad.and.arrow.forward")
    
    static let tabBarProfile = UIImage(named: "tab_profile_active")
    
    static let imagesListViewControllerIdentifier = "ImagesListViewController"
    static let authViewControllerIdentifier = "AuthViewController"
    static let TabBarViewControllerIdentifier = "TabBarViewController"
}
