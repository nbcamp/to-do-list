import UIKit

final class ViewController: UIViewController {
    private let helloWorld = {
        let label = UILabel()
        label.text = "Hello, World!"
        label.sizeToFit()
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
    }

    private func initializeUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(helloWorld)
        helloWorld.center = view.center
    }
}
