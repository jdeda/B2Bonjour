import Foundation
import CryptoKit

/// Represents the B2 Native API `b2_upload_file` endpoint.
/// https://www.backblaze.com/apidocs/b2-upload-file
public struct UploadFile {
    public struct Response: Codable {
        var accountId: String // typo, `acount`?
        var action: String
        var bucketId: String
        var contentLength: String
        var contentSha1: String
        var contentType: String
        var fieldId: String
        var fileInfo: String
        var fileName: String
        var uploadTimestamp: String
    }
    
    public struct Request: Codable {
        /// Name of file in
        let fileName: String
        let contentLength: String
        let contentSha1: String
        
        // Problem: api needs to encode ur object into an SHA1 string
        // but the app developer should have an easy life and just have
        // to give a fileName and object, which this client will do the dirty work of encoding
        init?(fileName: String, fileContents: any Codable) {
            self.fileName = fileName
            guard let data = try? JSONEncoder().encode(fileContents)
            else { return nil }
            let sha1Digest = Insecure.SHA1.hash(data: data)
            let sha1Checksum = sha1Digest.map { String(format: "%02hhx", $0) }.joined()
            self.contentLength = String(data.count + 40) // 40 is the num of hex checksum bytes
            // TODO: fileName and fileContent max bytes == 7000, if encrypted, 2048
            // but it alsoi says accorduinig to files they can be 5GiB
            self.contentSha1 = sha1Checksum
        }

        enum CodingKeys: String, CodingKey {
            case fileName = "X-Bz-File-Name"
            case contentLength = "Content-Length"
            case contentSha1 = "X-Bz-Content-Sha1"
        }
    }
    
    /// The token must have the `writeFiles` capability.
    let auth: Authentication
    let request: Request
    let uploadURL: GetUploadURL
}

extension UploadFile: APIModel {
    public func urlRequest() throws -> URLRequest {
        // Setup urlRequest
        let relativeURL = "b2api/v2/b2_upload_file"
        let absoluteURL = self.auth.apiUrl.appendingPathComponent(relativeURL)
        var urlRequest = URLRequest(url: absoluteURL)

        // Set urlRequest parameters.
        urlRequest.timeoutInterval = 10.0
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = {
            return try? JSONEncoder().encode(self.request)
        }()
        urlRequest.allHTTPHeaderFields = self.auth.authHeaders()
            .appending(NetworkUtilities.defaultBackblazeHeaders)
        return urlRequest
    }
}

//// MARK: - APIModel Conformance
//extension ListBuckets: APIModel {
//    func urlRequest() throws -> URLRequest {
//        let relativeURL = "b2api/v2/b2_list_buckets"
//        let absoluteURL = self.auth.apiUrl.appendingPathComponent(relativeURL)
//
//        var urlRequest = URLRequest(url: absoluteURL)
//        // in seconds
//        urlRequest.timeoutInterval = 10.0
//        urlRequest.httpMethod = "POST"
//        urlRequest.httpBody = {
//            let request = Request(accountId: self.auth.accountId)
//            return try? JSONEncoder().encode(request)
//        }()
//        urlRequest.allHTTPHeaderFields = self.auth.authHeaders()
//            .appending(NetworkUtilities.defaultBackblazeHeaders)
//        return urlRequest
//    }
//}
