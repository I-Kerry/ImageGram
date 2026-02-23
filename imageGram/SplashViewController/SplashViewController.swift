
import UIKit

final class SplashViewController: UIViewController {
    
    private let storage = OAuth2TokenStorage.shared
    private let segueIdentifier = "ShowAuthenticationScreen"
    private let profileService = ProfileService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if storage.token != nil {
            guard let token = storage.token else { return }
//            switchToTabBarController()
            fetchProfile(token: token)
        } else {
            performSegue(withIdentifier: segueIdentifier, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else {
                
                assertionFailure("Failed to prepare for \(segueIdentifier)")
                return
            }
            
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self,
                  let token = self.storage.token else { return }
//            self.fetchProfile(token: token)
        }
        
//        guard let token = storage.token else { return }
//        
//        fetchProfile(token: token)
        
//        switchToTabBarController()
    }
    
    func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success:
                guard let username = profileService.profile?.username else { return }
                ProfileImageService.shared.fetchProfileImageURL(username: username) {_ in }
                self.switchToTabBarController()
            case .failure:
                assertionFailure("Error: Profile was not found")
                OAuth2TokenStorage.shared.token = nil
                break
            }
        }
    }
}
