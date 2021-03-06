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

open class FluidViewController: UIViewController, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {

  /// Indicating the transition how it animates.
  public enum Idiom {
    case presentation
    case navigationPush(isScreenGestureEnabled: Bool)

    public static var navigationPush: Self {
      .navigationPush(isScreenGestureEnabled: false)
    }
  }

  /**
   - Warning: Under constructions
   */
  public enum PresentingTransition {

    public enum SlideInFrom: Hashable {
      case right
      case bottom
    }

    case slideIn(from: SlideInFrom)
    case custom(using: () -> UIViewControllerAnimatedTransitioning)

  }

  /**
   - Warning: Under constructions
   */
  public enum DismissingTransition {

    public enum SlideOutTo: Hashable {
      case right
      case bottom
    }

    case slideOut(to: SlideOutTo)
    case custom(using: () -> UIViewControllerAnimatedTransitioning)
  }

  /**
   - Warning: Under constructions
   */
  public struct DismissingIntereaction: Hashable {

    public enum Trigger: Hashable {

      /// Available dismissing gesture in the edge of the screen.
      case edge

      /// Available dismissing gesture in screen anywhere.
      case screen
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

  // MARK: - Properties

  public var wantsTransparentBackground: Bool = false

  public override var childForStatusBarStyle: UIViewController? {
    return bodyViewController
  }

  public override var childForStatusBarHidden: UIViewController? {
    return bodyViewController
  }

  public let bodyViewController: UIViewController?

  @available(*, unavailable, message: "Unsupported")
  open override var navigationController: UINavigationController? {
    super.navigationController
  }

  private var leftToRightTrackingContext: LeftToRightTrackingContext?

  private var isTracking = false

  private var isValidGestureDismissal: Bool {
    modalPresentationStyle != .pageSheet
  }

  private let scrollController = ScrollController()

  public var presentingTransition: PresentingTransition = .slideIn(from: .bottom)
  public var dismissingTransition: DismissingTransition = .slideOut(to: .bottom)

  public var dismissingInteractions: Set<DismissingIntereaction> = [] {
    didSet {
      if isViewLoaded {
        setupGestures()
      }
    }
  }

  public var interactiveUnwindGestureRecognizer: UIPanGestureRecognizer?

  public var interactiveEdgeUnwindGestureRecognizer: UIScreenEdgePanGestureRecognizer?

  private var registeredGestures: [UIGestureRecognizer] = []

  // MARK: - Initializers

  /// Creates an instance
  ///
  /// - Parameters:
  ///   - idiom:
  ///   - bodyViewController: a view controller that displays as a child view controller. It helps a case of can't create a subclass of FluidViewController.
  public init(
    idiom: Idiom? = nil,
    bodyViewController: UIViewController? = nil
  ) {
    self.bodyViewController = bodyViewController
    super.init(nibName: nil, bundle: nil)
    setIdiom(idiom ?? .presentation)

    modalPresentationStyle = .fullScreen
    transitioningDelegate = self
    modalPresentationCapturesStatusBarAppearance = true
  }

  @available(*, unavailable)
  public required init?(
    coder: NSCoder
  ) {
    fatalError()
  }

  // MARK: - Functions

  open override func viewDidLoad() {
    super.viewDidLoad()

    setupGestures()

    if let bodyViewController = bodyViewController {
      addChild(bodyViewController)
      view.addSubview(bodyViewController.view)
      NSLayoutConstraint.activate([
        bodyViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
        bodyViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
        bodyViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
        bodyViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      ])
      bodyViewController.didMove(toParent: self)
    }
  }

  /// Set presenting and dismissing transition according to the idiom
  /// - Parameter idiom: 
  public func setIdiom(_ idiom: Idiom) {

    switch idiom {
    case .presentation:
      self.presentingTransition = .slideIn(from: .bottom)
      self.dismissingTransition = .slideOut(to: .bottom)
      self.dismissingInteractions = []
    case .navigationPush(let isScreenGestureEnabled):
      self.presentingTransition = .slideIn(from: .right)
      self.dismissingTransition = .slideOut(to: .right)

      if isScreenGestureEnabled {
        self.dismissingInteractions = [.init(trigger: .screen, startFrom: .left)]
      } else {
        self.dismissingInteractions = [.init(trigger: .edge, startFrom: .left)]
      }

    }

  }

  private func setupGestures() {

    if leftToRightTrackingContext != nil {
      assertionFailure("Unable to set gestures up while transitioning.")
      return
    }

    registeredGestures.forEach {
      view.removeGestureRecognizer($0)
    }
    registeredGestures = []

    do {
      if dismissingInteractions.filter({ $0.trigger == .screen }).isEmpty == false {
        let panGesture = _PanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        view.addGestureRecognizer(panGesture)
        panGesture.delegate = self
        self.interactiveUnwindGestureRecognizer = panGesture

        registeredGestures.append(panGesture)
      }
    }

    do {

      dismissingInteractions
        .filter {
          $0.trigger == .edge
        }
        .forEach {
          switch $0.startFrom {
          case .left:
            let edgeGesture = _EdgePanGestureRecognizer(target: self, action: #selector(handleEdgeLeftPanGesture))
            edgeGesture.edges = .left
            view.addGestureRecognizer(edgeGesture)
            edgeGesture.delegate = self
            self.interactiveEdgeUnwindGestureRecognizer = edgeGesture
            registeredGestures.append(edgeGesture)

          }
        }

    }
  }

  @objc
  private func handleEdgeLeftPanGesture(_ gesture: _EdgePanGestureRecognizer) {

    guard parent == nil else { return }

    switch gesture.state {
    case .possible:
      break
    case .began:

      if leftToRightTrackingContext == nil {

        if let scrollView = gesture.trackingScrollView {

          scrollController.startTracking(scrollView: scrollView)
          scrollController.lockScrolling()
        }

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

  @objc
  private func handlePanGesture(_ gesture: _PanGestureRecognizer) {

    guard parent == nil else { return }

    switch gesture.state {
    case .possible:
      break
    case .began:

      break

    case .changed:

      if leftToRightTrackingContext == nil {

        if abs(gesture.translation(in: view).y) > 5 {
          gesture.state = .failed
          return
        }

        if gesture.translation(in: view).x < -5 {
          gesture.state = .failed
          return
        }

        if gesture.translation(in: view).x > 0 {

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
          dismiss(animated: true, completion: {
            /// Transition was completed or cancelled.
            self.leftToRightTrackingContext = nil
          })
        }
      }

      if isBeingDismissed {
        leftToRightTrackingContext?.handleChanged(gesture: gesture)
      }
    case .ended:
      scrollController.unlockScrolling()
      scrollController.endTracking()
      leftToRightTrackingContext?.handleEnded(gesture: gesture)
    case .cancelled, .failed:
      scrollController.unlockScrolling()
      scrollController.endTracking()
      leftToRightTrackingContext?.handleCancel(gesture: gesture)
    @unknown default:
      break
    }

  }

  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

    if gestureRecognizer is UIScreenEdgePanGestureRecognizer {

      return (otherGestureRecognizer is UIScreenEdgePanGestureRecognizer) == false
    }

    return true
  }

  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

    switch modalPresentationStyle {
    case .fullScreen, .currentContext, .overFullScreen, .overCurrentContext:
      switch presentingTransition {
      case .custom(let transitionController):
        return transitionController()
      case .slideIn(let from):
        switch from {
        case .bottom:
          return PresentingTransitionControllers.BottomToTopTransitionController()
        case .right:
          return PresentingTransitionControllers.RightToLeftTransitionController()
        }
      }
    case .pageSheet, .formSheet, .custom, .popover, .none, .automatic:
      return nil
    @unknown default:
      return nil
    }

  }

  public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

    switch modalPresentationStyle {
    case .fullScreen, .currentContext, .overFullScreen, .overCurrentContext:
      switch presentingTransition {
      case .custom:
        return nil
      case .slideIn(let from):
        switch from {
        case .bottom:
          return PresentingTransitionControllers.BottomToTopTransitionController()
        case .right:
          return PresentingTransitionControllers.RightToLeftTransitionController()
        }
      }
    case .pageSheet, .formSheet, .custom, .popover, .none, .automatic:
      return nil
    @unknown default:
      return nil
    }

  }

  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

    switch modalPresentationStyle {
    case .fullScreen, .currentContext, .overFullScreen, .overCurrentContext:
      switch dismissingTransition {
      case .custom(let transitionController):
        return transitionController()
      case .slideOut(let to):
        switch to {
        case .bottom:
          return DismissingTransitionControllers.TopToBottomTransitionController()
        case .right:
          return DismissingTransitionControllers.LeftToRightTransitionController()
        }
      }
    case .pageSheet, .formSheet, .custom, .popover, .none, .automatic:
      return nil
    @unknown default:
      return nil
    }

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

final class _EdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer {

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
