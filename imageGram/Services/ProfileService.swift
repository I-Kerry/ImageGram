

import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
    
    private enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

final class ProfileService {
    
    static let shared = ProfileService()
    private var task: URLSessionTask?
    private var urlSession = URLSession.shared
    //    private var token = OAuth2TokenStorage.shared.token
    private init() {}
    private(set) var profile: Profile?
    
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService.fetchProfile] \(NetworkError.invalidRequest)")
            completion(.failure(NetworkError.invalidRequest))
//            print("Bad Request: Error 400")
            return
        }
        let newTask = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let profileResult):
//                guard let lastName = profileResult.lastName else { return }
                let fullName: String
                if let lastName = profileResult.lastName {
                    fullName = profileResult.firstName + " " + lastName
                } else {
                    fullName = profileResult.firstName
                }
                let profile = Profile(username: profileResult.username, name: fullName /*profileResult.firstName + " " + lastName*/, loginName: "@\(profileResult.username)", bio: profileResult.bio)
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("[ProfileService.fetchProfile] \(error)")
                completion(.failure(error))
//                print("Network Error: \(error.localizedDescription)")
            }
            self.task = nil
        }
        self.task = newTask
        //        newTask.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
