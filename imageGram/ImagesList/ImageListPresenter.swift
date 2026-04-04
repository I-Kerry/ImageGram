
import Foundation
import UIKit

protocol ImageListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get set }
    func viewDidLoad()
    func fetchNextPage()
    func didTapLike(at indexPath: IndexPath)
}

final class ImageListPresenter: ImageListPresenterProtocol {
    
    private let service: ImagesListServiceProtocol
    var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    
    init(service: ImagesListServiceProtocol = ImagesListService.shared) {
        self.service = service
    }
    
    func viewDidLoad() {
        setupNotification()
        service.fetchPhotosNextPage()
    }
    
    func setupNotification() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self else { return }
                self.updateTableViewAnimated()
            }
    }
    
    func updateTableViewAnimated() {
        
        let oldCount = photos.count
        let newCount = service.photos.count
        
        photos = service.photos
        
        view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
    }
    
    func fetchNextPage() {
        if photos.count == service.photos.count {
            service.fetchPhotosNextPage()
        }
    }
    
    func didTapLike(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        service.changeLike(photoId: photo.id, isLike: photo.isLiked) {
            result in
            switch result {
            case .success:
                self.photos = self.service.photos
                let isLiked = self.photos[indexPath.row].isLiked
                self.view?.updateLike(at: indexPath, isLiked: isLiked)
                
                UIBlockingProgressHUD.dismiss()
            case .failure(let failure):
                UIBlockingProgressHUD.dismiss()
                print("[ImagesListViewController.imagesListCellDidTapLike]: \(failure)")
                self.view?.showAlert()
            }
        }
    }
}
