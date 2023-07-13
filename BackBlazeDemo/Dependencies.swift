import Foundation
import ComposableArchitecture
import B2Api

extension DependencyValues {
  var b2Api: B2ApiClient {
    get { self[B2ApiClient.self] }
    set { self[B2ApiClient.self] = newValue }
  }
}
