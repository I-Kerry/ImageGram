
import Foundation

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
    
    private enum CodingKeys: String, CodingKey {
        case small
        case medium
        case large
    }
}

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() { }
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    private var urlSession = URLSession.shared
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ProfileImageService.fetchProfileImageURL]: \(NetworkError.invalidRequest)")
            completion(.failure(NetworkError.invalidRequest))
//            print("Network Error 401")
            return
        }
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            print("[ProfileImageService.fetchProfileImageURL]: \(NetworkError.invalidRequest)")
            completion(.failure(NetworkError.invalidRequest))
//            print("Bad Request: Error 400")
            return
        }
        let newTask = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let userResult):
                self.avatarURL = userResult.profileImage.small
                completion(.success(userResult.profileImage.small))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": userResult.profileImage.small])
            case .failure(let error):
//                assertionFailure("Request error \(error.localizedDescription)")
                print("[ProfileImageService.fetchProfileImageURL]: \(error)")
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = newTask
        //        newTask.resume()
    }
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

extension ProfileImageService {
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
}
