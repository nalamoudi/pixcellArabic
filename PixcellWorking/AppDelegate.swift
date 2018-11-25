//
//  AppDelegate.swift
//  PixcellWorking
//
//  Created by Muaawia Janoudy on 2018-10-17.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

var launch = ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        //The code below is to determine if this is the user's first time using the App and setting a String value to it
    
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        
        if launchedBefore
        {
            launch = "Has launched before"
        }
        else
        {
            launch = "First launch"
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        //configure the Firebase Database for the App use
        FirebaseApp.configure()
        
        //request user Authorization to send them Notifications
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.badge, .alert, .sound], completionHandler: { (success, error) in
            if error != nil {
                print("Authorization is unsuccessful")
            } else {
                print("Authorization is successful")
            }
        })
        let content = UNMutableNotificationContent()
        content.title = "Pixcel Book Not Submitted"
        content.body = "Please submit your album before the 25th of the month if you have not done so already!"
        content.sound = UNNotificationSound.default
        
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        let dateString = "19/\(currentMonth)/\(currentYear)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let reminderDate = dateFormatter.date(from: dateString) as! Date
        let triggerMonthly = Calendar.current.dateComponents([/*.month,.day,*/.hour,.minute,.second], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerMonthly, repeats: true)
        
        let identifier = "UYLLocalNotification"
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print("Something's wrong")
            }
        })
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate
{
    //Here you get the callback for notification, if the app is in FOREGROUND.
    //Here you decide whether to silently handle the notification or still alert the user.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .sound]) //execute the provided completion handler block with the delivery option (if any) that you want the system to use. If you do not specify any options, the system silences the notification.
    }
}

