//
//  CustomModal.swift
//  classPics
//
//  Created by Kazumasa Shimomura on 2016/10/05.
//  Copyright © 2016年 Kazumasa Shimomura. All rights reserved.
//

import UIKit

class CustomModal: UIPresentationController, UIViewControllerTransitioningDelegate{
    
    // 呼び出し元の View Controller の上に重ねるオーバーレイ View
    var overlay: UIView!
    
    // 表示トランジション開始前に呼ばれる
    override func presentationTransitionWillBegin() {
        let containerView = self.containerView!
        
        self.overlay = UIView(frame: containerView.bounds)
        self.overlay.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(overlayDidTouch))]
        self.overlay.backgroundColor = UIColor.black
        self.overlay.alpha = 0.0
        containerView.insertSubview(self.overlay, at: 0)
        
        // トランジションを実行
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: {
            [unowned self] context in
            self.overlay.alpha = 0.5
            }, completion: nil)
    }
    
    // 非表示トランジション開始前に呼ばれる
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: {
            [unowned self] context in
            self.overlay.alpha = 0.0
            }, completion: nil)
    }
    
    // 非表示トランジション開始後に呼ばれる
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            self.overlay.removeFromSuperview()
//            let ad = UIApplication.shared.delegate as! AppDelegate
//            let vc = ad.window?.rootViewController?.childViewControllers.last as! WebViewController
//            if vc.interstitial.isReady {
//                vc.interstitial.presentFromRootViewController(vc)
//                vc.loadInterstitial()
//            }
        }
    }

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width, height: parentSize.height / 5)
    }
    
    // 呼び出し先の View Controller の Frame を返す
//    override func frameOfPresentedViewInContainerView() -> CGRect {
//        var presentedViewFrame = CGRectZero
//        let containerBounds = containerView!.bounds
//        presentedViewFrame.size = self.sizeForChildContentContainer(container: self.presentedViewController, withParentContainerSize: containerBounds.size)
//        presentedViewFrame.origin.x = containerBounds.size.width - presentedViewFrame.size.width
//        presentedViewFrame.origin.y = containerBounds.size.height - presentedViewFrame.size.height
//        return presentedViewFrame
//    }

        
    // レイアウト開始前に呼ばれる
    override func containerViewWillLayoutSubviews() {
        overlay.frame = containerView!.bounds
        self.presentedView!.frame = self.frameOfPresentedViewInContainerView
    }
    
    // レイアウト開始後に呼ばれる
    override func containerViewDidLayoutSubviews() {
    }
    
    // オーバーレイの View をタッチしたときに呼ばれる
    func overlayDidTouch(sender: AnyObject) {
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }

}

final class CustomPresentationController: UIPresentationController {
    var overlayView = UIView()
    
    // 表示トランジション開始前に呼ばれる
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }
        
        overlayView.frame = containerView.bounds
        overlayView.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(overlayViewDidTouch))]
        overlayView.backgroundColor = UIColor.black
        overlayView.alpha = 0.0
        containerView.insertSubview(overlayView, at: 0)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] context in
            self?.overlayView.alpha = 0.7
            }, completion: nil)
    }
    
    // 非表示トランジション開始前に呼ばれる
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] context in
            self?.overlayView.alpha = 0.0
            }, completion: nil)
    }
    
    // 非表示トランジション開始後に呼ばれる
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            overlayView.removeFromSuperview()
        }
    }
    
    let margin = (x: CGFloat(30), y: CGFloat(220.0))

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width - margin.x, height: parentSize.height - margin.y)

    }

    
//    override func frameOfPresentedViewInContainerView() -> CGRect {
//        var presentedViewFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
//        let containerBounds = containerView!.bounds
//        let childContentSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
//        presentedViewFrame.size = childContentSize
//        presentedViewFrame.origin.x = margin.x / 2.0
//        presentedViewFrame.origin.y = margin.y / 2.0
//        
//        return presentedViewFrame
//    }

    
//    override func frame
 
    
    // レイアウト開始前に呼ばれる
    override func containerViewWillLayoutSubviews() {
        overlayView.frame = containerView!.bounds
        presentedView!.frame = frameOfPresentedViewInContainerView
    }
    
    // レイアウト開始後に呼ばれる
    override func containerViewDidLayoutSubviews() {
    }
    
    // overlayViewをタップしたときに呼ばれる
    func overlayViewDidTouch(sender: AnyObject) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
