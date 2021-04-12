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

private final class DropShadowContainerView: UIView {

  override func layoutSubviews() {

    super.layoutSubviews()

    layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    layer.shadowColor = UIColor.init(white: 0, alpha: 0.2).cgColor
    layer.shadowRadius = 2
    layer.shadowOffset = .zero
    layer.shadowOpacity = 1

  }

}

private func resorationHierarchy(view: UIView) -> () -> Void {

  guard let superview = view.superview else {
    return {}
  }

  guard let index = superview.subviews.firstIndex(of: view) else {
    return {}
  }

  return { [weak superview, weak view] in
    guard let superview = superview, let view = view else { return }
    superview.insertSubview(view, at: index)
  }
}

private struct ViewProperties {

  var alpha: CGFloat
  var transform: CGAffineTransform

  init(
    from view: UIView
  ) {
    self.alpha = view.alpha
    self.transform = view.transform
  }

  func restore(in view: UIView) {
    view.alpha = alpha
    view.transform = transform
  }

}

enum PresentingTransitionControllers {

  final class BottomToTopTransitionController: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
      0
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

      let toView = transitionContext.view(forKey: .to)!

      transitionContext.containerView.addSubview(toView)

      toView.transform = .init(translationX: 0, y: toView.bounds.height)

      let animator = UIViewPropertyAnimator(duration: 0.55, dampingRatio: 1) {
        toView.transform = .identity
      }

      animator.addCompletion { _ in
        transitionContext.completeTransition(true)
      }

      animator.startAnimation()

    }

  }

  final class RightToLeftTransitionController: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
      0
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

      let toView = transitionContext.viewController(forKey: .to)!.view!
      let fromView = transitionContext.viewController(forKey: .from)!.view!

      transitionContext.containerView.backgroundColor = .white
      transitionContext.containerView.addSubview(fromView)
      transitionContext.containerView.addSubview(toView)

      let fromViewProperties = ViewProperties(from: fromView)

      toView.transform = .init(translationX: toView.bounds.width, y: 0)
      toView.alpha = 0

      let animator = UIViewPropertyAnimator(duration: 0.65, dampingRatio: 1) {
        fromView.transform = .init(translationX: -toView.bounds.width, y: 0)
        fromView.alpha = 0
        toView.transform = .identity
        toView.alpha = 1
      }

      animator.addCompletion { _ in
        fromViewProperties.restore(in: fromView)
        transitionContext.completeTransition(true)
      }

      animator.startAnimation()

    }

  }
}

enum DismissingTransitionControllers {

  final class TopToBottomTransitionController: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
      0
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

      let fromView = transitionContext.viewController(forKey: .from)!.view!
      let toView = transitionContext.viewController(forKey: .to)!.view!

      let restore = resorationHierarchy(view: toView)

      transitionContext.containerView.addSubview(toView)
      transitionContext.containerView.addSubview(fromView)

      let animator = UIViewPropertyAnimator(duration: 0.55, dampingRatio: 1) {
        fromView.transform = .init(translationX: 0, y: fromView.bounds.height)
      }

      animator.addCompletion { _ in
        restore()
        transitionContext.completeTransition(true)
      }

      animator.startAnimation()

    }

  }

  final class LeftToRightTransitionController: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
      0
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

      let fromView = transitionContext.viewController(forKey: .from)!.view!

      let toView = transitionContext.viewController(forKey: .to)!.view!
      let restore = resorationHierarchy(view: toView)

      assert(fromView.bounds.width == transitionContext.containerView.bounds.width)
      assert(toView.bounds.width == transitionContext.containerView.bounds.width)

      transitionContext.containerView.backgroundColor = .white
      transitionContext.containerView.addSubview(toView)
      transitionContext.containerView.addSubview(fromView)

      let toViewProperties = ViewProperties(from: toView)

      makeInitialState: do {
        toView.transform = .init(translationX: -fromView.bounds.width, y: 0)
        toView.alpha = 0
      }

      func cleanup() {
        restore()
        toViewProperties.restore(in: toView)
      }

      let animator = UIViewPropertyAnimator(duration: 0.62, dampingRatio: 1) {
        fromView.transform = .init(translationX: fromView.bounds.width, y: 0)
        fromView.alpha = 0
        toView.transform = .identity
        toView.alpha = 1
      }

      animator.addCompletion { position in
        switch position {
        case .current:
          assertionFailure()
          // TODO: ???
          break
        case .end:
          cleanup()
          transitionContext.completeTransition(true)
        case .start:
          cleanup()
          transitionContext.completeTransition(false)
        @unknown default:
          fatalError()
        }

      }

      animator.startAnimation()

    }

  }

}

enum DismissingInteractiveTransitionControllers {

  final class LeftToRightTransitionController: NSObject, UIViewControllerInteractiveTransitioning {

    private weak var currentTransitionContext: UIViewControllerContextTransitioning?
    private var currentAnimator: UIViewPropertyAnimator?

    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {

      Log.debug(.generic, "Start Interactive Transition")

      self.currentTransitionContext = transitionContext

      let fromView = transitionContext.viewController(forKey: .from)!.view!

      let toView = transitionContext.viewController(forKey: .to)!.view!
      let restore = resorationHierarchy(view: toView)

      assert(fromView.bounds.width == transitionContext.containerView.bounds.width)
      assert(toView.bounds.width == transitionContext.containerView.bounds.width)

      transitionContext.containerView.backgroundColor = .white
      transitionContext.containerView.addSubview(toView)
      transitionContext.containerView.addSubview(fromView)

      let toViewProperties = ViewProperties(from: toView)

      makeInitialState: do {
        toView.transform = .init(translationX: -fromView.bounds.width, y: 0)
        toView.alpha = 0
      }

      func cleanup() {
        restore()
        toViewProperties.restore(in: toView)
      }

      let animator = UIViewPropertyAnimator(duration: 0.62, dampingRatio: 1) {
        fromView.transform = .init(translationX: fromView.bounds.width, y: 0)
        fromView.alpha = 0
        toView.transform = .identity
        toView.alpha = 1
      }

      animator.addCompletion { position in
        switch position {
        case .current:
          assertionFailure()
          // TODO: ???
          break
        case .end:
          cleanup()
          transitionContext.finishInteractiveTransition()
          transitionContext.completeTransition(true)
        case .start:
          cleanup()
          transitionContext.cancelInteractiveTransition()
          transitionContext.completeTransition(false)
        @unknown default:
          fatalError()
        }

      }

      animator.pauseAnimation()

      self.currentAnimator = animator
    }

    func finishInteractiveTransition(velocityX: CGFloat) {
      Log.debug(.generic, "Finish Interactive Transition")

      guard
        let animator = currentAnimator
      else {

        return
      }

      animator.continueAnimation(
        withTimingParameters: UISpringTimingParameters(
          dampingRatio: 1,
          initialVelocity: .init(dx: velocityX, dy: 0)
        ),
        durationFactor: 1
      )
    }

    func cancelInteractiveTransition() {
      Log.debug(.generic, "Cancel Interactive Transition")

      guard
        let animator = currentAnimator
      else {

        return
      }

      animator.isReversed = true
      animator.continueAnimation(
        withTimingParameters: UISpringTimingParameters(
          dampingRatio: 1,
          initialVelocity: .zero
        ),
        durationFactor: 1
      )
    }

    func updateProgress(_ progress: CGFloat) {
//      Log.debug(.generic, "Update progress")

      guard
        let context = currentTransitionContext,
        let animator = currentAnimator
      else {

        return
      }

      context.updateInteractiveTransition(progress)
      animator.isReversed = false
      animator.pauseAnimation()
      animator.fractionComplete = progress
    }

  }

}
