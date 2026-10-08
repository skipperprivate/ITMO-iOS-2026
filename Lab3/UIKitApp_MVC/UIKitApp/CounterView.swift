import UIKit

class CounterView: UIView {

    let label = UILabel()
    let changeButton = UIButton(type: .system)
    let nextButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemGray6

        setupLabel()
        setupButton()
        setupNextButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateCount(_ count: Int) {
        label.text = "Count: \(count)"
    }
    
    func setupLabel() {
        label.text = "Count: 0"
        label.textColor = .black
        label.font = .systemFont(ofSize: 40)

        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50)
        ])
    }

    func setupButton() {
        changeButton.setTitle("Add", for: .normal)

        changeButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(changeButton)

        NSLayoutConstraint.activate([
            changeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            changeButton.topAnchor.constraint(
                equalTo: label.bottomAnchor,
                constant: 30
            )
        ])
    }

    func setupNextButton() {
        nextButton.setTitle("Next page", for: .normal)

        nextButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(nextButton)

        NSLayoutConstraint.activate([
            nextButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            nextButton.topAnchor.constraint(
                equalTo: changeButton.bottomAnchor,
                constant: 20
            )
        ])
    }
}
