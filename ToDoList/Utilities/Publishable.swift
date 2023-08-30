import Foundation

@propertyWrapper
final class Publishable<Property> {
    typealias EventHandler<Host: AnyObject> = ((host: Host, property: Property)) -> Void

    struct Handler<Host: AnyObject>: Identifiable {
        let id: UUID
        let handler: EventHandler<Host>
        let weakRef: WeakRef<Host>
    }

    private var value: Property
    private var handlers: [Handler<AnyObject>] = []

    var wrappedValue: Property {
        get { value }
        set { publish(newValue) }
    }

    var projectedValue: Publishable {
        return self
    }

    init(wrappedValue: Property) {
        self.value = wrappedValue
    }

    @discardableResult
    func subscribe<Host: AnyObject>(
        by object: Host,
        _ handler: @escaping EventHandler<Host>
    ) -> ((_ id: UUID) -> Void, UUID) {
        return subscribe(by: object, immediate: false, handler)
    }

    @discardableResult
    func subscribe<Host: AnyObject>(
        by host: Host,
        immediate: Bool,
        _ handler: @escaping EventHandler<Host>
    ) -> ((_ id: UUID) -> Void, UUID) {
        let id = UUID()
        let anyHandler: EventHandler<AnyObject> = { args in
            if let host = args.host as? Host {
                handler((host, args.property))
            }
        }
        handlers.append(Handler(id: id, handler: anyHandler, weakRef: WeakRef(host)))
        if immediate { handler((host, value)) }
        return (unsubscribe, id)
    }

    func unsubscribe(_ id: UUID) {
        handlers.removeAll { $0.id == id }
    }

    func publish(_ newValue: Property) {
        value = newValue
        var _subscribers = [Handler<AnyObject>]()
        for subscriber in handlers {
            guard let host = subscriber.weakRef.value else { continue }
            subscriber.handler((host, value))
            _subscribers.append(subscriber)
        }
        handlers = _subscribers
    }
}
