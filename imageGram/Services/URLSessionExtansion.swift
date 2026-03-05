

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

protocol URLSessionProtocol {
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void ) -> URLSessionTask
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping(Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: {data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    print("[URLSession.data]: \(NetworkError.httpStatusCode(statusCode))")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                print("[URLSession.data]: \(NetworkError.urlRequestError(error))")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                print("[URLSession.data]: \(NetworkError.urlSessionError)")
            }
        })
        
        return task
    }
}

extension URLSession: URLSessionProtocol {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        
        let decoder = JSONDecoder()
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let object = try decoder.decode(T.self, from: data)
                    completion(.success(object))
                } catch {
                    completion(.failure(NetworkError.decodingError(error)))
                    print("[URLSession.objectTask]: \(NetworkError.decodingError(error)), data \(String(data: data, encoding: .utf8) ?? "nil")")
                }
            case .failure(let error):
                completion(.failure(error))
                print("[URLSession.objectTask]: \(error)")
            }
        }
        task.resume()
        return task
    }
}
