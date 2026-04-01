import UIKit

public class KeyboardViewController: UIInputViewController {
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Immediate Feedback for iOS
        self.view.backgroundColor = .systemGray6
        
        // Minimal UI to prove it's alive
        let label = UILabel()
        label.text = "FLASHBOARD V4 - READY"
        label.textAlignment = .center
        label.textColor = .systemBlue
        label.font = .boldSystemFont(ofSize: 20)
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Small button to switch back to next keyboard (required for testing)
        let nextBtn = UIButton(type: .system)
        nextBtn.setTitle("Next Keyboard", for: .normal)
        nextBtn.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        view.addSubview(nextBtn)
        nextBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            nextBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

