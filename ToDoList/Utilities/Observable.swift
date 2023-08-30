import Foundation

@propertyWrapper
final class Observable<Property> {
    typealias Handler<Host: AnyObject> = ((Host, Property)) -> Void

    struct Observer<Host: AnyObject>: Identifiable {
        let id: UUID
        let handler: Handler<Host>
        let weakRef: WeakRef<Host>
    }

    private var value: Property
    private var observers: [Observer<AnyObject>] = []
    private let queue = DispatchQueue(label: "ObservableQueue")

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
    func observe<Host: AnyObject>(
        by object: Host,
        _ handler: @escaping Handler<Host>
    ) -> ((_ id: UUID) -> Void, UUID) {
        return observe(by: object, immediate: false, handler)
    }

    @discardableResult
    func observe<Host: AnyObject>(
        by host: Host,
        immediate: Bool,
        _ handler: @escaping Handler<Host>
    ) -> ((_ id: UUID) -> Void, UUID) {
        let id = UUID()
        let anyHandler: Handler<AnyObject> = { params in
            let (anyHost, property) = params
            if let host = anyHost as? Host { handler((host, property)) }
        }
        queue.sync { observers.append(Observer(id: id, handler: anyHandler, weakRef: WeakRef(host))) }
        if immediate { handler((host, value)) }
        return (unobserve, id)
    }

    func unobserve(_ id: UUID) {
        queue.sync { observers.removeAll { $0.id == id } }
    }

    func notify(_ newValue: Property) {
        clean()
        value = newValue
        for observer in observers {
            guard let host = observer.weakRef.value else { continue }
            observer.handler((host, value))
        }
    }

    private func clean() {
        queue.async { [weak self] in
            guard let self else { return }
            let before = self.observers.count
            self.observers = self.observers.filter { $0.weakRef.value != nil }
            print("[Observable.clean] Before: \(before), After: \(self.observers.count)")
        }
    }
}
