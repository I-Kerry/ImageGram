
import UIKit
final class ImagesListService {
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    private lazy var dateFormatter = ISO8601DateFormatter()
    
    private(set) var photos: [Photo] = []
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func fetchPhotosNextPage() {
        
        guard task == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
//        guard let url = URL(string: "https://api.unsplash.com/photos") else { return }
        
        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else { return }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)")
        ]
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let newTask = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult],Error>) in
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
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                }
            case .failure(let error):
                print("[ImagesListService.fetchPhotosNextPage]: \(error)")
                
            }
            self.task = nil
        }
        
        task = newTask
        newTask.resume()
    }
}
