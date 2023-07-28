import Foundation
import CryptoKit

/// Represents the B2 Native API `b2_upload_file` endpoint.
/// https://www.backblaze.com/apidocs/b2-upload-file
public struct UploadFile {
    public struct Response: Codable {
        var accountId: String // typo, `acount`?
        var action: String
        var bucketId: String
        var contentLength: Int
        var contentSha1: String
        var contentType: String
        var fileId: String
        var fileName: String
        var uploadTimestamp: Int
    }

    /// The token must have the `writeFiles` capability.
    let authorizationToken: String
    let uploadURL: URL
    let fileName: String
    let fileData: Data

    var contentSha1: String {
        let digest = Insecure.SHA1.hash(data: fileData)
        let sha1Checksum = digest.map { String(format: "%02hhx", $0) }.joined()
        return sha1Checksum
    }
}

extension UploadFile: APIModel {
    public func urlRequest() throws -> URLRequest {
        var urlRequest = URLRequest(url: self.uploadURL)
        let contentLength = fileData.count + 40

        urlRequest.timeoutInterval = 10.0
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = self.fileData
        urlRequest.allHTTPHeaderFields = {
            [
                "Authorization": self.authorizationToken,
                "X-Bz-File-Name": self.fileName.percentEscapedString,
                "Content-Length": "\(contentLength)",
                "Content-Type": "b2/x-auto",
                "X-Bz-Content-Sha1": self.contentSha1
            ]
        }()
        return urlRequest
    }
}
