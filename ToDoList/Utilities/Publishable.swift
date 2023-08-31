import Foundation

@propertyWrapper
final class Publishable<Property> {
    typealias Changes = (old: Property, new: Property)
    typealias EventCallback<Publisher: AnyObject> = ((publisher: Publisher, property: Changes)) -> Void

    struct Subscriber<Publisher: AnyObject>: Identifiable {
        let id: UUID
        let callback: EventCallback<Publisher>
        let publisher: WeakRef<Publisher>
    }

    private var value: Property
    private var subscribers: [Subscriber<AnyObject>] = []

    var wrappedValue: Property {
        get { value }
        set {
            let oldValue = value
            value = newValue
            publish((oldValue, newValue))
        }
    }

    var projectedValue: Publishable { self }

    init(wrappedValue: Property) {
        self.value = wrappedValue
    }

    @discardableResult
    func subscribe<Publisher: AnyObject>(
        by publisher: Publisher,
        _ callback: @escaping EventCallback<Publisher>
    ) -> ((_ id: UUID) -> Void, UUID) {
        return subscribe(by: publisher, immediate: true, callback)
    }

    @discardableResult
    func subscribe<Publisher: AnyObject>(
        by publisher: Publisher,
        immediate: Bool,
        _ callback: @escaping EventCallback<Publisher>
    ) -> ((_ id: UUID) -> Void, UUID) {
        let id = UUID()
        let anyCallback: EventCallback<AnyObject> = { args in
            guard let publisher = args.publisher as? Publisher else { return }
            callback((publisher, args.property))
        }
        subscribers.append(.init(id: id, callback: anyCallback, publisher: .init(publisher)))
        if immediate { callback((publisher, (value, value))) }
        return (unsubscribe, id)
    }

    func unsubscribe(_ id: UUID) {
        subscribers.removeAll { $0.id == id }
    }

    func publish(_ changes: Changes) {
        subscribers = subscribers.compactMap { subscriber in
            guard let publisher = subscriber.publisher.value else { return nil }
            subscriber.callback((publisher, changes))
            return subscriber
        }
    }
}
