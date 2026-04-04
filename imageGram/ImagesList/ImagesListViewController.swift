
import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImageListPresenterProtocol? { get set }
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func updateLike(at indexPath: IndexPath, isLiked: Bool)
    func showAlert()
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Properties
    
    var presenter: ImageListPresenterProtocol? 
    
    weak var delegate: ImagesListCellDelegate?
    
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
        if presenter == nil {
            let presenter = ImageListPresenter()
            configure(presenter)
        } else {
            presenter?.view = self
        }
        setupTableView()
        presenter?.viewDidLoad()
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard segue.identifier == showSingleImageSegueIdentifier,
              let viewController = segue.destination as? SingleImageViewController,
              let indexPath = sender as? IndexPath
        else {
            return
        }
        guard let photo = presenter?.photos[indexPath.row] else { return }
        viewController.largeImageUrl = photo.largeImageURL
    }
    
    // MARK: - Cell Congiguration
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let photo = presenter?.photos[indexPath.row] else { return }
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
    
    func configure(_ presenter: ImageListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.photos[indexPath.row] else { return 0}
        
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
        guard let photo = presenter?.photos.count else { return 0 }
        return photo
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
        
        if indexPath.row + 1 == presenter?.photos.count {
            presenter?.fetchNextPage()
        }
    }
}

// MARK: - TableView Update

extension ImagesListViewController {
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
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
        presenter?.didTapLike(at: indexPath)
    }
    
    func updateLike(at indexPath: IndexPath, isLiked: Bool) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else { return }
        cell.setIsLiked(isLiked)
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
