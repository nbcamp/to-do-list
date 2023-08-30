import Foundation

final class Subscriber<Target> {
    private let target: Target
    private var unsubscribes: [((_ id: UUID) -> Void, UUID)] = []

    init(target: Target) {
        self.target = target
    }

    func on<Host: AnyObject, Value>(
        _ keyPath: KeyPath<Target, Publishable<Value>>,
        by host: Host,
        immediate: Bool = true,
        handler: @escaping ((Host, Value)) -> Void
    ) {
        let publishable = target[keyPath: keyPath]
        let unsubscribe = publishable.subscribe(by: host, immediate: immediate, handler)
        unsubscribes.append(unsubscribe)
    }

    deinit {
        unsubscribes.forEach { unsubscribe, id in unsubscribe(id) }
    }
}
