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

    typealias EventCallback<Listener: AnyObject, Event: EventProtocol> = ((Listener, Event.Payload)) -> Void
    typealias AnyEventCallback = ((listener: AnyObject, payload: Any)) -> Void

    struct Emitter<Listener: AnyObject> {
        var callback: AnyEventCallback
        var listener: WeakRef<Listener>
    }

    private var emitterMap: [String: [Emitter<AnyObject>]] = [:]

    func on<Listener: AnyObject, Event: EventProtocol>(
        _ event: Event.Type,
        by listener: Listener,
        _ callback: @escaping EventCallback<Listener, Event>
    ) {
        let anyCallback: AnyEventCallback = { args in
            if let listener = args.listener as? Listener,
               let payload = args.payload as? Event.Payload
            { callback((listener, payload)) }
        }
        emitterMap[event.id, default: []].append(.init(callback: anyCallback, listener: .init(listener)))
    }

    func off<Listener: AnyObject, Event: EventProtocol>(
        _ event: Event,
        by listener: Listener
    ) {
        emitterMap[event.id]?.removeAll { $0.listener.value === listener }
    }

    func reset<Listener: AnyObject>(_ listener: Listener) {
        emitterMap.keys.forEach { key in emitterMap[key]?.removeAll { $0.listener.value === listener } }
    }

    func emit<Event: EventProtocol>(_ event: Event) {
        let key = event.id
        emitterMap[key] = emitterMap[key]?.compactMap { emitter in
            guard let listener = emitter.listener.value else { return nil }
            emitter.callback((listener, event.payload))
            return emitter
        }
        if let emitters = emitterMap[key], emitters.isEmpty {
            emitterMap.removeValue(forKey: key)
        }
    }
}
