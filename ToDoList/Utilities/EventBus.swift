import Foundation

protocol EventProtocol: Identifiable {
    associatedtype Payload
    var id: String { get }
    var payload: Payload { get }
}

extension EventProtocol {
    var id: String { Self.id }
    static var id: String { String(describing: Self.self) }
}

final class EventBus {
    static let shared: EventBus = .init()
    private init() {}

    typealias EventCallback<Emitter: AnyObject, Event: EventProtocol> = ((Emitter, Event.Payload)) -> Void
    typealias AnyEventCallback = ((emitter: AnyObject, payload: Any)) -> Void

    struct Listener<Emitter: AnyObject> {
        var callback: AnyEventCallback
        var emitter: WeakRef<Emitter>
    }

    private var listenerMap: [String: [Listener<AnyObject>]] = [:]

    func on<Emitter: AnyObject, Event: EventProtocol>(
        _ event: Event.Type,
        by emitter: Emitter,
        _ callback: @escaping EventCallback<Emitter, Event>
    ) {
        let anyCallback: AnyEventCallback = { args in
            if let emitter = args.emitter as? Emitter,
               let payload = args.payload as? Event.Payload
            { callback((emitter, payload)) }
        }
        listenerMap[event.id, default: []].append(.init(callback: anyCallback, emitter: .init(emitter)))
    }

    func off<Emitter: AnyObject, Event: EventProtocol>(
        _ event: Event,
        of emitter: Emitter
    ) {
        listenerMap[event.id]?.removeAll { $0.emitter.value === emitter }
    }

    func reset<Emitter: AnyObject>(_ emitter: Emitter) {
        listenerMap.keys.forEach { key in listenerMap[key]?.removeAll { $0.emitter.value === emitter } }
    }

    func emit<Event: EventProtocol>(_ event: Event) {
        let key = event.id
        listenerMap[key] = listenerMap[key]?.compactMap { listener in
            guard let emitter = listener.emitter.value else { return nil }
            listener.callback((emitter, event.payload))
            return listener
        }
        if let listeners = listenerMap[key], listeners.isEmpty {
            listenerMap.removeValue(forKey: key)
        }
    }
}
