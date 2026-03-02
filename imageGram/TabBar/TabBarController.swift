
import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: MagicConstants.imagesListViewControllerIdentifier)
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(title: "", image: MagicConstants.tabBarProfile, selectedImage: nil)
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
