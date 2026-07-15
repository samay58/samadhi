import SamadhiDomain

@MainActor
final class RunTaskStore {
    private var tasks: [RunTaskKind: Task<Void, Never>] = [:]
    private var generations: [RunTaskKind: Int] = [:]

    deinit {
        for task in tasks.values {
            task.cancel()
        }
    }

    func replace(_ kind: RunTaskKind, operation: @escaping @MainActor () async -> Void) {
        cancel(kind)
        let generation = (generations[kind] ?? 0) + 1
        generations[kind] = generation
        tasks[kind] = Task { [weak self] in
            await operation()
            guard let self, generations[kind] == generation else { return }
            tasks[kind] = nil
        }
    }

    func cancel(_ kind: RunTaskKind) {
        tasks[kind]?.cancel()
        tasks[kind] = nil
        generations[kind, default: 0] += 1
    }

    func cancelAll() {
        for task in tasks.values {
            task.cancel()
        }
        tasks.removeAll()
        for kind in generations.keys {
            generations[kind, default: 0] += 1
        }
    }
}
