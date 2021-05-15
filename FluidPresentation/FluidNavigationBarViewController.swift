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

import Foundation
import UIKit

/// A extended view controller from FluidViewController.
/// Witch has a standalone UINavigationBar that displays navigationItem from itself or bodyViewController.
open class NavigatedFluidViewController: FluidViewController, UINavigationBarDelegate {

  public let navigationBar: UINavigationBar

  public init(
    idiom: Idiom = .presentation,
    bodyViewController: UIViewController? = nil,
    unwindBarButtonItem: UIBarButtonItem? = nil,
    navigationBarClass: UINavigationBar.Type = UINavigationBar.self
  ) {
    self.navigationBar = navigationBarClass.init()
    super.init(idiom: idiom, bodyViewController: bodyViewController)

    let _unwindBarButtonItem = unwindBarButtonItem ?? {
      let button: UIBarButtonItem

      switch idiom {
      case .navigationPush:
        button = .init(barButtonSystemItem: .init(rawValue: 101)!, target: nil, action: nil)
      case .presentation:
        button = .init(title: "Dismiss", style: .plain, target: nil, action: nil)
      }
      return button
    }()

    _unwindBarButtonItem.target = self
    _unwindBarButtonItem.action = #selector(_onTapUnwindButton)

    if let bodyViewController = bodyViewController {
      bodyViewController.navigationItem.leftBarButtonItem = _unwindBarButtonItem
    } else {
      navigationItem.leftBarButtonItem = _unwindBarButtonItem
    }
  }

  open override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(navigationBar)

    navigationBar.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      navigationBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor),
      navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
    ])

    navigationBar.delegate = self

    if let bodyViewController = bodyViewController {
      navigationBar.pushItem(bodyViewController.navigationItem, animated: false)
    } else {
      navigationBar.pushItem(navigationItem, animated: false)
    }

  }

  @objc private func _onTapUnwindButton() {
    dismiss(animated: true, completion: nil)
  }

  open override func viewDidLayoutSubviews() {
    additionalSafeAreaInsets.top = navigationBar.frame.height
    view.bringSubviewToFront(navigationBar)
  }

  public func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
}
