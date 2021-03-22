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

    public init(trigger: PresentationViewController.Behavior.Trigger, startFrom: PresentationViewController.Behavior.StartFrom) {
      self.trigger = trigger
      self.startFrom = startFrom
    }
    
  }
  
  public let behaviors: Set<Behavior>
  
  private var isTracking = false
  
  init(behaviors: Set<Behavior> = []) {
    self.behaviors = behaviors
    super.init(nibName: nil, bundle: nil)
    setUp()
  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError()
  }
  
  private var currentInteractiveTransitionController: _SwipeDismissalTransitionController?
  
  private func setUp() {
    
    modalPresentationStyle = .overCurrentContext
    transitioningDelegate = self
                
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
    view.addGestureRecognizer(panGesture)
    panGesture.delegate = self
    
    let edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePanGesture))
    view.addGestureRecognizer(edgeGesture)
    edgeGesture.delegate = self
    
    do {
      
      behaviors
        .filter {
          $0.trigger == .edge
        }
        .forEach {
          switch $0.startFrom {
          case .top:
            edgeGesture.edges.formUnion(.top)
          case .left:
            edgeGesture.edges.formUnion(.left)
          case .right:
            edgeGesture.edges.formUnion(.right)
          case .bottom:
            edgeGesture.edges.formUnion(.bottom)
          }
        }
      
    }
  }
  
  @objc
  private func handleEdgePanGesture(_ gesture: UIPanGestureRecognizer) {
    
//    guard isTracking == false else {
//      return
//    }

  }
  
  @objc
  private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        
    switch gesture.state {
    case .began:
            
      currentInteractiveTransitionController = .init()
      dismiss(animated: true, completion: nil)
      
    case .changed:
      
      let t = view.transform
      view.transform = .identity
      let position = gesture.location(in: gesture.view)
      view.transform = t
      
      let progress = position.x / view.bounds.width
      
      print(position, progress)
      currentInteractiveTransitionController?.updateProgress(progress)
      
      break
    case .possible:
      break
    case .ended:
      currentInteractiveTransitionController?.finishInteractiveTransition()

    case .cancelled:
      currentInteractiveTransitionController?.cancelInteractiveTransition()
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
  
  func finishInteractiveTransition() {
    currentAnimator?.continueAnimation(withTimingParameters: nil, durationFactor: 0)
    currentTransitionContext?.finishInteractiveTransition()
  }
  
  func cancelInteractiveTransition() {
    currentAnimator?.isReversed = true
    currentAnimator?.continueAnimation(withTimingParameters: nil, durationFactor: 0)
    currentTransitionContext?.cancelInteractiveTransition()
  }
  
  func updateProgress(_ progress: CGFloat) {
    currentAnimator?.fractionComplete = progress
  }
    
}
