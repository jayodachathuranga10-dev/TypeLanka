import UIKit

protocol KeyboardViewDelegate: AnyObject {
    func didTapKey(character: String)
    func didTapBackspace()
    func didTapSpace()
    func didTapEnter()
    func didTapShift()
    func didTapLanguageSwitch()
    func didTapNumberSwitch()
    func didTapClipboard()
    func didSelectClipboardItem(_ text: String)
    func didSelectSuggestion(_ word: String)
    func didTogglePredictiveBar()
    func didOpenSettings()
}

class KeyboardView: UIView {
    
    weak var delegate: KeyboardViewDelegate?
    private var keysContainer = UIView()
    private var suggestionBar = UIStackView()
    private var isShifted = false
    private var clipboardOverlay = UIView()
    private var clipboardStack = UIStackView()
    private var predictiveToggleButton = UIButton(type: .system)
    
    // Theme Layers
    private var gradientBackgroundLayer: CAGradientLayer?
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var topBarContainer = UIStackView()
    
    private func setupUI() {
        topBarContainer.axis = .horizontal
        topBarContainer.spacing = 6
        
        let langBtn = UIButton(type: .system)
        langBtn.setTitle("SI", for: .normal)
        langBtn.titleLabel?.font = .boldSystemFont(ofSize: 14)
        langBtn.backgroundColor = ThemeManager.shared.activeTheme.specialKeyColor
        langBtn.setTitleColor(.white, for: .normal)
        langBtn.layer.cornerRadius = 18
        
        let emojiBtn = UIButton(type: .system)
        emojiBtn.setTitle("😀", for: .normal)
        emojiBtn.layer.cornerRadius = 18
        emojiBtn.backgroundColor = ThemeManager.shared.activeTheme.specialKeyColor
        
        let fontBtn = UIButton(type: .system)
        fontBtn.setTitle("Aa", for: .normal)
        fontBtn.setTitleColor(.white, for: .normal)
        fontBtn.layer.cornerRadius = 18
        fontBtn.backgroundColor = ThemeManager.shared.activeTheme.specialKeyColor
        
        let settingBtn = UIButton(type: .system)
        settingBtn.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        settingBtn.tintColor = .white
        settingBtn.layer.cornerRadius = 18
        settingBtn.backgroundColor = ThemeManager.shared.activeTheme.specialKeyColor
        settingBtn.addTarget(self, action: #selector(settingsBtnTapped), for: .touchUpInside)

        let clipBtn = UIButton(type: .system)
        clipBtn.setTitle("📋", for: .normal)
        clipBtn.layer.cornerRadius = 18
        clipBtn.backgroundColor = ThemeManager.shared.activeTheme.specialKeyColor
        clipBtn.addTarget(self, action: #selector(clipboardBtnTapped), for: .touchUpInside)
        
        predictiveToggleButton.setTitle("˅", for: .normal)
        predictiveToggleButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        predictiveToggleButton.setTitleColor(.white, for: .normal)
        predictiveToggleButton.layer.cornerRadius = 18
        predictiveToggleButton.layer.borderWidth = 1
        predictiveToggleButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
        predictiveToggleButton.backgroundColor = .clear
        predictiveToggleButton.addTarget(self, action: #selector(predictiveBtnTapped), for: .touchUpInside)
        
        suggestionBar.axis = .horizontal
        suggestionBar.distribution = .fillEqually
        suggestionBar.spacing = 2
        suggestionBar.isHidden = true
        
        let toolsWrapper = UIStackView(arrangedSubviews: [langBtn, emojiBtn, fontBtn, clipBtn, settingBtn, predictiveToggleButton])
        toolsWrapper.axis = .horizontal
        toolsWrapper.spacing = 8
        toolsWrapper.distribution = .fillEqually
        
        topBarContainer.addArrangedSubview(toolsWrapper)
        
        for btn in [langBtn, emojiBtn, fontBtn, settingBtn, clipBtn] {
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.widthAnchor.constraint(equalToConstant: 36).isActive = true
            btn.heightAnchor.constraint(equalToConstant: 36).isActive = true
        }
        
        addSubview(topBarContainer)
        topBarContainer.alignment = .center
        topBarContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topBarContainer.topAnchor.constraint(equalTo: topAnchor),
            topBarContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            topBarContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            topBarContainer.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        addSubview(keysContainer)
        keysContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            keysContainer.topAnchor.constraint(equalTo: topBarContainer.bottomAnchor),
            keysContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            keysContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            keysContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        updateTheme()
        setupKeys()
        setupClipboardOverlay()
    }
    
    private func setupClipboardOverlay() {
        addSubview(clipboardOverlay)
        clipboardOverlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clipboardOverlay.topAnchor.constraint(equalTo: topAnchor),
            clipboardOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            clipboardOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            clipboardOverlay.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Needs a blur or solid background
        clipboardOverlay.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        clipboardOverlay.isHidden = true
        
        let header = UIView()
        let backBtn = UIButton(type: .system)
        backBtn.setTitle("←", for: .normal)
        backBtn.titleLabel?.font = .boldSystemFont(ofSize: 20)
        backBtn.setTitleColor(.white, for: .normal)
        backBtn.addTarget(self, action: #selector(hideClipboard), for: .touchUpInside)
        
        let titleLabel = UILabel()
        titleLabel.text = "Clips"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 16)
        
        header.addSubview(backBtn)
        header.addSubview(titleLabel)
        
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        header.translatesAutoresizingMaskIntoConstraints = false
        clipboardOverlay.addSubview(header)
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: clipboardOverlay.topAnchor),
            header.leadingAnchor.constraint(equalTo: clipboardOverlay.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: clipboardOverlay.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 44),
            
            backBtn.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 10),
            backBtn.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            backBtn.widthAnchor.constraint(equalToConstant: 44),
            backBtn.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor)
        ])
        
        let scrollView = UIScrollView()
        clipboardStack.axis = .vertical
        clipboardStack.spacing = 10
        
        scrollView.addSubview(clipboardStack)
        clipboardOverlay.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        clipboardStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: clipboardOverlay.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: clipboardOverlay.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: clipboardOverlay.bottomAnchor),
            
            clipboardStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            clipboardStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 15),
            clipboardStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -15),
            clipboardStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -10),
            clipboardStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -30)
        ])
    }
    
    func showClipboard(items: [ClipItem]) {
        keysContainer.isHidden = true
        topBarContainer.isHidden = true
        clipboardOverlay.isHidden = false
        
        clipboardStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if items.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "Your clipboard is empty.\nOnce you copy a piece of text, it will appear here."
            emptyLabel.textColor = .lightGray
            emptyLabel.numberOfLines = 0
            emptyLabel.textAlignment = .center
            emptyLabel.font = .systemFont(ofSize: 14)
            clipboardStack.addArrangedSubview(emptyLabel)
            return
        }
        
        for item in items {
            let container = UIView()
            container.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
            if item.isPinned {
                container.layer.borderWidth = 1
                container.layer.borderColor = UIColor.systemYellow.cgColor
            }
            container.layer.cornerRadius = 8
            
            let btn = UIButton(type: .system)
            btn.setTitle(item.text, for: .normal)
            btn.titleLabel?.numberOfLines = 2
            btn.contentHorizontalAlignment = .left
            btn.titleLabel?.font = .systemFont(ofSize: 15)
            btn.setTitleColor(.white, for: .normal)
            btn.addTarget(self, action: #selector(clipItemTapped(_:)), for: .touchUpInside)
            
            container.addSubview(btn)
            btn.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                btn.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
                btn.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
                btn.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
                btn.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10)
            ])
            
            clipboardStack.addArrangedSubview(container)
        }
    }
    
    @objc private func clipboardBtnTapped() {
        delegate?.didTapClipboard()
    }
    
    @objc func hideClipboard() {
        clipboardOverlay.isHidden = true
        keysContainer.isHidden = false
        topBarContainer.isHidden = false
    }
    
    @objc private func clipItemTapped(_ sender: UIButton) {
        if let text = sender.titleLabel?.text {
            delegate?.didSelectClipboardItem(text)
        }
    }
    
    @objc private func predictiveBtnTapped() { delegate?.didTogglePredictiveBar() }
    @objc private func settingsBtnTapped() { delegate?.didOpenSettings() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientBackgroundLayer?.frame = self.bounds
    }
    
    func updateTheme() {
        let theme = ThemeManager.shared.activeTheme
        
        if let bgColors = theme.backgroundGradient {
            if gradientBackgroundLayer == nil {
                let gradient = CAGradientLayer()
                self.layer.insertSublayer(gradient, at: 0)
                gradientBackgroundLayer = gradient
            }
            gradientBackgroundLayer?.colors = bgColors.map({ $0.cgColor })
            self.backgroundColor = .clear
        } else {
            gradientBackgroundLayer?.removeFromSuperlayer()
            gradientBackgroundLayer = nil
            self.backgroundColor = theme.backgroundColor
        }
        
        suggestionBar.backgroundColor = .clear
    }
    
    func displaySuggestions(_ words: [String]) {
        suggestionBar.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for word in words {
            let btn = UIButton(type: .system)
            btn.setTitle(word, for: .normal)
            btn.setTitleColor(ThemeManager.shared.activeTheme.keyTextColor, for: .normal)
            btn.addTarget(self, action: #selector(suggestionTapped(_:)), for: .touchUpInside)
            suggestionBar.addArrangedSubview(btn)
        }
    }
    
    @objc private func suggestionTapped(_ sender: UIButton) {
        if let word = sender.titleLabel?.text {
            delegate?.didSelectSuggestion(word)
        }
    }
    
    private func setupKeys() {
        let rows: [[(String, String?)]] = [
            [("q","1"), ("w","2"), ("e","3"), ("r","4"), ("t","5"), ("y","6"), ("u","7"), ("i","8"), ("o","9"), ("p","0")],
            [("a","@"), ("s","#"), ("d","$"), ("f","-"), ("g","&"), ("h","-"), ("j","+"), ("k","("), ("l",")")],
            [("⇧",nil), ("z","*"), ("x","\""), ("c","'"), ("v",":"), ("b",";"), ("n","!"), ("m","?"), ("⌫",nil)],
            [("123",nil), ("🌐",nil), (",",nil), ("TypeLanka",nil), (".",nil), ("enter",nil)]
        ]
        var verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.distribution = .fillEqually
        verticalStack.spacing = 8
        keysContainer.addSubview(verticalStack)
        
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: keysContainer.topAnchor, constant: 8),
            verticalStack.leadingAnchor.constraint(equalTo: keysContainer.leadingAnchor, constant: 4),
            verticalStack.trailingAnchor.constraint(equalTo: keysContainer.trailingAnchor, constant: -4),
            verticalStack.bottomAnchor.constraint(equalTo: keysContainer.bottomAnchor, constant: -8)
        ])
        
        for row in rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillProportionally
            rowStack.spacing = 6
            for keyData in row {
                let btn = UIButton(type: .system)
                btn.setTitle(keyData.0 == "TypeLanka" ? " " : keyData.0, for: .normal)
                btn.titleLabel?.font = .systemFont(ofSize: 22)
                btn.layer.cornerRadius = 6
                btn.backgroundColor = ThemeManager.shared.activeTheme.keyColor
                btn.setTitleColor(ThemeManager.shared.activeTheme.keyTextColor, for: .normal)
                
                // Shadow & modern inner border simulation
                btn.layer.shadowColor = ThemeManager.shared.activeTheme.keyShadowColor.cgColor
                btn.layer.shadowOffset = CGSize(width: 0, height: 1)
                btn.layer.shadowOpacity = 1.0
                btn.layer.shadowRadius = 0
                btn.layer.borderColor = ThemeManager.shared.activeTheme.keyInnerBorderColor.cgColor
                btn.layer.borderWidth = 0.5
                
                if keyData.0 == "enter" {
                    btn.backgroundColor = ThemeManager.shared.activeTheme.primaryActionColor
                    btn.setTitleColor(.white, for: .normal)
                    let img = UIImage(systemName: "return")
                    btn.setImage(img, for: .normal)
                    btn.setTitle("", for: .normal)
                    btn.tintColor = .white
                } else if keyData.0 == "⇧" {
                    let img = UIImage(systemName: "shift")
                    btn.setImage(img, for: .normal)
                    btn.setTitle("", for: .normal)
                    btn.tintColor = ThemeManager.shared.activeTheme.keyTextColor
                    btn.backgroundColor = ThemeManager.shared.activeTheme.specialKeyColor
                } else if keyData.0 == "⌫" {
                    let img = UIImage(systemName: "delete.left")
                    btn.setImage(img, for: .normal)
                    btn.setTitle("", for: .normal)
                    btn.tintColor = ThemeManager.shared.activeTheme.keyTextColor
                    btn.backgroundColor = ThemeManager.shared.activeTheme.specialKeyColor
                } else if ["123", "🌐"].contains(keyData.0) {
                    btn.backgroundColor = ThemeManager.shared.activeTheme.specialKeyColor
                    btn.titleLabel?.font = .systemFont(ofSize: 16)
                }
                
                // Spacebar text
                if keyData.0 == "TypeLanka" {
                    let lbl = UILabel()
                    lbl.text = "TypeLanka"
                    lbl.textColor = ThemeManager.shared.activeTheme.subHintTextColor
                    lbl.font = .systemFont(ofSize: 15, weight: .medium)
                    lbl.translatesAutoresizingMaskIntoConstraints = false
                    btn.addSubview(lbl)
                    lbl.centerXAnchor.constraint(equalTo: btn.centerXAnchor).isActive = true
                    lbl.centerYAnchor.constraint(equalTo: btn.centerYAnchor).isActive = true
                }
                
                // Subhint label
                if let hint = keyData.1 {
                    let hintLbl = UILabel()
                    hintLbl.text = hint
                    hintLbl.textColor = ThemeManager.shared.activeTheme.subHintTextColor
                    hintLbl.font = .systemFont(ofSize: 10, weight: .medium)
                    hintLbl.translatesAutoresizingMaskIntoConstraints = false
                    btn.addSubview(hintLbl)
                    NSLayoutConstraint.activate([
                        hintLbl.topAnchor.constraint(equalTo: btn.topAnchor, constant: 3),
                        hintLbl.trailingAnchor.constraint(equalTo: btn.trailingAnchor, constant: -4)
                    ])
                }
                
                btn.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
                // Need to pass data safely, we will extract title or sub-hint based on action later. 
                // Because UIButton's accessibilityIdentifier can store the exact character for us reliably:
                btn.accessibilityIdentifier = keyData.0
                
                rowStack.addArrangedSubview(btn)
            }
            verticalStack.addArrangedSubview(rowStack)
        }
    }
    
    @objc private func keyTapped(_ sender: UIButton) {
        guard let title = sender.accessibilityIdentifier else { return }
        switch title {
        case "⌫": delegate?.didTapBackspace()
        case "TypeLanka": delegate?.didTapSpace()
        case "enter": delegate?.didTapEnter()
        case "⇧": delegate?.didTapShift()
        case "🌐": delegate?.didTapLanguageSwitch()
        case "123": delegate?.didTapNumberSwitch()
        default: delegate?.didTapKey(character: title)
        }
    }
}
