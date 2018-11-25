//
//  SettingsDetailViewController.swift
//  PixcellWorking
//
//  Created by Nahar Alamoudi on 11/6/18.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

import UIKit
import WebKit

class SettingsDetailViewController: UIViewController {
    
    var settingsString: String?
    var webView: WKWebView
    
    
    
    @IBOutlet weak var languageLabelEnglish: UILabel!
    @IBOutlet weak var languageLabelArabic: UILabel!
    @IBOutlet weak var languageSegmentedChoice: UISegmentedControl!
    @IBOutlet weak var viewSegmented: UIView!
    
    required init(coder aDecoder: NSCoder) {
        self.webView = WKWebView(frame: CGRect.zero)
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        viewSegmented.layer.cornerRadius = 10
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        languageLabelArabic.isHidden = true
        languageLabelEnglish.isHidden = true
        languageSegmentedChoice.isHidden = true
        viewSegmented.isHidden = true
        
        /*
         
         /* Language Cell */
         "Change Language" = "تغير اللغة";
         
         /* Terms Cell */
         "Terms & Conditions" = "الشروط والأحكام";
         
         /* Privacy Cell */
         "Privacy Policy" = "سياسة الخصوصية";
         
         /* Contact Cell */
         "Contact Us" = "اتصل بنا";
         
         /* FAQs Cell */
         "FAQs" = "أسئلة وأجوبة"
         
 */
        
        if let settingsString = settingsString {
            
            if settingsString == "Terms & Conditions" || settingsString == "الشروط والأحكام"{
                displayWebPageWithURL(with: "https://pixcellbook.com/terms-and-conditions")
            } else if settingsString == "Privacy Policy" || settingsString == "سياسة الخصوصية" {
                displayWebPageWithURL(with: "https://pixcellbook.com/privacy-policy")
                
            } else if settingsString == "Contact Us" || settingsString == "اتصل بنا" {
                displayWebPageWithURL(with: "https://pixcellbook.com/contact-us")
                
            } else if settingsString == "FAQs" || settingsString == "أسئلة وأجوبة" {
                displayWebPageWithURL(with: "https://pixcellbook.com/faq")
                
            } else if settingsString == "Change Language" || settingsString == "تغير اللغة" {
                view.bringSubviewToFront(viewSegmented)
                view.bringSubviewToFront(languageLabelArabic)
                view.bringSubviewToFront(languageLabelEnglish)
                languageLabelArabic.isHidden = false
                languageLabelEnglish.isHidden = false
                languageSegmentedChoice.isHidden = false
                viewSegmented.isHidden = false
                
            }
                
        }
    }
    
    func displayWebPageWithURL(with siteURL: String) {
        let url = NSURL(string: siteURL)
        let request = NSURLRequest(url: url! as URL)
        webView.load(request as URLRequest)
    }
    
    func attributedText(_ text: String, _ title: String) -> NSAttributedString {
        
        let string = text as NSString
        
        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15.0)])
        
        let boldFontAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15.0)]
        
        // Part of string to be bold
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: title))
       // attributedString.addAttributes(boldFontAttribute, range: string.range(of: "PLEASE NOTE:"))
        
        // 4
        return attributedString
    }
    

}
