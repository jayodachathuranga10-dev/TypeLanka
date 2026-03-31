import Foundation

class TransliterationEngine {
    
    // Basic mapping tables
    let consonants: [String: String] = [
        "k": "ක්", "g": "ග්", "c": "ච්", "j": "ජ්", "t": "ට්", "d": "ඩ්", 
        "th": "ත්", "dh": "ද්", "n": "න්", "p": "ප්", "b": "බ්", "m": "ම්",
        "y": "ය්", "r": "ර්", "l": "ල්", "v": "ව්", "w": "ව්", "s": "ස්",
        "sh": "ෂ්", "h": "හ්", "f": "ෆ්", "nd": "න්‍ද්", "mb": "ම්බ්", "ng": "න්‍ග්"
    ]
    
    let vowels: [String: String] = [
        "a": "අ", "aa": "ආ", "ae": "ඇ", "aee": "ඈ",
        "i": "ඉ", "ii": "ඊ",
        "u": "උ", "uu": "ඌ", "oo": "ඌ",
        "e": "එ", "ee": "ඒ", "ea": "ඒ",
        "o": "ඔ", "oa": "ඕ",
        "au": "ඖ"
    ]
    
    let vowelModifiers: [String: String] = [
        "a": "", "aa": "ා", "ae": "ැ", "aee": "ෑ",
        "i": "ි", "ii": "ී",
        "u": "ු", "uu": "ූ", "oo": "ූ",
        "e": "ෙ", "ee": "ේ", "ea": "ේ",
        "o": "ො", "oa": "ෝ",
        "au": "ෞ"
    ]
    
    func transliterate(text: String) -> String {
        var result = ""
        var i = 0
        let chars = Array(text.lowercased())
        let n = chars.count
        
        var isAfterVowel = false
        var isStartOrSpace = true
        
        while i < n {
            if chars[i] == " " {
                result += " "
                i += 1
                isStartOrSpace = true
                isAfterVowel = false
                continue
            }
            
            // Check for longest possible vowel match at start or after a vowel/space
            if isStartOrSpace || isAfterVowel {
                let (match, len) = findLongestMatch(in: vowels, chars: chars, index: i)
                if len > 0 {
                    result += match
                    i += len
                    isStartOrSpace = false
                    isAfterVowel = true
                    continue
                }
            }
            
            // Check for longest possible consonant match
            let (cMatch, cLen) = findLongestMatch(in: consonants, chars: chars, index: i)
            if cLen > 0 {
                isStartOrSpace = false
                isAfterVowel = false
                // Check if followed by a vowel for modifier
                let (vMatch, vLen) = findLongestMatch(in: vowelModifiers, chars: chars, index: i + cLen)
                
                if vLen > 0 {
                    let baseConsonant = String(cMatch.dropLast())
                    result += baseConsonant + vMatch
                    i += cLen + vLen
                    isAfterVowel = true
                } else {
                    result += cMatch
                    i += cLen
                }
                continue
            }
            
            let (vow, vLen2) = findLongestMatch(in: vowels, chars: chars, index: i)
            if vLen2 > 0 {
                 result += vow
                 i += vLen2
                 isStartOrSpace = false
                 isAfterVowel = true
                 continue
            }
            
            result += String(chars[i])
            i += 1
            isStartOrSpace = false
            isAfterVowel = false
        }
        
        return result
    }
    
    private func findLongestMatch(in dictionary: [String: String], chars: [Character], index: Int) -> (String, Int) {
        var longestMatch = ""
        var matchLen = 0
        var currentStr = ""
        
        for i in 0..<min(4, chars.count - index) {
            currentStr += String(chars[index + i])
            if let val = dictionary[currentStr] {
                longestMatch = val
                matchLen = i + 1
            }
        }
        
        return (longestMatch, matchLen)
    }
}
