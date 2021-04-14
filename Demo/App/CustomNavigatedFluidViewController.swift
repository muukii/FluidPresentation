import FluidPresentation
import UIKit

open class CustomNavigatedFluidViewController: NavigatedFluidViewController {

  public init(
    idiom: Idiom = .presentation,
    bodyViewController: UIViewController? = nil,
    displaysUnwindButton: Bool = true
  ) {

    super.init(
      idiom: idiom,
      bodyViewController: bodyViewController
    )

    if displaysUnwindButton {

      let button: UIBarButtonItem

      switch idiom {
      case .navigationPush:
        button = .init(title: "Back", style: .plain, target: nil, action: nil)
      case .presentation:
        button = .init(title: "Dismiss", style: .plain, target: nil, action: nil)
      }

      button.target = self
      button.action = #selector(onTapUnwindButton)

      if let bodyViewController = bodyViewController {
        bodyViewController.navigationItem.leftBarButtonItem = button
      } else {
        navigationItem.leftBarButtonItem = button
      }
    }

  }

  @objc private func onTapUnwindButton() {
    dismiss(animated: true, completion: nil)
  }
}

extension UIViewController {

  public func wrappingNavigatedFluidViewController(
    idiom: FluidViewController.Idiom
  ) -> CustomNavigatedFluidViewController {
    .init(idiom: idiom, bodyViewController: self, displaysUnwindButton: true)
  }

}

