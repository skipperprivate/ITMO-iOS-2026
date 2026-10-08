import UIKit

class ViewController: UIViewController {

    var counter = 0

    let label = UILabel()
    let changeButton = UIButton(type: .system)
    let nextButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGray6

        setupLabel()
        setupButton()
        setupNextButton()
    }

    func setupLabel() {
        label.text = "Count: 0"
        label.textColor = .black
        label.font = .systemFont(ofSize: 40)

        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: -50
            )
        ])
    }

    func setupButton() {
        changeButton.setTitle("Add", for: .normal)

        changeButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(changeButton)

        changeButton.addTarget(
            self,
            action: #selector(changeText),
            for: .touchUpInside
        )

        NSLayoutConstraint.activate([
            changeButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            changeButton.topAnchor.constraint(
                equalTo: label.bottomAnchor,
                constant: 30
            )
        ])
    }

    func setupNextButton() {
        nextButton.setTitle("Next page", for: .normal)

        nextButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nextButton)

        nextButton.addTarget(
            self,
            action: #selector(openSecondScreen),
            for: .touchUpInside
        )

        NSLayoutConstraint.activate([
            nextButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            nextButton.topAnchor.constraint(
                equalTo: changeButton.bottomAnchor,
                constant: 20
            )
        ])
    }

    @objc func changeText() {
        counter += 1
        label.text = "Count: \(counter)"
    }

    @objc func openSecondScreen() {
        let secondVC = SecondViewController()

        navigationController?.pushViewController(
            secondVC,
            animated: true
        )
    }
}
