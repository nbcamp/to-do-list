import Foundation

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
        let unobserver = observable.observe(by: host, immediate: immediate, handler)
        unobservers.append(unobserver)
    }

    deinit {
        unobservers.forEach { unobserve, id in unobserve(id) }
    }
}
