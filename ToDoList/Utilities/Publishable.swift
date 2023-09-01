import Foundation

@propertyWrapper
final class Publishable<Property> {
    typealias Changes = (old: Property, new: Property)
    typealias EventCallback<Subscriber: AnyObject> = ((subscriber: Subscriber, property: Changes)) -> Void

    struct Publisher<Subscriber: AnyObject> {
        let callback: EventCallback<Subscriber>
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

    func subscribe<Subscriber: AnyObject>(
        by subscriber: Subscriber,
        immediate: Bool = false,
        _ callback: @escaping EventCallback<Subscriber>
    ) {
        unsubscribe(by: self)
        let anyCallback: EventCallback<AnyObject> = { args in
            guard let subscriber = args.subscriber as? Subscriber else { return }
            callback((subscriber, args.property))
        }
        publishers.append(.init(callback: anyCallback, subscriber: .init(subscriber)))
        if immediate { callback((subscriber, (value, value))) }
    }

    func unsubscribe<Subscriber: AnyObject>(by subscriber: Subscriber) {
        publishers.removeAll { publisher in
            guard let sub = publisher.subscriber.value else { return true }
            return sub === subscriber
        }
    }

    func publish(_ changes: Changes? = nil) {
        let (old, new) = changes ?? (value, value)
        publishers = publishers.compactMap { publisher in
            guard let subscriber = publisher.subscriber.value else { return nil }
            publisher.callback((subscriber, (old, new)))
            return publisher
        }
    }
}
