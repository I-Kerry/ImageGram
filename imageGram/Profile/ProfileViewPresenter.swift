import Foundation
import UIKit

public protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidload()
    func fetchAvatarUrl()
    func logout()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    private var profileService: ProfileServiceProtocol
    private var profileImageService: ProfileImageServiceProtocol
    
    init(profileService: ProfileServiceProtocol, profileImageService: ProfileImageServiceProtocol) {
        self.profileService = profileService
        self.profileImageService = profileImageService
    }

    func viewDidload() {
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self ] _ in
                guard let self else { return }
                fetchAvatarUrl()
            }
        
        fetchAvatarUrl()
        
        if let profile = profileService.profile {
            view?.updateProfile(name: profile.name, lName: profile.loginName, bio: profile.bio)
            profileImageService.fetchProfileImageURL(username: profile.username) { _ in
            }
//            ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in
//            }
        }
    }
    
    func fetchAvatarUrl() {
        guard
            let url = profileImageService.avatarURL,
            let imageUrl = URL(string: url)
        else { return }
        view?.updateAvatar(url: imageUrl)
    }
    
    func logout() {
        ProfileLogoutService.shared.logout()
        guard let window = UIApplication.shared.windows.first else { return }
        let splashVc = SplashViewController()
        window.rootViewController = splashVc
        window.makeKeyAndVisible()
    }
}

