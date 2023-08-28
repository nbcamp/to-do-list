import Foundation

@propertyWrapper
final class ObservableProperty<T> {
    typealias Observer = (T) -> Void

    var value: T
    private var observers: [(id: UUID, observer: Observer)] = []

    var wrappedValue: T {
        get { value }
        set {
            value = newValue
            observers.forEach { $0.observer(value) }
        }
    }

    var projectedValue: ObservableProperty {
        return self
    }

    init(wrappedValue: T) {
        self.value = wrappedValue
    }

    @discardableResult
    func subscribe(_ observer: @escaping Observer) -> UUID {
        let id = UUID()
        observers.append((id, observer))
        return id
    }

    func unsubscribe(_ id: UUID) {
        observers.remove { $0.id == id }
    }
}
