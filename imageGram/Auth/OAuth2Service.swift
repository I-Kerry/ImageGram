

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
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
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("OAuth2Service: failed to create token request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        fetch(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
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
                    
                } catch {
                    print(String(data: data, encoding: .utf8))
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Network Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    private func fetch(request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void) {
        let task = URLSession.shared.data(for: request) { result in
            handler(result)
        }
        task.resume()
        
    }
}
