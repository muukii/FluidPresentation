//
//  TransitionControllers.swift
//  PresentationViewController
//
//  Created by Muukii on 2021/04/09.
//

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

}

enum DismissingInteractiveTransitionControllers {

  final class LeftToRightTransitionController: NSObject, UIViewControllerInteractiveTransitioning {

    private weak var currentTransitionContext: UIViewControllerContextTransitioning?
    private var currentAnimator: UIViewPropertyAnimator?

    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {

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

      let animator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1) {
        fromView.transform = .init(translationX: fromView.bounds.width, y: 0)
        fromView.alpha = 0
        toView.transform = .identity
        toView.alpha = 1
      }

      animator.addCompletion { position in
        switch position {
        case .current:
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
      currentAnimator?.continueAnimation(
        withTimingParameters: UISpringTimingParameters(
          dampingRatio: 1,
          initialVelocity: .init(dx: velocityX, dy: 0)
        ),
        durationFactor: 0
      )
    }

    func cancelInteractiveTransition() {
      currentAnimator?.isReversed = true
      currentAnimator?.continueAnimation(
        withTimingParameters: UISpringTimingParameters(
          dampingRatio: 1,
          initialVelocity: .zero
        ),
        durationFactor: 2
      )
    }

    func updateProgress(_ progress: CGFloat) {
      currentTransitionContext?.updateInteractiveTransition(progress)
      currentAnimator?.isReversed = false
      currentAnimator?.pauseAnimation()
      currentAnimator?.fractionComplete = progress
    }

  }

}
