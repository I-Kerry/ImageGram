import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
//    override init(nibName: String?, bundle: Bundle?) {
//        super .init(nibName: nibName, bundle: bundle)
//        addObserver()
//    }
//    
//    required init?(coder: NSCoder) {
//        super .init(coder: coder)
//        addObserver()
//    }
//    
//    deinit {
//        removeObserver()
//    }
//    
//    private func addObserver() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(updateAvatar(notification:)),
//            name: ProfileImageService.didChangeNotification,
//            object: nil)
//    }
//    
//    private func removeObserver() {
//        NotificationCenter.default.removeObserver(
//            self,
//            name: ProfileImageService.didChangeNotification,
//            object: nil)
//    }
//    
//    @objc
//    private func updateAvatar(notification: Notification) {
//        guard
//            isViewLoaded,
//            let userInfo = notification.userInfo,
//            let profileImageURL = userInfo["URL"] as? String,
//            let url = URL(string: profileImageURL)
//        else { return }
//        
//        // TODO vot zdes kingfisher budet
//    } это первый способ со старым
    
    
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private var imageView: UIImageView!
    private var nameLabel: UILabel!
    private var loginName: UILabel!
    private var discription: UILabel!
    private var logoutButton: UIButton!
    
    private var profileService = ProfileService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImageView()
        setupNameLabel()
        setupLoginName()
        setupDiscription()
        setupLogoutButton()
        setupConstraints()
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self ] _ in
                guard let self else { return }
                self.updateAvatar()
            }
        
        updateAvatar()
        
//        if let avatarURL = ProfileImageService.shared.avatarURL,
//           let url = URL(string: avatarURL) {
//            
//        } старый способ
        
        // TODO [Sprint 11]  Обновите аватар, если нотификация
                            // была опубликована до того, как мы подписались.

        if let profile = profileService.profile {
            updateProfile(profile: profile)
            ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in
            }
        }
        
        
//        guard let token = OAuth2TokenStorage.shared.token else {
//            assertionFailure("Token is wrong")
//            return
//        }
//        profile.fetchProfile("\(token)") { result in
//            switch result {
//            case .success(let profile):
//                self.updateProfile(profile: profile)
//            case .failure(let error):
//                assertionFailure("\(error)")
//            }
//
//        }

    }
    
    @objc
    private func tapLogoutButton() {
        OAuth2TokenStorage.shared.token = nil
    }
    
    private func setupImageView() {
        let profileimage = UIImage(named: "image_photo")
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
    }
    
    private func setupLoginName() {
        loginName = UILabel()
        loginName.text = "@ekaterina_nov"
        view.addSubview(loginName)
        loginName.translatesAutoresizingMaskIntoConstraints = false
        loginName.textColor = .ypGrayLoginName
        loginName.font = UIFont.systemFont(ofSize: 13)
    }
    
    private func setupDiscription() {
        discription = UILabel()
        discription.text = "Hello, world!"
        view.addSubview(discription)
        discription.translatesAutoresizingMaskIntoConstraints = false
        discription.textColor = .white
        discription.font = UIFont.systemFont(ofSize: 13)
    }
    
    private func setupLogoutButton() {
        logoutButton = UIButton.systemButton(with: UIImage(systemName: "ipad.and.arrow.forward")!, target: self, action: #selector(self.tapLogoutButton))
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
    
    private func updateProfile(profile: Profile) {
        nameLabel.text = profile.name.isEmpty ? "Uknown" : profile.name
        loginName.text = profile.loginName.isEmpty ? "@Uknown" : profile.loginName
        discription.text = profile.bio?.isEmpty != nil ? profile.bio : "There is nothing yet"
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else { return }
        // TODO A v novom metode zdes nuzhno budet zakinut obnovlenie s kingfishera
        
        
        let placeholder = UIImage(systemName: "person.crop.circle.fill")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal).withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: imageUrl, placeholder: placeholder, options: [.processor(processor), .scaleFactor(UIScreen.main.scale), .cacheOriginalImage, .forceRefresh]) { result in
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
}

