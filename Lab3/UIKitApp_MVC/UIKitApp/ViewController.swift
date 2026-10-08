import UIKit

class ViewController: UIViewController {

    let model = CounterModel()
    let counterView = CounterView()

    override func loadView() {
        view = counterView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        counterView.changeButton.addTarget(
            self,
            action: #selector(changeText),
            for: .touchUpInside
        )

        counterView.nextButton.addTarget(
            self,
            action: #selector(openSecondScreen),
            for: .touchUpInside
        )
    }

    @objc func changeText() {
        model.increment()
        counterView.updateCount(model.count)
    }

    @objc func openSecondScreen() {
        let secondVC = SecondViewController()

        navigationController?.pushViewController(
            secondVC,
            animated: true
        )
    }
}
