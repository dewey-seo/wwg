//
//  AppDelegate.swift
//  wwg
//
//  Created by dewey on 2018. 7. 10..
//  Copyright © 2018년 dewey. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import GooglePlaces

let GOOGLE_API_KEY = "AIzaSyCROCajPeG43OjPpFu5w936kNZuRtIXFc4"
let KAKAO_SECRET_KEY = "zQMMc5TQIVPNuVgY2ycHQyvjTiU0VmaG"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let rootViewController: PTRootViewController = PTRootViewController(nibName: "PTRootViewController", bundle: nil)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = rootViewController
        self.window?.makeKeyAndVisible()
        
        // 
        PTDBManager.shared.deleteOrphanedModels()
        
        // Network Start
        PTNetworkManager.sharedInstance.start()
        
        // Google Places API
        self.didFinishLaunchingWithOptionForGoogle()
        
        // Kakao
        self.didFinishLaunchingWithOptionForKakao()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        KOSession.handleDidBecomeActive()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        KOSession.handleDidBecomeActive()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        PTNetworkManager.sharedInstance.stop()
        PTCoredataManager.saveContext()
    }

    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "wwg")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension AppDelegate {
    static func rootViewController() -> PTRootViewController {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.rootViewController
    }
    
    static func topViewController() -> UIViewController {
        var baseViewController:UIViewController = AppDelegate.rootViewController()
        while let presentedViewController = baseViewController.presentedViewController {
            baseViewController = presentedViewController
        }
        
        return baseViewController
    }
}

extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if KOSession.isKakaoAccountLoginCallback(url) {
            return KOSession.handleOpen(url)
        }
        
        return false
    }
    
    func didFinishLaunchingWithOptionForKakao() {
        KOSession.shared().clientSecret = KAKAO_SECRET_KEY
        KOSession.shared().isAutomaticPeriodicRefresh = true
    }
    func didFinishLaunchingWithOptionForGoogle() {
        GMSServices.provideAPIKey(GOOGLE_API_KEY)
        GMSPlacesClient.provideAPIKey(GOOGLE_API_KEY)
    }
}
