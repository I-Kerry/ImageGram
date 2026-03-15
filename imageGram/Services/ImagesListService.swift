
import UIKit
final class ImagesListService {
    
    static let shared = ImagesListService()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    private lazy var dateFormatter = ISO8601DateFormatter()
    
    private(set) var photos: [Photo] = []
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func fetchPhotosNextPage() {
        
        guard task == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
                
        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else { return }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = urlComponents.url else { return }
        
        guard let token = OAuth2TokenStorage.shared.token else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

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
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let token = OAuth2TokenStorage.shared.token else { return }
        
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "DELETE" : "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let newTask = urlSession.data(for: request) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(id: photo.id,
                                         size: photo.size,
                                         createdAt: photo.createdAt,
                                         welcomeDescription: photo.welcomeDescription,
                                         thumbImageURL: photo.thumbImageURL,
                                         largeImageURL: photo.largeImageURL,
                                         isLiked: !photo.isLiked)
                    self.photos[index] = newPhoto
                    
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        newTask.resume()
    }
    
    func cleanImagesList() {
        photos = []
        lastLoadedPage = nil
        task?.cancel()
    }
}
