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

    typealias EventHandler<Host: AnyObject, Event: EventProtocol> = ((Host, Event.Payload)) -> Void
    typealias AnyEventHandler = ((host: AnyObject, payload: Any)) -> Void
    private var handlers: [String: [(host: WeakRef<AnyObject>, handler: AnyEventHandler)]] = [:]

    func on<Host: AnyObject, Event: EventProtocol>(_ event: Event.Type, by host: Host, _ handler: @escaping EventHandler<Host, Event>) {
        let anyHandler: AnyEventHandler = { args in
            if let host = args.host as? Host,
               let payload = args.payload as? Event.Payload
            { handler((host, payload)) }
        }
        handlers[event.id, default: []].append((WeakRef(host), anyHandler))
    }

    func off<Host: AnyObject, Event: EventProtocol>(_ event: Event, of host: Host) {
        handlers[event.id]?.removeAll { $0.host.value === host }
    }

    func reset<Host: AnyObject>(_ host: Host) {
        handlers.keys.forEach { key in handlers[key]?.removeAll { $0.host.value === host } }
    }

    func emit<Event: EventProtocol>(_ event: Event) {
        handlers[event.id]?.forEach { weakRef, handler in
            guard let host = weakRef.value else { return }
            handler((host, event.payload))
        }
    }
}
