import Foundation

protocol DataModel: Identifiable, Equatable {}

extension DataModel {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
