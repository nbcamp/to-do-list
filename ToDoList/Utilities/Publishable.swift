import Foundation

@propertyWrapper
final class Publishable<Property> {
    typealias Changes = (old: Property, new: Property)
    typealias Event<Subscriber: AnyObject> = ((subscriber: Subscriber, property: Changes)) -> Void

    struct Publisher<Subscriber: AnyObject>: Identifiable {
        let id: UUID
        let event: Event<Subscriber>
        let subscriber: WeakRef<Subscriber>
    }

    private var value: Property
    private var publishers: [Publisher<AnyObject>] = []

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
    func subscribe<Subscriber: AnyObject>(
        by subscriber: Subscriber,
        _ event: @escaping Event<Subscriber>
    ) -> ((_ id: UUID) -> Void, UUID) {
        return subscribe(by: subscriber, immediate: true, event)
    }

    @discardableResult
    func subscribe<Subscriber: AnyObject>(
        by subscriber: Subscriber,
        immediate: Bool,
        _ event: @escaping Event<Subscriber>
    ) -> ((_ id: UUID) -> Void, UUID) {
        let id = UUID()
        let anyEvent: Event<AnyObject> = { args in
            guard let publisher = args.subscriber as? Subscriber else { return }
            event((publisher, args.property))
        }
        publishers.append(.init(id: id, event: anyEvent, subscriber: .init(subscriber)))
        if immediate { event((subscriber, (value, value))) }
        return (unsubscribe, id)
    }

    func unsubscribe(_ id: UUID) {
        publishers.removeAll { $0.id == id }
    }

    func publish(_ changes: Changes? = nil) {
        let (old, new) = changes ?? (value, value)
        publishers = publishers.compactMap { publisher in
            guard let subscriber = publisher.subscriber.value else { return nil }
            publisher.event((subscriber, (old, new)))
            return publisher
        }
    }
}
