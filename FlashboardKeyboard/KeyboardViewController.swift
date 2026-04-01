import UIKit

public class KeyboardViewController: UIInputViewController, KeyboardViewDelegate {
    
    private var keyboardView: KeyboardView!
    
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
        
        if transliterationEngine.isSinhalaEnabled {
            let result = transliterationEngine.process(character)
            proxy.insertText(result)
            updateSuggestions(for: transliterationEngine.currentWord)
        } else {
            proxy.insertText(character)
        }
    }
    
    public func didTapBackspace() {
        textDocumentProxy.deleteBackward()
        if transliterationEngine.isSinhalaEnabled {
            transliterationEngine.backspace()
            updateSuggestions(for: transliterationEngine.currentWord)
        }
    }
    
    public func didTapSpace() {
        textDocumentProxy.insertText(" ")
        transliterationEngine.resetWord()
        keyboardView.displaySuggestions([])
    }
    
    public func didTapEnter() {
        textDocumentProxy.insertText("\n")
        transliterationEngine.resetWord()
    }
    
    public func didTapShift() {
        // Toggle shift state in UI if needed
    }
    
    public func didTapLanguageSwitch() {
        transliterationEngine.isSinhalaEnabled.toggle()
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
    }
    
    public func didSelectSuggestion(_ word: String) {
        let proxy = textDocumentProxy
        // Remove current partial word
        for _ in 0..<transliterationEngine.currentWord.count {
            proxy.deleteBackward()
        }
        proxy.insertText(word + " ")
        transliterationEngine.resetWord()
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
        guard !word.isEmpty else {
            keyboardView.displaySuggestions([])
            return
        }
        let suggestions = suggestionEngine.getSuggestions(for: word)
        keyboardView.displaySuggestions(suggestions)
    }
}
