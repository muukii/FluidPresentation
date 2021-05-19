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

import UIKit

extension FluidViewController {

  public var fluidContext: FluidPresentationContext {
    .init(presentedViewController: self)
  }

}

public struct FluidPresentationContext {

  public let presentedViewController: FluidViewController

  init(presentedViewController: FluidViewController) {
    self.presentedViewController = presentedViewController
  }

}

extension FluidPresentationContext {

  /**
   Presents this view controller in the view controller as contextually.
   The presenting view controller must be a presentation context.
   Make sure the view controller is the presentation context with `UIViewController.definesPresentationContext`.
   */
  public func present(
    in presentingViewController: UIViewController,
    animated: Bool,
    completion: (() -> Void)?
  ) {

    assert(
      presentingViewController.definesPresentationContext == true,
      """
      The presenting view controller \(presentingViewController) does not define PresentationContext.
      Make sure \(presentingViewController).definesPresentationContext returns `true`.
      """
    )

    presentedViewController.modalPresentationStyle = presentedViewController.wantsTransparentBackground ? .overCurrentContext : .currentContext

    presentingViewController
      .present(
        presentedViewController,
        animated: animated,
        completion: completion
      )

  }

  /**
   Presents this view controller as full screen.
   Technically, `modalPresentationStyle` would be set `.overFullScreen` or `fullScreen`.
   Which would be used depends on `wantsTransparentBackground`

   How's finding the presenting view controller.
   - a child view controller forwards calling `present` to the parent view controller.
   */
  public func present(
    from presentingViewController: UIViewController,
    animated: Bool,
    completion: (() -> Void)?
  ) {

    presentedViewController.modalPresentationStyle = presentedViewController.wantsTransparentBackground ? .overFullScreen : .fullScreen

    presentingViewController
      .present(
        presentedViewController,
        animated: animated,
        completion: completion
      )

  }
}
