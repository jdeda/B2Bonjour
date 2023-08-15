import Foundation

public struct GetUploadURL {
    public struct Request: Codable {
        public var bucketId: String
        
        public init(bucketId: String) {
            self.bucketId = bucketId
        }
    }
    
    public struct Response: Codable {
        public let bucketId: String
        public let uploadUrl: URL
        public let authorizationToken: String
    }
    
    public let auth: Authentication
    public let request: Request
    
    public init(auth: Authentication, request: Request) {
        self.auth = auth
        self.request = request
    }
}

extension GetUploadURL: APIModel {
    func urlRequest() throws -> URLRequest {
        let relativeURL = "b2api/v2/b2_get_upload_url"
        let absoluteURL = self.auth.apiUrl.appendingPathComponent(relativeURL)
            .appendingQueryItem(name: "bucketId", value: self.request.bucketId)

        var urlRequest = URLRequest(url: absoluteURL)
        urlRequest.timeoutInterval = 10.0
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = self.auth.authHeaders()
            .appending(NetworkUtilities.defaultBackblazeHeaders)
        return urlRequest
    }
}
