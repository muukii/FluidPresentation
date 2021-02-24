//
//  ViewController.swift
//  PresentationViewController
//
//  Created by Muukii on 2021/02/02.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  @IBAction func onTap(_ sender: Any) {
    
    let controller = SampleViewController()
    
    present(controller, animated: true, completion: nil)
    
  }
  
}

final class SampleViewController: PresentationViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .blue
  }
}

open class PresentationViewController: UIViewController, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {
  
  init() {
    super.init(nibName: nil, bundle: nil)
    setUp()
  }
  
  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    setUp()
  }
  
  private var currentInteractiveTransitionController: _SwipeDismissalTransitionController?
  
  private func setUp() {
    
    modalPresentationStyle = .currentContext
    transitioningDelegate = self
    
    let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePanGesture))
        
    gesture.edges = .left
    view.addGestureRecognizer(gesture)
    gesture.delegate = self
  }
  
  @objc
  private func handleEdgePanGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
    
    switch gesture.state {
    case .began:
      currentInteractiveTransitionController = .init()
      dismiss(animated: true, completion: nil)
    case .changed:
      break
    case .possible:
      break
    case .ended:
      break
    case .cancelled:
      break
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
    _PresentationTransitionController()
  }
  
  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    _PresentationTransitionController()
  }
      
  public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    
    currentInteractiveTransitionController
  }
}

final class _PresentationTransitionController: NSObject, UIViewControllerAnimatedTransitioning {
  
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

final class _DismissalTransitionController: NSObject, UIViewControllerAnimatedTransitioning {
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    0.23
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    let fromView = transitionContext.view(forKey: .from)!
                
    let animator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 1) {
      fromView.transform = .init(translationX: 0, y: fromView.bounds.height)
    }
    
    animator.addCompletion { _ in
      transitionContext.completeTransition(true)
      fromView.transform = .identity
    }
    
    animator.startAnimation()
    
  }
  
}

final class _SwipeDismissalTransitionController: NSObject, UIViewControllerInteractiveTransitioning {
  
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
        transitionContext.completeTransition(true)
      case .start:
        transitionContext.completeTransition(false)
      @unknown default:
        fatalError()
      }

    }
    
    animator.pauseAnimation()
    
    self.currentAnimator = animator
  }
  
  func cancel() {
    currentTransitionContext?.cancelInteractiveTransition()
    
  }
    
}
