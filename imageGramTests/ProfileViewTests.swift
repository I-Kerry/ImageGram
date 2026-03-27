
import Foundation
@testable import imageGram
import XCTest

final class ProfileViewTests: XCTestCase {
    func testPresenterCallsViewDidLoad() {
        let vc = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        
        vc.presenter = presenter
        presenter.view = vc
        
        _ = vc.view
        
        presenter.viewDidload()
        
        XCTAssertTrue(presenter.didLoadCalled)
    }
    
    func testViewControllerAvatarUpdateCalled() {
        let vc = ProfileViewControllerSpy()
        let profileService = ProfileServiceMock()
        let profileImageService = ProfileImageServiceMock()
        let presenter = ProfileViewPresenter(profileService: profileService, profileImageService: profileImageService)
        presenter.view = vc
        guard
            let url = ProfileImageService.shared.avatarURL,
            let imageUrl = URL(string: url)
        else { return }
        
        presenter.fetchAvatarUrl()
        vc.updateAvatar(url: imageUrl)
        
        presenter.viewDidload()
        
        
        XCTAssertTrue(vc.avatarCalled)
    }
    
    func testViewControllerProfileUpdateCalled() {
        let vc = ProfileViewControllerSpy()
        let profileService = ProfileServiceMock()
        let profileImageService = ProfileImageServiceMock()
        let presenter = ProfileViewPresenter(profileService: profileService, profileImageService: profileImageService)
        
        presenter.view = vc
        presenter.viewDidload()
        
        XCTAssertTrue(vc.profileCalled)
    }
}

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var didLoadCalled: Bool = false
    
    func viewDidload() {
        didLoadCalled = true
    }
    
    func fetchAvatarUrl() {
        
    }
    
    func logout() {
    }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?
    var avatarCalled: Bool = false
    var profileCalled: Bool = false
    func updateAvatar(url: URL) {
        avatarCalled = true
    }
    
    func updateProfile(name: String, lName: String, bio: String?) {
        profileCalled = true
    }
}

final class ProfileServiceMock: ProfileServiceProtocol {
    func fetchProfile(_ token: String, completion: @escaping (Result<imageGram.Profile, any Error>) -> Void) {
    }
    
    var profile: Profile? = Profile(
        username: "cat",
        name: "cat",
        loginName: "cat",
        bio: nil)
}

final class ProfileImageServiceMock: ProfileImageServiceProtocol {
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, any Error>) -> Void) {
    }
    
    var avatarURL: String?
}
