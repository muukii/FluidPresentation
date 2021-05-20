//
// Copyright (c) 2021 Copyright (c) 2021 Eureka, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import FluidPresentation
import Foundation
import SwiftUI
import TinyConstraints

final class SampleViewController: FluidViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    count += 1
    title = "\(count)"

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
            controller.setIdiom(.navigationPush(isScreenGestureEnabled: true))
            present(controller, animated: true, completion: nil)
          case .pushNavigationBar:
            let controller = NavigatedFluidViewController(
              idiom: .navigationPush,
              bodyViewController: SampleViewController()
            )
            controller.setIdiom(.navigationPush(isScreenGestureEnabled: true))
            present(controller, animated: true, completion: nil)
          case .pushInCurrentContext:
            let controller = SampleViewController()
            controller.modalPresentationStyle = .currentContext
            controller.setIdiom(.navigationPush(isScreenGestureEnabled: true))
            present(controller, animated: true, completion: nil)
          case .present:
            let controller = SampleViewController()
            controller.setIdiom(.presentation)
            present(controller, animated: true, completion: nil)
          case .presentOverFullScreen:
            let controller = SampleViewController()
            controller.setIdiom(.presentation)
            controller.modalPresentationStyle = .overFullScreen
            present(controller, animated: true, completion: nil)
          case .presentInCurrentContext:
            let controller = SampleViewController()
            controller.modalPresentationStyle = .currentContext
            controller.setIdiom(.presentation)
            present(controller, animated: true, completion: nil)
          case .presentInOverCurrentContext:
            let controller = SampleViewController()
            controller.modalPresentationStyle = .overCurrentContext
            controller.setIdiom(.presentation)
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

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    print("Presented => \(String(describing: presentedViewController))")
    print("Presenting => \(String(describing: presentingViewController))")
  }
}
