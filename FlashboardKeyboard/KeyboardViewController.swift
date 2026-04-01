import UIKit

public class KeyboardViewController: UIInputViewController {
    
    // UI Elements
    private var mainStack: UIStackView?
    private var heightConstraint: NSLayoutConstraint?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Instant Background Setup
        self.view.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        // 2. Instant UI Setup (No Delay)
        setupKeyboardUI()
        
        print("KEYBOARD LOADED")
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 3. Perfect Height (High Priority, not Required for better OS flexibility)
        if heightConstraint == nil {
            let h = view.heightAnchor.constraint(equalToConstant: 280)
            h.priority = UILayoutPriority(999) // High but not required
            h.isActive = true
            heightConstraint = h
        }
    }
    
    // MARK: - UI Construction
    
    private func setupKeyboardUI() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        mainStack = stack
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
        
        // Row 1: Sinhala Vowels
        let row1 = createRow(["අ", "ආ", "ඇ", "ඈ", "ඉ", "ඊ", "උ"])
        stack.addArrangedSubview(row1)
        
        // Row 2: Common Consonants
        let row2 = createRow(["ක", "ග", "ච", "ජ", "ට", "ඩ", "ණ"])
        stack.addArrangedSubview(row2)
        
        // Row 3: More Consonants
        let row3 = createRow(["ත", "ද", "න", "ප", "බ", "ම", "ය"])
        stack.addArrangedSubview(row3)
        
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
        
        stack.addArrangedSubview(controlRow)
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
        
        // Shadows are safe and premium
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
