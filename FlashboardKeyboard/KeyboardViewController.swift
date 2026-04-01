import UIKit

@objc(KeyboardViewController)
public class KeyboardViewController: UIInputViewController {
    
    private var nextKeyboardButton: UIButton!
    private var heightConstraint: NSLayoutConstraint!
    
    public override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Basic Setup
        self.view.backgroundColor = .systemGray6
        
        // 2. Load the UI after a stable delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.setupSimpleUI()
        }
        
        print("Flashboard: Keyboard Loaded Successfully.")
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure height is stable
        if heightConstraint == nil {
            heightConstraint = view.heightAnchor.constraint(equalToConstant: 260)
            heightConstraint.priority = .required
            heightConstraint.isActive = true
        }
    }
    
    private func setupSimpleUI() {
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.distribution = .fillEqually
        mainStack.spacing = 10
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        ])
        
        // Row 1: A B C
        let row1 = createRow(["A", "B", "C"])
        mainStack.addArrangedSubview(row1)
        
        // Row 2: Space, Delete, Globe
        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.distribution = .fillEqually
        bottomRow.spacing = 8
        
        let globeBtn = createKey(title: "🌐", color: .systemGray2)
        globeBtn.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        bottomRow.addArrangedSubview(globeBtn)
        
        let spaceBtn = createKey(title: "Space", color: .white)
        spaceBtn.addTarget(self, action: #selector(spaceTapped), for: .touchUpInside)
        bottomRow.addArrangedSubview(spaceBtn)
        
        let deleteBtn = createKey(title: "⌫", color: .systemGray2)
        deleteBtn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        bottomRow.addArrangedSubview(deleteBtn)
        
        mainStack.addArrangedSubview(bottomRow)
    }
    
    private func createRow(_ titles: [String]) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        for title in titles {
            let btn = createKey(title: title, color: .white)
            btn.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(btn)
        }
        return stack
    }
    
    private func createKey(title: String, color: UIColor) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.backgroundColor = color
        btn.setTitleColor(.black, for: .normal)
        btn.layer.cornerRadius = 5
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        
        // Shadow for premium look
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 1)
        btn.layer.shadowRadius = 0
        btn.layer.shadowOpacity = 0.3
        
        return btn
    }
    
    @objc private func keyTapped(_ sender: UIButton) {
        if let char = sender.titleLabel?.text {
            textDocumentProxy.insertText(char)
            print("Flashboard: Inserted \(char)")
        }
    }
    
    @objc private func spaceTapped() {
        textDocumentProxy.insertText(" ")
    }
    
    @objc private func deleteTapped() {
        textDocumentProxy.deleteBackward()
    }
}
