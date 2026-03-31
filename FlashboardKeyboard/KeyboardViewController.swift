import UIKit

class KeyboardViewController: UIInputViewController, KeyboardViewDelegate {
    
    var customKeyboardView: KeyboardView!
    
    let transliterationEngine = TransliterationEngine()
    let suggestionEngine = SuggestionEngine()
    let smartReplyEngine = SmartReplyEngine()
    let clipboardEngine = ClipboardEngine()
    
    var isSinhalaMode = true
    var currentWord = ""
    var isPredictiveToolbarVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customKeyboardView = KeyboardView()
        customKeyboardView.delegate = self
        view.addSubview(customKeyboardView)
        
        customKeyboardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customKeyboardView.leftAnchor.constraint(equalTo: view.leftAnchor),
            customKeyboardView.rightAnchor.constraint(equalTo: view.rightAnchor),
            customKeyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            customKeyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        updateSuggestions()

    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // We override iOS's light/dark mode if the user sets an explicit theme in our Settings
        // However, if they have "Auto", we could sync it here.
        customKeyboardView.updateTheme()
        
        if currentWord.isEmpty {
            if let context = textDocumentProxy.documentContextBeforeInput,
               let replies = smartReplyEngine.generateReplies(context: context) {
                customKeyboardView.displaySuggestions(replies)
                return
            }

        }
    }
    
    func didTapKey(character: String) {
        currentWord += character
        if isSinhalaMode {
            let transliterated = transliterationEngine.transliterate(text: currentWord)
            customKeyboardView.displaySuggestions([transliterated] + suggestionEngine.getSuggestions(for: currentWord, language: "si"))
        } else {
            customKeyboardView.displaySuggestions(suggestionEngine.getSuggestions(for: currentWord, language: "en"))
        }
    }
    
    func didTapBackspace() {
        if !currentWord.isEmpty {
            currentWord.removeLast()
            updateSuggestions()
        } else {
            textDocumentProxy.deleteBackward()
        }
    }
    
    func didTapSpace() {
        commitCurrentWord()
        textDocumentProxy.insertText(" ")
    }
    
    func didTapEnter() {
        commitCurrentWord()
        textDocumentProxy.insertText("\n")
    }
    
    func didTapShift() {
        // Shift logic not fully implemented for space/simplicity
    }
    
    func didTapLanguageSwitch() {
        isSinhalaMode.toggle()
        updateSuggestions()
    }
    
    func didTapNumberSwitch() {
        // Number layout not fully implemented
    }
    
    func didTapClipboard() {
        // Fetch new item if exists
        clipboardEngine.pullFromSystemClipboard()
        // Display full history in overlay
        let history = clipboardEngine.getHistory()
        customKeyboardView.showClipboard(items: history)
    }
    
    func didSelectClipboardItem(_ text: String) {
        textDocumentProxy.insertText(text)
        customKeyboardView.hideClipboard()
    }
    
    func didSelectSuggestion(_ word: String) {
        suggestionEngine.recordWord(word: word)
        textDocumentProxy.insertText(word)
        textDocumentProxy.insertText(" ")
        currentWord = ""
        updateSuggestions()
    }
    
    private func updateSuggestions() {
        if isSinhalaMode && !currentWord.isEmpty {
            let transliterated = transliterationEngine.transliterate(text: currentWord)
            customKeyboardView.displaySuggestions([transliterated])
        } else {
            customKeyboardView.displaySuggestions([])
        }
    }
    
    private func commitCurrentWord() {
        if !currentWord.isEmpty {
            let finalWord = isSinhalaMode ? transliterationEngine.transliterate(text: currentWord) : currentWord
            suggestionEngine.recordWord(word: finalWord)
            textDocumentProxy.insertText(finalWord)
            currentWord = ""
            updateSuggestions()
        }
    }
    
    // MARK: - New Delegate Methods
    
    func didOpenSettings() {
        // Cycle active themes for testing directly from the keyboard view without needing a host app
        let themes = ThemeManager.shared.themes
        let currentID = ThemeManager.shared.activeTheme.id
        let currentIndex = themes.firstIndex(where: { $0.id == currentID }) ?? 1
        let nextIndex = (currentIndex + 1) % themes.count
        
        ThemeManager.shared.setActiveTheme(id: themes[nextIndex].id)
        customKeyboardView.updateTheme()
        customKeyboardView.setNeedsLayout()
    }
    
    func didTogglePredictiveBar() {
        // In a complete implementation, this would animate a height constraint.
        isPredictiveToolbarVisible.toggle()
        if isPredictiveToolbarVisible {
            updateSuggestions()
        } else {
            customKeyboardView.displaySuggestions([])
        }
    }
}
