import Foundation

final class WeakRef<T: AnyObject> {
    weak var value: T?
    init(_ value: T?) {
        self.value = value
    }
}

@propertyWrapper
final class Observable<Property> {
    typealias Handler = (Property) -> Void

    private var value: Property
    private var observers: [(id: UUID, handler: Handler, weakRef: WeakRef<AnyObject>)] = []

    var wrappedValue: Property {
        get { value }
        set { notify(newValue) }
    }

    var projectedValue: Observable {
        return self
    }

    init(wrappedValue: Property) {
        self.value = wrappedValue
    }

    @discardableResult
    func observe(by object: AnyObject, _ handler: @escaping Handler) -> ((_ id: UUID) -> Void, UUID) {
        return observe(by: object, immediate: false, handler)
    }

    @discardableResult
    func observe(by object: AnyObject, immediate: Bool, _ handler: @escaping Handler) -> ((_ id: UUID) -> Void, UUID) {
        let id = UUID()
        observers.append((id, handler, WeakRef(object)))
        if immediate { handler(value) }
        return (unobserve, id)
    }

    func unobserve(_ id: UUID) {
        observers.remove { $0.id == id }
    }

    func notify(_ newValue: Property) {
        value = newValue
        for (_, handler, weakRef) in observers {
            if weakRef.value == nil { continue }
            handler(value)
        }
    }
}

final class Observer<Target> {
    private let target: Target
    private var unobservers: [((_ id: UUID) -> Void, UUID)] = []

    init(target: Target) {
        self.target = target
    }

    func on<Host: AnyObject, Value>(
        _ keyPath: KeyPath<Target, Observable<Value>>,
        by host: Host,
        immediate: Bool = true,
        handler: @escaping ((Host, Value)) -> Void
    ) {
        let observable = target[keyPath: keyPath]
        let unobserver = observable.observe(by: host, immediate: immediate) { [weak host] newValue in
            guard let host else { return }
            handler((host, newValue))
        }
        unobservers.append(unobserver)
    }

    deinit {
        unobservers.forEach { unobserve, id in unobserve(id) }
    }
}
