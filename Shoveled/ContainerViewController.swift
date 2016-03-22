//
//  ContainerViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 3/5/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
    case BothCollapsed
    case LeftPanelExpanded
}

class ContainerViewController: UIViewController {

    var centerNavigationController: UINavigationController!
    var centerViewController: CurrentStatusViewController!
    
    var currentState: SlideOutState = .BothCollapsed {
        didSet {
            let shouldShowShadow = currentState != .BothCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    
    var leftViewController: SideMenuViewControllerTableViewController?
    
    let centerPanelExpandedOffset: CGFloat = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerViewController = UIStoryboard.centerViewController()
        centerViewController.delegate = self

        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)

        centerNavigationController.didMoveToParentViewController(self)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
    }
}


extension ContainerViewController: CurrentStatusControllerDelegate {
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func collapseSidePanels() {
        switch (currentState) {
        case .LeftPanelExpanded:
            toggleLeftPanel()
        default:
            break
        }
    }
    
    func addLeftPanelViewController() {
        if (leftViewController == nil) {
            leftViewController = UIStoryboard.leftViewController()
            leftViewController?.cellItems = MenuItems.allItems()
            
            addChildSidePanelController(leftViewController!)
        }
    }
    
    func addChildSidePanelController(sidePanelController: SideMenuViewControllerTableViewController) {
        sidePanelController.delegate = centerViewController
        
        view.insertSubview(sidePanelController.view, atIndex: 0)
        
        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }
    
    func animateLeftPanel(shouldExpand shouldExpand: Bool) {
        if shouldExpand {
            currentState = .LeftPanelExpanded
            
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerNavigationController.view.frame) - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
            
                self.currentState = .BothCollapsed
                self.leftViewController?.view.removeFromSuperview()
                self.leftViewController = nil
            }
        }
    }
    
    func animateCenterPanelXPosition(targetPosition targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
}

extension ContainerViewController: UIGestureRecognizerDelegate {
    // MARK: Gesture recognizer
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        
        switch(recognizer.state) {
        case .Began:
            if (currentState == .BothCollapsed) {
                if (gestureIsDraggingFromLeftToRight) {
                    addLeftPanelViewController()
                }
                showShadowForCenterViewController(true)
            }
        case .Changed:
            recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
            recognizer.setTranslation(CGPointZero, inView: view)
        case .Ended:
            if (leftViewController != nil) {
                // animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
            }
        default:
            break
        }
    }
}

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func leftViewController() -> SideMenuViewControllerTableViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SideMenuViewController") as? SideMenuViewControllerTableViewController
    }
    
    class func centerViewController() -> CurrentStatusViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("CurrentStatusViewController") as? CurrentStatusViewController
    }
}