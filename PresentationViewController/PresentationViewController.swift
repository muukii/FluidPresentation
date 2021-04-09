//
// Copyright (c) 2021 Hiroshi Kimura(Muukii) <muukii.app@gmail.com>
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

open class PresentationViewController: UIViewController, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {

  public struct Behavior: Hashable {

    public enum Trigger: Hashable {
      case edge
      case any
    }

    public enum StartFrom: Hashable {
      case left
      case right
      case top
      case bottom
    }

    public let trigger: Trigger
    public let startFrom: StartFrom

    public init(
      trigger: PresentationViewController.Behavior.Trigger,
      startFrom: PresentationViewController.Behavior.StartFrom
    ) {
      self.trigger = trigger
      self.startFrom = startFrom
    }

  }

  private var leftToRightTrackingContext: LeftToRightTrackingContext?

  public let behaviors: Set<Behavior>

  private var isTracking = false

  init(
    behaviors: Set<Behavior> = []
  ) {
    self.behaviors = behaviors
    super.init(nibName: nil, bundle: nil)
    setUp()
  }

  @available(*, unavailable)
  public required init?(
    coder: NSCoder
  ) {
    fatalError()
  }

  private func setUp() {

    modalPresentationStyle = .overCurrentContext
    transitioningDelegate = self

    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
    view.addGestureRecognizer(panGesture)
    panGesture.delegate = self

    do {

      behaviors
        .filter {
          $0.trigger == .edge
        }
        .forEach {
          switch $0.startFrom {
          case .top:
            break
          case .left:

            let edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeLeftPanGesture))
            edgeGesture.edges = .left
            view.addGestureRecognizer(edgeGesture)
            edgeGesture.delegate = self

          case .right:
            break
          case .bottom:
            break
          }
        }

    }
  }

  @objc
  private func handleEdgeLeftPanGesture(_ gesture: UIPanGestureRecognizer) {

  }

  @objc
  private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {

    switch gesture.state {
    case .possible:
      break
    case .began:

      if isBeingDismissed {

      } else {

        leftToRightTrackingContext = .init(
          viewFrame: view.bounds,
          beganPoint: gesture.location(in: view),
          controller: .init()
        )

        dismiss(animated: true, completion: nil)

      }

    case .changed:
      leftToRightTrackingContext?.handleChanged(gesture: gesture)
    case .ended:
      leftToRightTrackingContext?.handleEnded(gesture: gesture)
    case .cancelled:
      leftToRightTrackingContext?.handleCancel(gesture: gesture)
    case .failed:
      break
    @unknown default:
      break
    }

  }

  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    PresentingTransitionControllers.BottomToTopTransitionController()
  }

  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    if let controller = leftToRightTrackingContext?.controller {
      return controller
    }
    return nil
  }

  public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    if let controller = leftToRightTrackingContext?.controller {
      return controller
    }
    return nil
  }
}

extension PresentationViewController {

  private final class LeftToRightTrackingContext {

    typealias TransitionController = DismissingTransitionControllers.LeftToRightTransitionController

    let viewFrame: CGRect
    let beganPoint: CGPoint
    let controller: TransitionController

    init(
      viewFrame: CGRect,
      beganPoint: CGPoint,
      controller: TransitionController
    ) {
      self.viewFrame = viewFrame
      self.beganPoint = beganPoint
      self.controller = controller
    }

    func handleChanged(gesture: UIPanGestureRecognizer) {
      let progress = calulateProgress(gesture: gesture)
      controller.updateProgress(progress)
    }

    func handleEnded(gesture: UIPanGestureRecognizer) {

      let progress = calulateProgress(gesture: gesture)
      let velocity = gesture.velocity(in: gesture.view)

      if progress > 0.5 || velocity.x > 300 {
        controller.finishInteractiveTransition(velocityX: normalizedVelocity(gesture: gesture))
      } else {
        controller.cancelInteractiveTransition()
      }

    }

    func handleCancel(gesture: UIPanGestureRecognizer) {
      controller.cancelInteractiveTransition()
    }

    private func normalizedVelocity(gesture: UIPanGestureRecognizer) -> CGFloat {
      let velocityX = gesture.velocity(in: gesture.view).x
      return velocityX / viewFrame.width
    }

    private func calulateProgress(gesture: UIPanGestureRecognizer) -> CGFloat {
      let targetView = gesture.view!
      let t = targetView.transform
      targetView.transform = .identity
      let position = gesture.location(in: targetView)
      targetView.transform = t

      let progress = (position.x - beganPoint.x) / viewFrame.width
      return progress
    }
  }

}
