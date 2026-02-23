

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    private init() {}
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else { completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard
            let request = makeOAuthTokenRequest(code: code)
        else {
            completion(.failure(AuthServiceError.invalidRequest))
            print("Bad Request: Error 400")
            return
        }
        //        self.task = fetch(request: request) { [weak self] result in
        //            guard let self else { return }
        self.task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    //                    do {
                    //                        let response = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    let token = response.accessToken
                    guard !token.isEmpty else {
                        print("An empty token is received")
                        completion(.failure(NetworkError.decodingError(NSError(domain: "Empty token", code: 0))))
                        return
                    }
                    OAuth2TokenStorage.shared.token = token
                    DispatchQueue.main.async {
                        completion(.success(token))
                    }
                    
                    //                    } catch {
                    //                        print(String(data: data, encoding: .utf8))
                    //                        completion(.failure(error))
                    //                    }
                case .failure(let error):
                    print("Network Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                self.task = nil
                self.lastCode = nil
            }
        }
    }
        
//        guard let request = makeOAuthTokenRequest(code: code) else {
//            print("OAuth2Service: failed to create token request")
//            completion(.failure(NetworkError.invalidRequest))
//            return
//        }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("OAuth2Service: URLComponents init failed")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        guard let url = urlComponents.url else {
            print("OAuth2Service: URLComponents.url is nil")
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        return urlRequest
    }
    
//    private func fetch(request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
//        
//        let task = URLSession.shared.data(for: request) { result in
//            handler(result)
//        }
//        task.resume()
//        return task
//    }
}
