
import UIKit
final class ImagesListService {
    
    private let urlSession: URLSessionProtocol
    private let tokenStorage: TokenStorageProtocol
    private var task: URLSessionTask?
    
    init(urlSession: URLSessionProtocol = URLSession.shared, tokenStorage: TokenStorageProtocol = OAuth2TokenStorage.shared) {
        self.urlSession = urlSession
        self.tokenStorage = tokenStorage
    }
    
    private var lastLoadedPage: Int?
    private lazy var dateFormatter = ISO8601DateFormatter()
    
    private(set) var photos: [Photo] = []
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func fetchPhotosNextPage() {
        print("fetchPhotosNextPage called")
        
        guard task == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
//        guard let token = OAuth2TokenStorage.shared.token else { return }
        guard let token = tokenStorage.token else { return }
        
        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else { print("URLComponents failed")
            return }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = urlComponents.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let newTask = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult],Error>) in
            print("COMPLETION CALLED")
            guard let self else { return }
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map {
                    Photo(
                        id: $0.id,
                        size: CGSize(width: $0.width, height: $0.height),
                        createdAt: self.dateFormatter.date(from: $0.date ?? ""),
                        welcomeDescription: $0.description,
                        thumbImageURL: $0.urls.thumbUrl,
                        largeImageURL: $0.urls.largeUrl,
                        isLiked: $0.likedByUsers)
                }
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
            case .failure(let error):
                print("REQUEST FAILED:", error)
                print("[ImagesListService.fetchPhotosNextPage]: \(error)")
                
            }
        }
        
        self.task = newTask
    }
    
//    func fetchPhotosNextPage() {
//        guard task == nil else { return }
//        let nextPage = (lastLoadedPage ?? 0) + 1
//        guard let token = OAuth2TokenStorage.shared.token else { return }
//        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else { return }
//        urlComponents.queryItems = [
//            URLQueryItem(name: "page", value: "\(nextPage)"),
//            URLQueryItem(name: "per_page", value: "10")
//        ]
//        guard let url = urlComponents.url else { return }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        let newTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            
//            DispatchQueue.main.async {
//                guard let self else { return }
//                
//                guard let http = response as? HTTPURLResponse,
//                      (200..<300).contains(http.statusCode),
//                      let data
//                else {
//                    let code = (response as? HTTPURLResponse)?.statusCode ?? -1
//                    return
//                }
//                
//                do {
//                    let photoResults = try JSONDecoder().decode([PhotoResult].self, from: data)
//                    let newPhotos = photoResults.map {
//                        Photo(id: $0.id,
//                              size: CGSize(width: $0.width, height: $0.height),
//                              createdAt: self.dateFormatter.date(from: $0.date ?? ""),
//                              welcomeDescription: $0.description,
//                              thumbImageURL: $0.urls.thumbUrl,
//                              largeImageURL: $0.urls.largeUrl,
//                              isLiked: $0.likedByUsers)
//                    }
//                    self.photos.append(contentsOf: newPhotos)
//                    self.lastLoadedPage = nextPage
//                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
//                } catch {
//                    assertionFailure("\(error)")
//                }
//            }
//        }
//        self.task = newTask
//        task?.resume()
//    }
}
