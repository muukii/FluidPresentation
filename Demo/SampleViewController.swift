//
//  SampleViewController.swift
//  Demo
//
//  Created by Muukii on 2021/04/10.
//

import FluidPresentation
import Foundation
import SwiftUI
import TinyConstraints

final class SampleViewController: FluidViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    count += 1

    accessibilityLabel = count.description
    view.accessibilityIdentifier = count.description

    let hosting = UIHostingController(
      rootView: ContentView(
        onAction: { [unowned self] action in
          switch action {
          case .dismiss:
            self.dismiss(animated: true, completion: nil)
          case .push:
            let controller = SampleViewController()
            controller.dismissingInteractions = [.init(trigger: .any, startFrom: .left)]
            controller.presentingTransition = .slideIn(from: .right)
            present(controller, animated: true, completion: nil)
          case .pushInCurrentContext:
            let controller = SampleViewController()
            controller.dismissingInteractions = [.init(trigger: .any, startFrom: .left)]
            controller.presentingTransition = .slideIn(from: .right)
            controller.modalPresentationStyle = .currentContext
            present(controller, animated: true, completion: nil)
          case .present:
            let controller = SampleViewController()
            controller.dismissingInteractions = [.init(trigger: .any, startFrom: .left)]
            present(controller, animated: true, completion: nil)
          case .presentInCurrentContext:
            let controller = SampleViewController()
            controller.dismissingInteractions = [.init(trigger: .any, startFrom: .left)]
            controller.modalPresentationStyle = .currentContext
            present(controller, animated: true, completion: nil)
          case .makePresentationContext(let isOn):
            self.definesPresentationContext = isOn
          }
        }
      )
    )

    addChild(hosting)
    view.addSubview(hosting.view)
    hosting.view.edgesToSuperview()
  }
}
