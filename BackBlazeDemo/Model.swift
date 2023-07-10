import Foundation
import Tagged
import IdentifiedCollections

struct Todo: Identifiable, Equatable, Codable {
  typealias ID = Tagged<Self, UUID>
  
  let id: ID
  var description: String = ""
  var isComplete: Bool = false
}

extension Todo {
  static let mockTodos: IdentifiedArrayOf<Todo> = [
    .init(id: .init(), description: "wakeup", isComplete: true),
    .init(id: .init(), description: "homework", isComplete: false),
    .init(id: .init(), description: "play videogames", isComplete: true),
    .init(id: .init(), description: "do keto", isComplete: false),
    .init(id: .init(), description: "go to bed", isComplete: false)
  ]
  
  static let mockTodo: Todo = .init(
    id: .init(),
    description: "write a back blaze demo app",
    isComplete: false
  )
}
