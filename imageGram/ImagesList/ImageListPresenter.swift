
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
    var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    
    func viewDidLoad() {
        
        setupNotification()
        ImagesListService.shared.fetchPhotosNextPage()
        updateTableViewAnimated()
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
        let newCount = ImagesListService.shared.photos.count
        
        photos = ImagesListService.shared.photos
        
        view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
    }
    
    func fetchNextPage() {
        if photos.count == ImagesListService.shared.photos.count {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
    
    func didTapLike(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: photo.isLiked) { result in
            switch result {
            case .success:
//                self.photos = ImagesListService.shared.photos
                self.photos = ImagesListService.shared.photos
//                cell.setIsLiked(self.presenter?.photos[indexPath.row].isLiked)
                let isLiked = self.photos[indexPath.row].isLiked
//                view.cell.setIsLiked(isLiked)
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
