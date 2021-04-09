//
//  TransitionControllers.swift
//  PresentationViewController
//
//  Created by Muukii on 2021/04/09.
//

import UIKit

enum PresentingTransitionControllers {

  final class BottomToTopTransitionController: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
      0.23
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

      let toView = transitionContext.view(forKey: .to)!

      transitionContext.containerView.addSubview(toView)

      toView.transform = .init(translationX: 0, y: toView.bounds.height)

      let animator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 1) {
        toView.transform = .identity
      }

      animator.addCompletion { _ in
        transitionContext.completeTransition(true)
      }

      animator.startAnimation()

    }

  }

}

enum DismissingTransitionControllers {

  final class LeftToRightTransitionController: NSObject, UIViewControllerInteractiveTransitioning, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
      0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
      fatalError()
    }

    private weak var currentTransitionContext: UIViewControllerContextTransitioning?
    private var currentAnimator: UIViewPropertyAnimator?

    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {

      self.currentTransitionContext = transitionContext

      let fromView = transitionContext.view(forKey: .from)!

      let animator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1) {
        fromView.transform = .init(translationX: fromView.bounds.width, y: 0)
      }

      animator.addCompletion { position in
        switch position {
        case .current:
          // TODO: ???
          break
        case .end:
          transitionContext.finishInteractiveTransition()
          transitionContext.completeTransition(true)
        case .start:
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
      currentAnimator?.isReversed = false
      currentAnimator?.pauseAnimation()
      currentAnimator?.fractionComplete = progress
    }

  }

  final class RightToLeftTransitionController: NSObject, UIViewControllerInteractiveTransitioning, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
      0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
      fatalError()
    }

    private weak var currentTransitionContext: UIViewControllerContextTransitioning?
    private var currentAnimator: UIViewPropertyAnimator?

    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {

      self.currentTransitionContext = transitionContext

      let fromView = transitionContext.view(forKey: .from)!

      let animator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1) {
        fromView.transform = .init(translationX: -fromView.bounds.width, y: 0)
      }

      animator.addCompletion { position in
        switch position {
        case .current:
          // TODO: ???
          break
        case .end:
          transitionContext.finishInteractiveTransition()
          transitionContext.completeTransition(true)
        case .start:
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
      currentAnimator?.isReversed = false
      currentAnimator?.pauseAnimation()
      currentAnimator?.fractionComplete = progress
    }

  }


}
