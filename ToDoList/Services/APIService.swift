import Foundation

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
}

enum APIError: Error {
    case invalidUrlError
    case unknownError(cause: Error)
    case emptyData
}

class APIConfig {
    var baseUrl: String = ""
}

final class APIService {
    static let shared = APIService()
    private init() {}

    static let config = APIConfig()

    private let decoder = JSONDecoder()

    @discardableResult
    func fetch<T: Codable>(
        url: String,
        method: HttpMethod = .get,
        model: T.Type,
        lazy: Bool = false,
        queryItems: [URLQueryItem] = [],
        completion: @escaping (Result<T, APIError>) -> Void
    ) -> () -> Void {
        func load() {
            Task {
                do {
                    let url = try createUrl(string: "\(Self.config.baseUrl)\(url)", queryItems: queryItems)
                    let (data, _) = try await URLSession.shared.data(for: createRequest(url: url))
                    let model = try decoder.decode(T.self, from: data)
                    completion(.success(model))
                } catch {
                    completion(.failure(.unknownError(cause: error)))
                }
            }
        }

        if !lazy { load() }
        return load
    }

    private func createUrl(string: String, queryItems: [URLQueryItem]) throws -> URL {
        guard var urlComponents = URLComponents(string: string) else { throw APIError.invalidUrlError }
        var _queryItems = urlComponents.queryItems ?? []
        queryItems.forEach { _queryItems.append($0) }
        urlComponents.queryItems = _queryItems
        guard let url = urlComponents.url else { throw APIError.invalidUrlError }
        return url
    }

    private func createRequest(url: URL?, method: HttpMethod = .get) throws -> URLRequest {
        guard let url else { throw APIError.invalidUrlError }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 30
        return request
    }

    #if DEBUG
    private func __test(data: Data) {
        print(#function + " Started")
        do {
            let object = try JSONSerialization.jsonObject(with: data)
            print(object)
        } catch {
            print(error)
        }
        print(#function + " Ended")
    }
    #endif
}
