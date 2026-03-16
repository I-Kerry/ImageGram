
import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Properties
    
    weak var delegate: ImagesListCellDelegate?
    
    private var photos: [Photo] = []
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    // MARK: - Formatters
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNotification()
        ImagesListService.shared.fetchPhotosNextPage()
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self else { return }
                self.updateTableViewAnimated()
            }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard segue.identifier == showSingleImageSegueIdentifier,
              let viewController = segue.destination as? SingleImageViewController,
              let indexPath = sender as? IndexPath
        else {
            return
        }
        let photo = photos[indexPath.row]
        viewController.largeImageUrl = photo.largeImageURL
    }
    
    // MARK: - Cell Congiguration
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let thumbURL = photo.thumbImageURL
        let url = URL(string: thumbURL)
        
        lazy var placeholder = MagicConstants.photoPlaceholder?.withTintColor(.ypWhite, renderingMode: .alwaysOriginal)
        
        cell.tableImage.kf.indicatorType = .activity
        cell.tableImage.kf.setImage(with: url,placeholder: placeholder) { result in
            switch result {
            case .success(let value):
                print(value.image)
                print(value.cacheType)
                print(value.source)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(let error):
                print(error)
            }
        }
        
        let likeImage = photo.isLiked ? UIImage(resource: .buttonActive) : UIImage(resource: .buttonNonActive)
        cell.likeButton.setImage(likeImage, for: .normal)
        
        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        
        cell.delegate = self
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageSize = photo.size
        
        let aspectRatio = imageSize.width / imageSize.height
        
        let imageViewWidth = tableView.bounds.width - 32
        
        let imageViewHeight = imageViewWidth / aspectRatio
        
        let cellHeight = imageViewHeight + 8
        
        return cellHeight
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row + 1 == ImagesListService.shared.photos.count {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
}

// MARK: - TableView Update

extension ImagesListViewController {
    
    func updateTableViewAnimated() {
        
        let oldCount = photos.count
        let newCount = ImagesListService.shared.photos.count
        
        photos = ImagesListService.shared.photos
        
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexArray = (oldCount..<newCount).map { n in
                    IndexPath(row: n , section: 0)
                }
                tableView.insertRows(at: indexArray, with: .automatic)
            } completion: { _ in }
        }
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: photo.isLiked) { result in
            switch result {
            case .success:
                self.photos = ImagesListService.shared.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                
                UIBlockingProgressHUD.dismiss()
            case .failure(let failure):
                UIBlockingProgressHUD.dismiss()
                print("[ImagesListViewController.imagesListCellDidTapLike]: \(failure)")
                self.showAlert()
            }
        }
    }
}

// MARK: - Alerts

extension ImagesListViewController {
    func showAlert() {
        let alert = UIAlertController(title: "Something went wrong",
                                      message: "Unable to proceed this activity",
                                      preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
}
