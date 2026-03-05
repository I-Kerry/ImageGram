
import Testing
@testable import imageGram
import XCTest

final class MockTokenStorage: TokenStorageProtocol {
    var token: String? = "TEST_TOKEN"
}

final class MockURLSessionTask: URLSessionTask {
    override func resume() {}
}

final class URLSessionMock: URLSessionProtocol {

    var objectTaskCalled = false

    func objectTask<T>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask where T: Decodable {

        objectTaskCalled = true

        let mockPhotos: [PhotoResult] = (0..<10).map {
            PhotoResult(
                id: "\($0)",
                width: 100,
                height: 100,
                date: nil,
                description: nil,
                urls: UrlsResult(thumbUrl: "", largeUrl: ""),
                likedByUsers: false,
                likes: 0
            )
        }

        if let result = mockPhotos as? T {
            completion(.success(result))
        }

        return MockURLSessionTask()
    }
}

final class ImagesListServiceTests: XCTestCase {
    
    func testExample() {
        let mockStorage = MockTokenStorage()
        let sessionMock = URLSessionMock()
//        let service = ImagesListService(tokenStorage: mockStorage)
        let service = ImagesListService(urlSession: sessionMock, tokenStorage: mockStorage)
        
        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                expectation.fulfill()
            }
        service.fetchPhotosNextPage()
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(service.photos.count, 10)
    }
}


struct imageGramTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}
