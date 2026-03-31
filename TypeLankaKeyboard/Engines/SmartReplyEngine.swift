import Foundation

class SmartReplyEngine {
    
    struct Rule {
        let triggers: [String]
        let replies: [String]
    }
    
    // Local embedded rules for fast matching without AI APIs
    private let rules: [Rule] = [
        Rule(triggers: ["hello", "hi", "hey"], replies: ["Hi there!", "Hello", "Hey!"]),
        Rule(triggers: ["kohomada", "how are you", "what's up"], replies: ["Hondin", "Fine", "I'm good, thanks!"]),
        Rule(triggers: ["monawada", "what are you doing", "what r u doing"], replies: ["Mukuth na", "Nothing much", "Wedak naha"]),
        Rule(triggers: ["bye", "see ya", "gihin ennam"], replies: ["Bye!", "See you", "Parissamin"]),
        Rule(triggers: ["thanks", "thank you", "sthuthi"], replies: ["Welcome", "No problem", "Ela"])
    ]
    
    func generateReplies(context: String) -> [String]? {
        let lowerContext = context.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if lowerContext.isEmpty { return nil }
        let words = lowerContext.components(separatedBy: .whitespacesAndNewlines)
        
        // Exact matching or trailing word matching
        if let lastWord = words.last {
            for rule in rules {
                if rule.triggers.contains(lastWord) || rule.triggers.contains(lowerContext) {
                    return Array(rule.replies.shuffled().prefix(3))
                }
            }
        }
        return nil
    }
}
