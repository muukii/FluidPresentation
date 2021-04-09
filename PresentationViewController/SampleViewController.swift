//
//  SampleViewController.swift
//  Demo
//
//  Created by Muukii on 2021/04/10.
//

import FluidViewController
import Foundation
import SwiftUI
import TinyConstraints

final class SampleViewController: FluidViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let hosting = UIHostingController(
      rootView: ContentView(
        onTapDismiss: { [unowned self] in
          self.dismiss(animated: true, completion: nil)
        },
        onTapPush: { [unowned self] in
          let controller = SampleViewController(behaviors: [.init(trigger: .any, startFrom: .left)])
          present(controller, animated: true, completion: nil)
        },
        onTapPresent: { [unowned self] in
          let controller = SampleViewController(behaviors: [.init(trigger: .any, startFrom: .left)])
          present(controller, animated: true, completion: nil)
        }
      )
    )

    addChild(hosting)
    view.addSubview(hosting.view)
    hosting.view.edgesToSuperview()
  }
}
