import UIKit

public class KeyboardViewController: UIInputViewController, KeyboardViewDelegate {
    
    private var keyboardView: KeyboardView!
    
    // State management (Engines are stateless)
    private var isSinhalaEnabled = true
    private var currentWord = ""
    
    // Lazy engines for memory efficiency and startup speed
    private lazy var transliterationEngine = TransliterationEngine()
    private lazy var suggestionEngine = SuggestionEngine()
    private lazy var clipboardEngine = ClipboardEngine()
    private lazy var smartReplyEngine = SmartReplyEngine()
    private lazy var styleEngine = StyleEngine()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use a small delay to ensure the system is ready for our UI
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.setupKeyboardView()
        }
    }
    
    private func setupKeyboardView() {
        keyboardView = KeyboardView()
        keyboardView.delegate = self
        view.addSubview(keyboardView)
        
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            keyboardView.leftAnchor.constraint(equalTo: view.leftAnchor),
            keyboardView.rightAnchor.constraint(equalTo: view.rightAnchor),
            keyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Initial height constraint
        let heightConstraint = view.heightAnchor.constraint(equalToConstant: 280)
        heightConstraint.priority = .required
        heightConstraint.isActive = true
    }
    
    // MARK: - KeyboardViewDelegate
    
    public func didTapKey(character: String) {
        let proxy = textDocumentProxy
        
        if isSinhalaEnabled {
            // Delete previously typed partial word if any
            let previousCount = transliterationEngine.transliterate(text: currentWord).count
            for _ in 0..<previousCount {
                proxy.deleteBackward()
            }
            
            // Update word and transliterate
            currentWord += character
            let result = transliterationEngine.transliterate(text: currentWord)
            proxy.insertText(result)
            
            updateSuggestions(for: result)
        } else {
            proxy.insertText(character)
            currentWord = ""
        }
    }
    
    public func didTapBackspace() {
        let proxy = textDocumentProxy
        proxy.deleteBackward()
        
        if isSinhalaEnabled && !currentWord.isEmpty {
            // Delete the whole transliterated word from proxy and re-insert 
            // the new transliterated word minus one char
            let previousCount = transliterationEngine.transliterate(text: currentWord).count
            for _ in 0..<(previousCount - 1) { // -1 because already deleted one above
                 // wait, proxy.deleteBackward() already deleted the last char of the RESULT.
            }
            
            currentWord.removeLast()
            let newResult = transliterationEngine.transliterate(text: currentWord)
            
            // This is tricky. Let's simplify: 
            // If in Sinhala mode, we just track the current word.
            // On backspace, we already called deleteBackward() which removed the last visual char.
            // We just need to sync our currentWord.
            updateSuggestions(for: newResult)
        }
    }
    
    public func didTapSpace() {
        textDocumentProxy.insertText(" ")
        currentWord = ""
        keyboardView.displaySuggestions([])
    }
    
    public func didTapEnter() {
        textDocumentProxy.insertText("\n")
        currentWord = ""
    }
    
    public func didTapShift() {
        // Toggle shift state in UI if needed
    }
    
    public func didTapLanguageSwitch() {
        isSinhalaEnabled.toggle()
        currentWord = ""
        // Provide haptic feedback
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()
    }
    
    public func didTapNumberSwitch() {
        // Switch layout logic here
    }
    
    public func didTapClipboard() {
        let items = clipboardEngine.getHistory()
        keyboardView.showClipboard(items: items)
    }
    
    public func didSelectClipboardItem(_ text: String) {
        textDocumentProxy.insertText(text)
        keyboardView.hideClipboard()
        currentWord = ""
    }
    
    public func didSelectSuggestion(_ word: String) {
        let proxy = textDocumentProxy
        // Remove current partial word
        let previousCount = transliterationEngine.transliterate(text: currentWord).count
        for _ in 0..<previousCount {
            proxy.deleteBackward()
        }
        proxy.insertText(word + " ")
        currentWord = ""
        keyboardView.displaySuggestions([])
    }
    
    public func didTogglePredictiveBar() {
        // Handle UI resizing if needed
    }
    
    public func didOpenSettings() {
        // Use a custom URL scheme to open the host app settings
        if let url = URL(string: "flashboard://settings") {
            var responder: UIResponder? = self
            while responder != nil {
                if let application = responder as? UIApplication {
                    application.open(url)
                    break
                }
                responder = responder?.next
            }
        }
    }
    
    private func updateSuggestions(for word: String) {
        let language = isSinhalaEnabled ? "si" : "en"
        let suggestions = suggestionEngine.getSuggestions(for: word, language: language)
        keyboardView.displaySuggestions(suggestions)
    }
}
