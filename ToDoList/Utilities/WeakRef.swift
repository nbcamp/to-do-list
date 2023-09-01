struct WeakRef<T: AnyObject> {
    weak var value: T?
    init(_ value: T?) {
        self.value = value
    }
}

struct WeakArray<T: AnyObject> {
    private var elements: [WeakRef<T>]

    var allObjects: [T] { elements.compactMap { $0.value } }
    var count: Int { allObjects.count }

    init(_ elements: [T]) {
        self.elements = elements.map(WeakRef.init)
    }

    mutating func append(_ element: T) {
        elements.append(WeakRef(element))
    }

    mutating func remove(at index: Int) {
        elements.remove(at: index)
    }

    subscript(_ index: Int) -> T? { allObjects[index] }
}
