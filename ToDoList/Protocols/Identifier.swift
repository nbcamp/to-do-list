protocol Identifier {
    static var identifier: String { get }
}

extension Identifier {
    static var identifier: String { String(describing: self) }
}
