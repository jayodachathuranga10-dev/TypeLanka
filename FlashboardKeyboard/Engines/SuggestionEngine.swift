import Foundation

class SuggestionEngine {
    
    private let maxSuggestions = 3
    private var defaultSinhalaWords = ["ඔව්", "නැහැ", "හරි", "ස්තුතියි", "කොහොමද", "මම", "එන්න", "මොකද"]
    
    func getSuggestions(for currentWord: String, language: String) -> [String] {
        if currentWord.isEmpty {
             return language == "si" ? Array(defaultSinhalaWords.prefix(3)) : ["The", "I", "Are"]
        }
        
        let history = getUserHistory()
        var matches = history.filter { $0.hasPrefix(currentWord) }
        
        if language == "si" {
             matches.append(contentsOf: defaultSinhalaWords.filter { $0.hasPrefix(currentWord) })
        }
        
        var uniqueMatches = [String]()
        for match in matches {
             if !uniqueMatches.contains(match) {
                 uniqueMatches.append(match)
             }
        }
        
        return Array(uniqueMatches.prefix(maxSuggestions))
    }
    
    private let sharedDefaults = UserDefaults(suiteName: "group.com.flash.lanka")
    
    func recordWord(word: String) {
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        var history = getUserHistory()
        // Remove existing occurrence to place it at the top
        history.removeAll(where: { $0 == trimmed })
        history.insert(trimmed, at: 0)
        
        if history.count > 100 {
            history = Array(history.prefix(100))
        }
        sharedDefaults?.set(history, forKey: "UserWordHistory")
    }
    
    private func getUserHistory() -> [String] {
        return sharedDefaults?.stringArray(forKey: "UserWordHistory") ?? []
    }
}
