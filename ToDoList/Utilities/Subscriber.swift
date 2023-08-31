import Foundation

final class Subscriber<Source> {
    typealias Changes<Property> = (old: Property, new: Property)
    typealias EventCallback<Publisher: AnyObject, Property> = ((publisher: Publisher, property: Changes<Property>)) -> Void
    
    private let source: Source
    private var unsubscribes: [((UUID) -> Void, UUID)] = []

    init(source: Source) {
        self.source = source
    }

    func on<Publisher: AnyObject, Property>(
        _ keyPath: KeyPath<Source, Publishable<Property>>,
        by publisher: Publisher,
        immediate: Bool = true,
        _ callback: @escaping EventCallback<Publisher, Property>
    ) {
        let publishable = source[keyPath: keyPath]
        let unsubscribe = publishable.subscribe(by: publisher, immediate: immediate, callback)
        unsubscribes.append(unsubscribe)
    }

    deinit {
        unsubscribes.forEach { unsubscribe, id in unsubscribe(id) }
    }
}
