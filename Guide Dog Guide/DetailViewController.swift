//
//  DetailViewController.swift
//  Guide Dog Guide
//
//  Created by David Bradford on 1/14/17.
//  Copyright © 2017 David Bradford. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var webview: UIWebView!

    let htmlPrefix = "<html><head><meta name=\"viewport\" content=\"width=device-width\"></head><body>\n"
    let htmlSuffix = "</body></html>"

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let webview = self.webview {
                webview.loadHTMLString(htmlPrefix + detail + htmlSuffix, baseURL: nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: String? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if (navigationType == UIWebViewNavigationType.linkClicked) {
            
            let url = request.url!
            if let scheme = url.scheme {
                if scheme == "applewebdata" {
                    return true
                }
                UIApplication.shared.open(url)
                return false
            }
            return true
        }
        
        return true
    }
}

