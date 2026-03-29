
import Foundation
@testable import imageGram
import XCTest

final class ImageListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // Given
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        vc.presenter = presenter
        presenter.view = vc
        
        // When
        
        _ = vc.view
        
        // Then
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    func testPresenterCallsUpdateTableView() {
        
        // Given
        
        let vc = ImagesListViewControllerSpy()
        let service = ImagesListServiceMock()
        let presenter = ImageListPresenter(service: service)
        presenter.view = vc
        
        // When
        
        presenter.viewDidLoad()
        
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
        
        // Then
        
        XCTAssertTrue(vc.tableViewCalled)
    }
    
    func testPresenterCallsUpdateLike() {
        
        // Given
        
        let vc = ImagesListViewControllerSpy()
        let presenter = ImageListPresenter()
        presenter.view = vc
                
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        
        presenter.photos.append(photo)
        
        let expectation = XCTestExpectation(description: "isLikedCalled")
        
        // When
        
        DispatchQueue.main.async {
            presenter.didTapLike(at: IndexPath(row: 0, section: 0))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                
                // Then
                
                XCTAssertTrue(vc.updateLikeCalled)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

final class ImagesListPresenterSpy: ImageListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    
    var photos: [Photo] = []
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchNextPage() {
        
    }
    
    func didTapLike(at indexPath: IndexPath) {
        
    }
}

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImageListPresenterProtocol?
    var tableViewCalled: Bool = false
    var updateLikeCalled: Bool = false
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        tableViewCalled = true
    }
    
    func updateLike(at indexPath: IndexPath, isLiked: Bool) {
        updateLikeCalled = true
    }
    
    func showAlert() {
        
    }
}

final class ImagesListServiceMock: ImagesListServiceProtocol {
    var photos: [Photo] = []
    
    var fetchPhotoNextPageCalled = false
    
    func fetchPhotosNextPage() {
        fetchPhotoNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, any Error>) -> Void) {
        
    }
}
