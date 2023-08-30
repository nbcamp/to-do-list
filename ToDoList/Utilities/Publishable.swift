import Foundation

@propertyWrapper
final class Publishable<Property> {
    typealias EventCallback<Publisher: AnyObject> = ((publisher: Publisher, property: Property)) -> Void

    struct Subscriber<Publisher: AnyObject>: Identifiable {
        let id: UUID
        let callback: EventCallback<Publisher>
        let publisher: WeakRef<Publisher>
    }

    private var value: Property
    private var subscribers: [Subscriber<AnyObject>] = []

    var wrappedValue: Property {
        get { value }
        set { publish(newValue) }
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
        return subscribe(by: publisher, immediate: false, callback)
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
        if immediate { callback((publisher, value)) }
        return (unsubscribe, id)
    }

    func unsubscribe(_ id: UUID) {
        subscribers.removeAll { $0.id == id }
    }

    func publish(_ newValue: Property) {
        value = newValue
        subscribers = subscribers.compactMap { subscriber in
            guard let publisher = subscriber.publisher.value else { return nil }
            subscriber.callback((publisher, value))
            return subscriber
        }
    }
}
