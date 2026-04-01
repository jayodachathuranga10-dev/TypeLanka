import UIKit

@objc(InputViewController)
class InputViewController: UIInputViewController {
    
    // UI Elements
    private var mainStack: UIStackView!
    private var heightConstraint: NSLayoutConstraint!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        // Load UI after a safe system handshake delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.setupKeyboardUI()
        }
        
        print("KEYBOARD LOADED ✅")
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Force the keyboard height to be stable at 280px
        if heightConstraint == nil {
            heightConstraint = view.heightAnchor.constraint(equalToConstant: 280)
            heightConstraint.priority = .required
            heightConstraint.isActive = true
        }
    }
    
    // MARK: - UI Construction
    
    private func setupKeyboardUI() {
        mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.distribution = .fillEqually
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
        
        // Row 1: Sinhala Common Vowels
        let row1 = createRow(["අ", "ආ", "ඇ", "ඈ", "ඉ", "ඊ", "උ"])
        mainStack.addArrangedSubview(row1)
        
        // Row 2: Common Consonants
        let row2 = createRow(["ක", "ග", "ච", "ජ", "ට", "ඩ", "ණ"])
        mainStack.addArrangedSubview(row2)
        
        // Row 3: More Consonants
        let row3 = createRow(["ත", "ද", "න", "ප", "බ", "ම", "ය"])
        mainStack.addArrangedSubview(row3)
        
        // Row 4: Controls (Globe, Space, Delete)
        let controlRow = UIStackView()
        controlRow.axis = .horizontal
        controlRow.distribution = .fillProportionally
        controlRow.spacing = 8
        
        let globeBtn = createKey(title: "🌐", color: .systemGray)
        globeBtn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        globeBtn.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        controlRow.addArrangedSubview(globeBtn)
        
        let spaceBtn = createKey(title: "Space", color: .white)
        spaceBtn.addTarget(self, action: #selector(didTapSpace), for: .touchUpInside)
        controlRow.addArrangedSubview(spaceBtn)
        
        let deleteBtn = createKey(title: "⌫", color: .systemGray)
        deleteBtn.widthAnchor.constraint(equalToConstant: 60).isActive = true
        deleteBtn.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
        controlRow.addArrangedSubview(deleteBtn)
        
        mainStack.addArrangedSubview(controlRow)
    }
    
    private func createRow(_ characters: [String]) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 6
        for char in characters {
            let btn = createKey(title: char, color: .darkGray)
            btn.setTitleColor(.white, for: .normal)
            btn.addTarget(self, action: #selector(didTapKey(_:)), for: .touchUpInside)
            stack.addArrangedSubview(btn)
        }
        return stack
    }
    
    private func createKey(title: String, color: UIColor) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.backgroundColor = color
        btn.layer.cornerRadius = 6
        btn.titleLabel?.font = .systemFont(ofSize: 22, weight: .regular)
        
        // Shadow (iOS Style)
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        btn.layer.shadowRadius = 0
        btn.layer.shadowOpacity = 0.45
        
        return btn
    }
    
    // MARK: - Actions
    
    @objc private func didTapKey(_ sender: UIButton) {
        if let char = sender.title(for: .normal) {
            textDocumentProxy.insertText(char)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
    
    @objc private func didTapSpace() {
        textDocumentProxy.insertText(" ")
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    @objc private func didTapDelete() {
        textDocumentProxy.deleteBackward()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
