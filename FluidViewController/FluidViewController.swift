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

open class FluidViewController: UIViewController, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {

  /**
   - Warning: Under constructions
   */
  public struct PresentingTransition: Hashable {

    public enum SlideInFrom: Hashable {
      case right
      case bottom
    }

    public enum Animation: Hashable {
      case slideIn(SlideInFrom)
    }

    let animation: Animation

    public static func slideIn(from: SlideInFrom) -> Self {
      return .init(animation: .slideIn(from))
    }

  }

  /**
   - Warning: Under constructions
   */
  public struct DismissingIntereaction: Hashable {

    public enum Trigger: Hashable {
      case edge
      case any
    }

    public enum StartFrom: Hashable {
      case left
      //      case right
      //      case top
      //      case bottom
    }

    public let trigger: Trigger
    public let startFrom: StartFrom

    public init(
      trigger: FluidViewController.DismissingIntereaction.Trigger,
      startFrom: FluidViewController.DismissingIntereaction.StartFrom
    ) {
      self.trigger = trigger
      self.startFrom = startFrom
    }

  }

  private var leftToRightTrackingContext: LeftToRightTrackingContext?

  public let behaviors: Set<DismissingIntereaction>

  private var isTracking = false

  private var isValidGestureDismissal: Bool {
    modalPresentationStyle != .pageSheet
  }

  private let scrollController = ScrollController()

  public init(
    behaviors: Set<DismissingIntereaction> = [.init(trigger: .any, startFrom: .left)]
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

  public var presentingTransition: PresentingTransition = .slideIn(from: .bottom)
  public var dismissingInteractions: Set<DismissingIntereaction> = []

  private func setUp() {

    modalPresentationStyle = .fullScreen
    transitioningDelegate = self

    do {
      if behaviors.filter({ $0.trigger == .any }).isEmpty == false {
        let panGesture = _PanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        view.addGestureRecognizer(panGesture)
        panGesture.delegate = self
      }
    }

    do {

      behaviors
        .filter {
          $0.trigger == .edge
        }
        .forEach {
          switch $0.startFrom {
          case .left:
            let edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeLeftPanGesture))
            edgeGesture.edges = .left
            view.addGestureRecognizer(edgeGesture)
            edgeGesture.delegate = self
          }
        }

    }
  }

  @objc
  private func handleEdgeLeftPanGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {

    switch gesture.state {
    case .possible:
      break
    case .began:

      if leftToRightTrackingContext == nil {
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
      leftToRightTrackingContext = nil
    case .cancelled:
      leftToRightTrackingContext?.handleCancel(gesture: gesture)
      leftToRightTrackingContext = nil
    case .failed:
      break
    @unknown default:
      break
    }

  }

  @objc
  private func handlePanGesture(_ gesture: _PanGestureRecognizer) {

    switch gesture.state {
    case .possible:
      break
    case .began:

      break

    case .changed:

      if leftToRightTrackingContext == nil {

        if abs(gesture.translation(in: view).y) > 20 {
          gesture.state = .failed
          return
        }

        if gesture.translation(in: view).x < -5 {
          gesture.state = .failed
          return
        }

        if gesture.translation(in: view).x > 20 {

          if let scrollView = gesture.trackingScrollView {

            let representation = ScrollViewRepresentation(from: scrollView)

            if representation.isReachedToEdge(.left) {

              scrollController.startTracking(scrollView: scrollView)

            } else {
              gesture.state = .failed
              return
            }

          }

          leftToRightTrackingContext = .init(
            viewFrame: view.bounds,
            beganPoint: gesture.location(in: view),
            controller: .init()
          )

          scrollController.lockScrolling()
          dismiss(animated: true, completion: nil)
        }
      }

      if isBeingDismissed {
        leftToRightTrackingContext?.handleChanged(gesture: gesture)
      }
    case .ended:
      scrollController.unlockScrolling()
      scrollController.endTracking()
      leftToRightTrackingContext?.handleEnded(gesture: gesture)
      leftToRightTrackingContext = nil
    case .cancelled, .failed:
      scrollController.unlockScrolling()
      scrollController.endTracking()
      leftToRightTrackingContext?.handleCancel(gesture: gesture)
      leftToRightTrackingContext = nil
    @unknown default:
      break
    }

  }

  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

    switch presentingTransition.animation {
    case .slideIn(let from):
      switch from {
      case .bottom:
        return PresentingTransitionControllers.BottomToTopTransitionController()
      case .right:
        return PresentingTransitionControllers.RightToLeftTransitionController()
      }
    }

  }

  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

    Log.debug(.generic, "Start Dismiss")

    return DismissingTransitionControllers.TopToBottomTransitionController()
  }

  public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    if let controller = leftToRightTrackingContext?.controller {
      Log.debug(.generic, "Start Interactive Dismiss")
      return controller
    }
    return nil
  }
}

extension FluidViewController {

  private final class LeftToRightTrackingContext {

    typealias TransitionController = DismissingInteractiveTransitionControllers.LeftToRightTransitionController

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

final class _PanGestureRecognizer: UIPanGestureRecognizer {

  weak var trackingScrollView: UIScrollView?

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    trackingScrollView = event.findScrollView()
    super.touchesBegan(touches, with: event)
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {

    super.touchesMoved(touches, with: event)
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesEnded(touches, with: event)
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesCancelled(touches, with: event)
  }

}

extension UIEvent {

  fileprivate func findScrollView() -> UIScrollView? {

    guard
      let firstTouch = allTouches?.first,
      let targetView = firstTouch.view
    else { return nil }

    let scrollView = sequence(first: targetView, next: \.next).map { $0 }
      .first {
        guard let scrollView = $0 as? UIScrollView else {
          return false
        }

        func isScrollable(scrollView: UIScrollView) -> Bool {

          let contentInset: UIEdgeInsets

          if #available(iOS 11.0, *) {
            contentInset = scrollView.adjustedContentInset
          } else {
            contentInset = scrollView.contentInset
          }

          return (scrollView.bounds.width - (contentInset.right + contentInset.left) <= scrollView.contentSize.width) || (scrollView.bounds.height - (contentInset.top + contentInset.bottom) <= scrollView.contentSize.height)
        }

        return isScrollable(scrollView: scrollView)
      }

    return (scrollView as? UIScrollView)
  }

}
