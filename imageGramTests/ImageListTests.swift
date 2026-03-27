
import Foundation
@testable import imageGram
import XCTest

final class ImageListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "ImagesListViewController") as! ImagesListViewController
//        let vc = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        vc.presenter = presenter
        presenter.view = vc
        
        _ = vc.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    func testPresenterCallsUpdateTableView() {
        let vc = ImagesListViewControllerSpy()
        let presenter = ImageListPresenter()
        
        presenter.view = vc
        presenter.viewDidLoad()
        
        XCTAssertTrue(vc.tableViewCalled)
    }
    
    func testPresenterCallsUpdateLike() {
        let vc = ImagesListViewControllerSpy()
        let presenter = ImageListPresenter()
        
        presenter.view = vc
        
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        
        presenter.photos.append(photo)
        
        let expectation = XCTestExpectation(description: "isLikedCalled")
        DispatchQueue.main.async {
            presenter.didTapLike(at: IndexPath(row: 0, section: 0))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                XCTAssertTrue(vc.updateLikeCalled)
                expectation.fulfill()
            }
        }
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

