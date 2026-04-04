import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func updateAvatar(url: URL)
    func updateProfile(name: String, lName: String, bio: String?)
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?
    private var profileImageService: ProfileImageServiceProtocol? = ProfileImageService.shared
    
    private var imageView: UIImageView!
    private var nameLabel: UILabel!
    private var loginName: UILabel!
    private var discription: UILabel!
    private var logoutButton: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImageView()
        setupNameLabel()
        setupLoginName()
        setupDiscription()
        setupLogoutButton()
        setupConstraints()
        logoutButton.accessibilityIdentifier = "logoutButton"
        
        view.backgroundColor = .ypBlack
        
        let presenter = ProfileViewPresenter(profileService: ProfileService.shared, profileImageService: profileImageService ?? ProfileImageService.shared)
        
        configure(presenter)
        
        presenter.viewDidload()
    }
    
    @objc
    private func tapLogoutButton() {
        showAlert()
    }
    
    private func setupImageView() {
        let profileimage = MagicConstants.profileimage
        imageView = UIImageView(image: profileimage)
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .ypBlack
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 35
        
    }
    
    private func setupNameLabel() {
        nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        nameLabel.textColor = .white
        nameLabel.accessibilityIdentifier = "nameLabel"
    }
    
    private func setupLoginName() {
        loginName = UILabel()
        loginName.text = "@ekaterina_nov"
        view.addSubview(loginName)
        loginName.translatesAutoresizingMaskIntoConstraints = false
        loginName.textColor = .ypGrayLoginName
        loginName.font = UIFont.systemFont(ofSize: 13)
        loginName.accessibilityIdentifier = "loginName"
    }
    
    private func setupDiscription() {
        discription = UILabel()
        discription.text = "Hello, world!"
        view.addSubview(discription)
        discription.translatesAutoresizingMaskIntoConstraints = false
        discription.textColor = .white
        discription.font = UIFont.systemFont(ofSize: 13)
        discription.accessibilityIdentifier = "discription"
    }
    
    private func setupLogoutButton() {
        guard let logoutImage = MagicConstants.logoutButton else { return }
        
        logoutButton = UIButton.systemButton(with: logoutImage, target: self, action: #selector(self.tapLogoutButton))
        logoutButton.tintColor = .ypRed
        view.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
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
    
    func updateProfile(name: String, lName: String, bio: String?) {
        nameLabel.text = name.isEmpty ? "Uknown" : name
        loginName.text = lName.isEmpty ? "@Uknown" : lName
        discription.text = bio?.isEmpty == false ? bio : "There is nothing yet"
    }
    
    func updateAvatar(url: URL) {
        lazy var placeholder = MagicConstants.personInCircle?.withTintColor(.lightGray, renderingMode: .alwaysOriginal).withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url, placeholder: placeholder, options: [.processor(processor), .scaleFactor(UIScreen.main.scale), .cacheOriginalImage, .forceRefresh]) { result in
            switch result {
            case .success(let value):
                print(value.image)
                print(value.cacheType)
                print(value.source)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func configure(_ presenter: ProfileViewPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
}

extension ProfileViewController {
    func showAlert() {
        let alert = UIAlertController(title: "Bye, bye", message: "Are you sure you want to leave?", preferredStyle: .alert)
        let alertAction1 = UIAlertAction(title: "No", style: .default) { _ in
        return }
        let alertAction2 = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            guard let self else { return }
            presenter?.logout()
        }
        alert.addAction(alertAction2)
        alert.addAction(alertAction1)
        present(alert, animated: true)
    }
}
