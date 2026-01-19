import UIKit

final class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profileimage = UIImage(named: "image_photo")
        let imageView = UIImageView(image: profileimage)
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .ypBlack
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 35
        
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        nameLabel.textColor = .white
        
        let loginName = UILabel()
        loginName.text = "@ekaterina_nov"
        view.addSubview(loginName)
        loginName.translatesAutoresizingMaskIntoConstraints = false
        loginName.textColor = .ypGrayLoginName
        loginName.font = UIFont.systemFont(ofSize: 13)
        
        let discription = UILabel()
        discription.text = "Hello, world!"
        view.addSubview(discription)
        discription.translatesAutoresizingMaskIntoConstraints = false
        discription.textColor = .white
        discription.font = UIFont.systemFont(ofSize: 13)
        
        let logoutButton = UIButton.systemButton(with: UIImage(systemName: "ipad.and.arrow.forward")!, target: self, action: #selector(self.tapLogoutButton))
        logoutButton.tintColor = .ypRed
        view.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            loginName.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginName.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            discription.topAnchor.constraint(equalTo: loginName.bottomAnchor, constant: 8),
            discription.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
    }
    
    @objc
    private func tapLogoutButton() {
    }
}
