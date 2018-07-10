//
//  PTPopupViewController.swift
//  Path
//
//  Created by dewey on 2018. 6. 22..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit

enum PTPopupViewHideContext: Int {
    case unknown
    case scrolling
    case tapGesture
    case fromManager
}

enum PTPopupViewState: Int {
    case unknown
    case onHideAndShowAnimation
    case onShowAnimation
    case onHideAnimation
    case showedPopup
    case closed
}

protocol PTPopupViewShareDelegate: class {
    func popupViewStateShare(state: PTPopupViewState)
}

let PTPopupViewControllerBGAlpha: CGFloat = 0.8
typealias PTPopupViewAnimationCompletionBlock = () -> Void

class PTPopupViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var delegate: PTPopupViewShareDelegate?
    
    var _state:PTPopupViewState = .unknown
    var state: PTPopupViewState {
        get {
            return _state
        }
        set (newState){
            _state = newState
            self.delegate?.popupViewStateShare(state: newState)
        }
    }
    
    var newPopupView: UIView?
    var currentPopupView: UIView?
    
    let PTPopupAnimationBaseDuration = 0.4
    let PTPopupAnimationOverShoot: CGFloat = 10.0
    let PTAnimationMaximumRotationDegrees: CGFloat = 8.0;
    let PTAnimationMinimumRotationDegrees: CGFloat = 2.0;
    
    var gestureStartTouchPositionX: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initScrollView()
    }
    
    deinit {
        print("PTPopupViewController deinit check")
    }
    
    func initScrollView() {
        let screenSize = UIScreen.main.bounds.size
        self.scrollView.contentSize = CGSize(width: screenSize.width, height: screenSize.height * 2)
        self.scrollView.isPagingEnabled = true
        self.scrollView.delegate = self
        
        if #available(iOS 11, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewWasTapeed(_:)))
        self.scrollView.addGestureRecognizer(tapRecognizer)
    }
    
    func close() {
        self.dismiss(animated: false) {
            self.state = .closed
        }
    }
    
    public func showPopupView(_ popupView: UIView, animated: Bool) {
        self.newPopupView = popupView
        
        if self.currentPopupView != nil {
            self.prepareHidePopupView()
            self.startHidePopupAnimation(nil)
            
            self.state = .onHideAndShowAnimation
        } else {
            self.state = .onShowAnimation
        }
        
        self.prepareShowPopupView()
        self.startShowPopupAnimation(nil)
    }
    
    public func hidePopupView(animated: Bool, hideContext: PTPopupViewHideContext) {
        self.state = .onHideAnimation
        
        if animated == true {
            self.prepareHidePopupView()
            self.startHidePopupAnimation {
                self.close()
            }
        } else {
            self.close()
        }
    }
    
    @objc func viewWasTapeed(_ sender: UITapGestureRecognizer) {
        self.gestureStartTouchPositionX = sender.location(in: self.view).x
        self.hidePopupView(animated: true, hideContext: .tapGesture)
    }
    
    func prepareShowPopupView() {
        guard let popupView = self.newPopupView else {
            print("\(#function): popupView is nil")
            return
        }
        
        // init PopupView Origin
        self.view.addSubview(popupView)
        popupView.frame = self.initialPopupViewFrameForShowAnimation(popupView)
    }
    
    func prepareHidePopupView() {
        guard let currentPopupView = self.currentPopupView else {
            print("\(#function): currentPopupView is nil")
            return
        }
        
        let rect = self.scrollView.convert(currentPopupView.frame, to: self.view)
        
        if currentPopupView.superview != nil {
            currentPopupView.removeFromSuperview()
        }
        self.view.addSubview(currentPopupView)
        currentPopupView.frame = rect
    }
    
    func startShowPopupAnimation(_ completion: PTPopupViewAnimationCompletionBlock?) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        guard let popupView = self.newPopupView else {
            print("\(#function): newPopupView is nil")
            return
        }
        
        let initialRect = self.initialPopupViewFrameForShowAnimation(popupView)
        let finalRect = self.finalPopupViewFrameForShowAnimation(popupView)
        
        popupView.layer.addAnimation(self.createPopupViewYRotationAnimation(rect: initialRect, targetRect: finalRect), forKey: nil, startBlock: nil, finishBlock: nil)
        popupView.layer.addAnimation(self.createPopupViewZRotationAnimation(view: popupView), forKey: nil, startBlock: nil) { (finished) in
            self.endShowPopupAnimation(popupView)
            completion?()
        }
    }
    
    func startHidePopupAnimation(_ completion: PTPopupViewAnimationCompletionBlock?) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        guard let popupView = self.currentPopupView else {
            print("\(#function): currentPopupView is nil")
            return
        }
        
        let initialRect = self.initialPopupViewFrameForHideAnimation(popupView)
        let finalRect = self.finalPopupViewFrameForHideAnimation(popupView)
        
        popupView.layer.addAnimation(self.createPopupViewYRotationAnimation(rect: initialRect, targetRect: finalRect), forKey: nil, startBlock: nil, finishBlock: nil)
        popupView.layer.addAnimation(self.createPopupViewZRotationAnimation(view: popupView), forKey: nil, startBlock: nil) { (finished) in
            self.endHidePopupViewAnimation(popupView)
            completion?()
        }
        
        if case .onHideAnimation = self.state {
            UIView.animate(withDuration: PTPopupAnimationBaseDuration) {
                self.view.backgroundColor = self.backgroundColor(alpha: 0.0)
            }
        }
    }
    
    func endShowPopupAnimation(_ popupView: UIView) {
        self.state = .showedPopup
        
        // self.view -> scrollView
        self.scrollView.addSubview(popupView)
        self.scrollView.scrollRectToVisible(self.scrollViewBottomPageFrame(), animated: false)
        popupView.frame = self.popupViewFrameForScrollView(popupView)

        // remove Animation
        popupView.layer.removeAllAnimations()
        
        //
        self.currentPopupView = self.newPopupView
        self.newPopupView = nil
        
        // end Ignore Touch Event
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func endHidePopupViewAnimation(_ popupView: UIView) {
        // remove from superView
        popupView.removeFromSuperview()
        popupView.layer.removeAllAnimations()
        
        // end Ignore Touch Event
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}

// MARK:- Animation Assitance
extension PTPopupViewController {
    func createPopupViewYRotationAnimation(rect: CGRect, targetRect: CGRect) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation.init(keyPath: "position.y")
        animation.duration = PTPopupAnimationBaseDuration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.values = [rect.midY, targetRect.midY + PTPopupAnimationOverShoot,  targetRect.midY]
        animation.keyTimes = [0.0, 0.75, 1.0]
        animation.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut),
                                     CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut),
                                     CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)]
        
        return animation
    }
    
    func createPopupViewZRotationAnimation(view: UIView) -> CAKeyframeAnimation {
        let rotationAngle = self.gestureStartTouchPositionX < self.view.frame.width * 0.5 ? 1.0 : -1.0
        
        let animation = CAKeyframeAnimation.init(keyPath: "transform.rotation.z")
        animation.duration = PTPopupAnimationBaseDuration + 0.15
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.values = [(0.0).toRadians(), (-2.2 * rotationAngle).toRadians(), (1.2 * rotationAngle).toRadians(), (0.0).toRadians()]
        animation.keyTimes = [0.0, 0.4, 0.54, 1.0]
        animation.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut),
                                     CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut),
                                     CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut),
                                     CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)]
        
        return animation
    }
    
    func scrollViewBottomPageFrame() -> CGRect {
        var bottomPageFrame = self.scrollView.frame
        
        let numberOfPages = 2
        
        bottomPageFrame.origin.y = self.scrollView.bounds.height * (CGFloat)(numberOfPages - 1)
        
        return bottomPageFrame
    }
    
    func initialPopupViewFrameForShowAnimation(_ popupView: UIView) -> CGRect {
        var rect = popupView.frame
        
        rect.origin.x = (self.view.frame.width - rect.width) * 0.5
        rect.origin.y = (self.view.frame.height - rect.height) * 0.5 - self.view.frame.height
        
        return rect
    }
    
    func finalPopupViewFrameForShowAnimation(_ popupView: UIView) -> CGRect {
        var rect = popupView.frame
        
        rect.origin.x = (self.view.frame.width - rect.width) * 0.5
        rect.origin.y = (self.view.frame.height - rect.height) * 0.5
        
        return rect
    }
    
    func initialPopupViewFrameForHideAnimation(_ popupView: UIView) -> CGRect {
        if popupView.superview == self.scrollView {
            let rect = self.scrollView.convert(popupView.frame, to: self.view)
            return rect
        } else {
            return self.finalPopupViewFrameForShowAnimation(popupView)
        }
    }

    func finalPopupViewFrameForHideAnimation(_ popupView: UIView) -> CGRect {
        var rect = popupView.frame
        
        rect.origin.x = (self.view.frame.width - rect.width) * 0.5
        rect.origin.y = (self.view.frame.height - rect.height) * 0.5 + self.view.frame.height
        
        return rect
    }
    
    func popupViewFrameForScrollView(_ popupView: UIView) -> CGRect {
        let targetRect = self.scrollViewBottomPageFrame()
        var rect = popupView.frame
        
        rect.origin.x = (targetRect.size.width - rect.width) * 0.5
        rect.origin.y = targetRect.origin.y + (targetRect.size.height - rect.height) * 0.5
        
        return rect
    }
    
    func popupViewRotationAngle() -> CGFloat {
        var rotationAngle: CGFloat = 0.0;
        
        if (self.gestureStartTouchPositionX == 0.0) {
            // The user didn't swipe to dismiss the profile popup view, so we pick a random rotation angle
            
            // Calculate a random angle between -PTAnimationMaximumRotationDegrees° and PTAnimationMaximumRotationDegrees°, disallowing angles too close to 0°
            let maximumRotation: UInt32 = (UInt32)(self.PTAnimationMaximumRotationDegrees * 100);
            let minimumRotation: UInt32 = (UInt32)(self.PTAnimationMinimumRotationDegrees * 100);
            rotationAngle = ((CGFloat)(arc4random() % (maximumRotation - minimumRotation)) + (CGFloat)(minimumRotation)) * 0.01;
            
            if (arc4random_uniform(2) == 1) {
                rotationAngle *= -1.0;
            }
        } else {
            // The user swiped down above the profile popup view, so we'll pick an angle that would feel natural when swiping a card away
            
            // Bring the maximum rotation angle in a bit so the profile popup view doesn't hit the edges of the screen
            let maximumRotation: CGFloat = PTAnimationMaximumRotationDegrees - 1.0;
            let normalizedSwipeGesturePositionX = self.gestureStartTouchPositionX / self.view.frame.width;
            rotationAngle = (normalizedSwipeGesturePositionX * (maximumRotation * 2.0)) - maximumRotation;
        }
        
        return rotationAngle;
    }
    
    public func backgroundColor(alpha: CGFloat) -> UIColor {
        return UIColor(white: 0.4, alpha: alpha)
    }
}

extension PTPopupViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let currentPopupView = self.currentPopupView {
            currentPopupView.layer.shouldRasterize = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let currentPopupView = self.currentPopupView {
            let scrollViewContentOffsetY = scrollView.contentOffset.y
            let scrollViewBottommostPageFrameY = self.scrollViewBottomPageFrame().minY
            
            self.gestureStartTouchPositionX = scrollView.panGestureRecognizer.location(in: scrollView).x
            
            let offscreenRotationAngle: CGFloat = self.popupViewRotationAngle()
            let unboundedOffscreenMovementPercentage: CGFloat = 1.0 - (scrollViewContentOffsetY / scrollViewBottommostPageFrameY);
            let boundedOffscreenMovementPercentage: CGFloat = max(0.0, min(unboundedOffscreenMovementPercentage, 1.0))
            let currentRotationAngle: CGFloat = offscreenRotationAngle * boundedOffscreenMovementPercentage;
            
            self.view.backgroundColor = self.backgroundColor(alpha: PTPopupViewControllerBGAlpha * (1 - boundedOffscreenMovementPercentage))
            
            currentPopupView.transform = CGAffineTransform(rotationAngle: (CGFloat)((Double)(currentRotationAngle).toRadians()))
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.hidePopupViewIfNeeded(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            self.hidePopupViewIfNeeded(scrollView)
        }
    }
    
    func hidePopupViewIfNeeded(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0.0 {
            self.hidePopupView(animated: false, hideContext: .scrolling)
        }
    }
}
