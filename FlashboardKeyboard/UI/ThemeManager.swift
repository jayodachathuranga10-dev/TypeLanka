import UIKit

struct Theme {
    let id: String
    let name: String
    
    // Core Layout Colors
    let backgroundColor: UIColor?
    let backgroundGradient: [UIColor]?
    
    // Key Colors
    let keyColor: UIColor
    let specialKeyColor: UIColor
    let keyTextColor: UIColor
    let subHintTextColor: UIColor
    
    // Visual Polish
    let keyShadowColor: UIColor
    let keyInnerBorderColor: UIColor
    let primaryActionColor: UIColor
}

class ThemeManager {
    static let shared = ThemeManager()
    
    private let themeKey = "TypeLankaActiveThemeID"
    
    private let sharedDefaults = UserDefaults(suiteName: "group.com.flash.lanka")
    
    var activeTheme: Theme {
        let id = sharedDefaults?.string(forKey: themeKey) ?? "dark"
        return themes.first { $0.id == id } ?? themes[1] // Default to Dark
    }
    
    func setActiveTheme(id: String) {
        sharedDefaults?.set(id, forKey: themeKey)
        NotificationCenter.default.post(name: NSNotification.Name("ThemeDidUpdate"), object: nil)
    }
    
    let themes: [Theme] = [
        // 1. Light Mode (Default iOS)
        Theme(id: "light", name: "Classic Light", 
              backgroundColor: UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0), backgroundGradient: nil,
              keyColor: .white, specialKeyColor: UIColor(white: 0.75, alpha: 1.0),
              keyTextColor: .black, subHintTextColor: .systemGray,
              keyShadowColor: UIColor(white: 0.0, alpha: 0.3), keyInnerBorderColor: UIColor(white: 1.0, alpha: 1.0), primaryActionColor: .systemBlue),
        
        // 2. Dark Mode (Default iOS)
        Theme(id: "dark", name: "Classic Dark", 
              backgroundColor: UIColor(red: 0.08, green: 0.08, blue: 0.09, alpha: 1.0), backgroundGradient: nil,
              keyColor: UIColor(white: 0.2, alpha: 1.0), specialKeyColor: UIColor(white: 0.15, alpha: 1.0),
              keyTextColor: .white, subHintTextColor: .lightGray,
              keyShadowColor: UIColor(white: 0.0, alpha: 0.8), keyInnerBorderColor: UIColor(white: 1.0, alpha: 0.05), primaryActionColor: .systemBlue),
        
        // 3. OLED Black
        Theme(id: "oled", name: "OLED Pitch Black", 
              backgroundColor: .black, backgroundGradient: nil,
              keyColor: UIColor(white: 0.1, alpha: 1.0), specialKeyColor: UIColor(white: 0.05, alpha: 1.0),
              keyTextColor: .white, subHintTextColor: .darkGray,
              keyShadowColor: .clear, keyInnerBorderColor: UIColor(white: 0.2, alpha: 1.0), primaryActionColor: .cyan),
        
        // 4. Cyberpunk
        Theme(id: "cyberpunk", name: "Cyberpunk Neon", 
              backgroundColor: UIColor(red: 0.04, green: 0.01, blue: 0.1, alpha: 1.0), 
              backgroundGradient: [UIColor(red: 0.04, green: 0.01, blue: 0.1, alpha: 1), UIColor(red: 0.1, green: 0.0, blue: 0.1, alpha: 1)],
              keyColor: UIColor(red: 0.12, green: 0, blue: 0.25, alpha: 1.0), specialKeyColor: UIColor(red: 0.08, green: 0, blue: 0.2, alpha: 1.0),
              keyTextColor: UIColor(red: 0.0, green: 1.0, blue: 0.9, alpha: 1.0), subHintTextColor: UIColor(red: 1.0, green: 0.0, blue: 0.5, alpha: 1.0),
              keyShadowColor: UIColor(red: 0, green: 1, blue: 0.9, alpha: 0.4), keyInnerBorderColor: .clear, primaryActionColor: .systemPink),
        
        // 5. Matrix Green
        Theme(id: "matrix", name: "The Matrix", 
              backgroundColor: .black, backgroundGradient: nil,
              keyColor: UIColor(red: 0, green: 0.1, blue: 0, alpha: 1.0), specialKeyColor: UIColor(red: 0, green: 0.05, blue: 0, alpha: 1.0),
              keyTextColor: UIColor(red: 0, green: 1.0, blue: 0, alpha: 1.0), subHintTextColor: UIColor(red: 0, green: 0.5, blue: 0, alpha: 1.0),
              keyShadowColor: UIColor(red: 0, green: 1.0, blue: 0, alpha: 0.3), keyInnerBorderColor: .clear, primaryActionColor: .green),
              
        // 6. Sunset Gradient
        Theme(id: "sunset", name: "LA Sunset", 
              backgroundColor: nil, 
              backgroundGradient: [UIColor(red: 1.0, green: 0.4, blue: 0, alpha: 1), UIColor(red: 0.9, green: 0.1, blue: 0.5, alpha: 1)],
              keyColor: UIColor(white: 1.0, alpha: 0.2), specialKeyColor: UIColor(white: 1.0, alpha: 0.1),
              keyTextColor: .white, subHintTextColor: UIColor(white: 1.0, alpha: 0.5),
              keyShadowColor: .clear, keyInnerBorderColor: UIColor(white: 1.0, alpha: 0.2), primaryActionColor: .systemOrange),
              
        // 7. Lavender
        Theme(id: "lavender", name: "Lavender Dream", 
              backgroundColor: UIColor(red: 0.9, green: 0.85, blue: 0.95, alpha: 1.0), backgroundGradient: nil,
              keyColor: .white, specialKeyColor: UIColor(red: 0.85, green: 0.75, blue: 0.9, alpha: 1.0),
              keyTextColor: UIColor(red: 0.3, green: 0.1, blue: 0.5, alpha: 1.0), subHintTextColor: UIColor(red: 0.5, green: 0.3, blue: 0.7, alpha: 1.0),
              keyShadowColor: UIColor(white: 0.0, alpha: 0.1), keyInnerBorderColor: .white, primaryActionColor: .systemPurple)
    ]
}
