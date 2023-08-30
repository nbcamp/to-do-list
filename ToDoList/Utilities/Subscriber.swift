import Foundation

final class Subscriber<Source> {
    private let source: Source
    private var unsubscribes: [((UUID) -> Void, UUID)] = []

    init(source: Source) {
        self.source = source
    }

    func on<Publisher: AnyObject, Property>(
        _ keyPath: KeyPath<Source, Publishable<Property>>,
        by publisher: Publisher,
        immediate: Bool = true,
        _ callback: @escaping ((Publisher, Property)) -> Void
    ) {
        let publishable = source[keyPath: keyPath]
        let unsubscribe = publishable.subscribe(by: publisher, immediate: immediate, callback)
        unsubscribes.append(unsubscribe)
    }

    deinit {
        unsubscribes.forEach { unsubscribe, id in unsubscribe(id) }
    }
}
