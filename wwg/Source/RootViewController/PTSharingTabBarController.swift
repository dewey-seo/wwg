//
//  PTSharingTabBarController.swift
//  Path
//
//  Created by dewey on 2018. 7. 2..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit

enum PTTabTag: Int {
    case feed
    case recommend
    case search
    case setting
}

class PTSharingTabBarController: UITabBarController {
    var dismissBlock: PTRootViewRefreshBlock?
    
    var currentTag: Int = 0
    
    let mainTabViewController: PTMainTabViewController
    let mainTabNavigationController: UINavigationController
    let recommendViewController: PTRecommendTabViewController
    let recommendNavigationController: UINavigationController
    let myPlacesViewController: PTMyPlacesTabViewController
    let myPlacesNavigationController: UINavigationController
    let settingViewController: PTSettingViewController
    let settingNavigationController: UINavigationController
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.mainTabViewController = PTMainTabViewController(nibName: "PTMainTabViewController", bundle: nil)
        self.mainTabNavigationController = UINavigationController(rootViewController: self.mainTabViewController)
        
        self.recommendViewController = PTRecommendTabViewController(nibName: "PTRecommendTabViewController", bundle: nil)
        self.recommendNavigationController = UINavigationController(rootViewController: self.recommendViewController)
        
        self.myPlacesViewController = PTMyPlacesTabViewController(nibName: "PTMyPlacesTabViewController", bundle: nil)
        self.myPlacesNavigationController = UINavigationController(rootViewController: self.myPlacesViewController)
        
        self.settingViewController = PTSettingViewController(nibName: "PTSettingViewController", bundle: nil)
        self.settingNavigationController = UINavigationController(rootViewController: self.settingViewController)
        
        let feedTabItem = UITabBarItem.init(tabBarSystemItem: .favorites, tag: PTTabTag.feed.rawValue)
        let recommendTabItem = UITabBarItem.init(tabBarSystemItem: .topRated, tag: PTTabTag.recommend.rawValue)
        let searchTabItem = UITabBarItem.init(tabBarSystemItem: .search, tag: PTTabTag.search.rawValue)
        let settingTabItem = UITabBarItem.init(tabBarSystemItem: .more, tag: PTTabTag.setting.rawValue)
        
        self.mainTabViewController.tabBarItem = feedTabItem
        self.recommendViewController.tabBarItem = recommendTabItem
        self.myPlacesViewController.tabBarItem = searchTabItem
        self.settingViewController.tabBarItem = settingTabItem
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.viewControllers = [self.mainTabNavigationController, self.recommendNavigationController, self.myPlacesNavigationController, self.settingNavigationController]
    }
    
    func close() {
        self.dismiss(animated: true) {
            if let block = self.dismissBlock {
                block()
            }
        }
    }
}

enum Direction {
    case hold
    case left
    case right
    
    var startPositionTransfrom: CGAffineTransform {
        switch self {
        case .left:
            return .init(translationX: (-1 * UIScreen.main.bounds.width * 0.5), y: 0)
        case .right:
            return .init(translationX: UIScreen.main.bounds.width * 0.5, y: 0)
        case .hold:
            return .identity
        }
    }
    
    
    func applyDirctionAnimation(fromVC: UIViewController, toVC: UIViewController) {
        fromVC.view.alpha = 1.0
        toVC.view.transform = self.startPositionTransfrom
        
        let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
            fromVC.view.alpha = 1.0
            toVC.view.transform = .identity
        }
        
        animator.addCompletion {
            position in
            switch position {
            case .end: print("Completion handler called at end of animation")
            case .current: print("Completion handler called mid-way through animation")
            case .start: print("Completion handler called  at start of animation")
            }
        }
        
        animator.startAnimation()
    }
}

extension PTSharingTabBarController {
    override var selectedIndex: Int {
        willSet(newValue) {
            if let selectedVC = self.selectedViewController {
                self.selectedItemChanged(from: currentTag, to: selectedVC.tabBarItem.tag)
            }
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.selectedItemChanged(from: currentTag, to: item.tag)
    }
    
    private func selectedItemChanged(from: Int, to: Int) {
        currentTag = to
        
        print("index change: \(from) -> \(to)")
        let direction: Direction = from < to ? .right : (from > to ? .left : .hold)

        guard let fromVC = self.tabBarItemTagToViewController(from) else {
            print("can`t find viewcontroller: tag(\(from))")
            return
        }
        guard let toVC = self.tabBarItemTagToViewController(to) else {
            print("can`t find viewcontroller: tag(\(to))")
            return
        }
        
        direction.applyDirctionAnimation(fromVC: fromVC, toVC: toVC)
    }
    
    private func tabBarItemTagToViewController(_ tag: Int) -> UIViewController? {
        guard let viewController = self.viewControllers else {
            return nil
        }
        
        var result: UIViewController?
        for vc in viewController {
            if vc.tabBarItem.tag == tag {
                result = vc
            }
        }
        
        return result
    }
}
