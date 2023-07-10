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
    .init(id: .init(), description: "Wakeup", isComplete: true),
    .init(id: .init(), description: "Homework", isComplete: false),
    .init(id: .init(), description: "Play Videogames", isComplete: true),
    .init(id: .init(), description: "Do Keto", isComplete: false),
    .init(id: .init(), description: "Go to Bed", isComplete: false)
  ]
  
  static let mockTodo: Todo = .init(
    id: .init(),
    description: "write a back blaze demo app",
    isComplete: false
  )
}
