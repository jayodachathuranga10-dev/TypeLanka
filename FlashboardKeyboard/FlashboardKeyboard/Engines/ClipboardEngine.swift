import Foundation
import UIKit

struct ClipItem: Codable, Equatable {
    let id: UUID
    let text: String
    var isPinned: Bool
    let timestamp: Date
}

class ClipboardEngine {
    private let maxHistoryCount = 20
    private let historyKey = "TypeLankaClipboardHistory_V2"
    
    func pullFromSystemClipboard() {
        guard let text = UIPasteboard.general.string, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        var history = getHistory()
        // If it already exists, just bump it to the top (unless it's pinned)
        if let existingIdx = history.firstIndex(where: { $0.text == text }) {
            let item = history.remove(at: existingIdx)
            if item.isPinned {
                history.insert(item, at: 0) // Keep pins at top
            } else {
                let firstUnpinnedIdx = history.firstIndex(where: { !$0.isPinned }) ?? history.count
                history.insert(item, at: firstUnpinnedIdx)
            }
        } else {
            let newItem = ClipItem(id: UUID(), text: text, isPinned: false, timestamp: Date())
            let firstUnpinnedIdx = history.firstIndex(where: { !$0.isPinned }) ?? history.count
            history.insert(newItem, at: firstUnpinnedIdx)
        }
        
        saveHistory(history)
    }
    
    func getHistory() -> [ClipItem] {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let items = try? JSONDecoder().decode([ClipItem].self, from: data) else {
            return []
        }
        return items
    }
    
    func togglePin(id: UUID) {
        var items = getHistory()
        if let idx = items.firstIndex(where: { $0.id == id }) {
            items[idx].isPinned.toggle()
            // Re-sort: Pinned at top, then by date descending
            items.sort { 
                if $0.isPinned != $1.isPinned { return $0.isPinned }
                return $0.timestamp > $1.timestamp 
            }
            saveHistory(items)
        }
    }
    
    func deleteItem(id: UUID) {
        var items = getHistory()
        items.removeAll { $0.id == id }
        saveHistory(items)
    }
    
    func clearUnpinned() {
        let items = getHistory().filter { $0.isPinned }
        saveHistory(items)
    }
    
    private func saveHistory(_ items: [ClipItem]) {
        var history = items
        // trim unpinned if exceeding max
        if history.count > maxHistoryCount {
            let pinned = history.filter { $0.isPinned }
            var unpinned = history.filter { !$0.isPinned }
            let allowedUnpinned = maxHistoryCount - pinned.count
            if allowedUnpinned > 0 {
                unpinned = Array(unpinned.prefix(allowedUnpinned))
            } else {
                unpinned = []
            }
            history = pinned + unpinned
        }
        
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }
}
