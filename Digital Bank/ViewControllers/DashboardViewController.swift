//
//  DashboardViewController.swift
//  Digital Bank
//
//  Updated by Keith Puzey on 1 / 4/2026.
//

import UIKit
import WebKit
import Alamofire

class DashboardViewController: UIViewController {

    var authToken: String?
    var userEmail: String?
    
    // 1. Changed from UITableView to WKWebView
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 2. Set the Title
        self.navigationItem.title = "Financial Dashboard"
        
        setupWebViewUI()
        loadFinancialDashboard()
    }
    
    private func setupWebViewUI() {
        // 1. Clear any "Invisible Walls" (Gestures on the parent view)
        // This stops the main view from "stealing" touches meant for the web content
        view.gestureRecognizers?.forEach { view.removeGestureRecognizer($0) }
        
        // 2. Force Auto Layout to use our code-based constraints
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        // 3. Force the Web View to the absolute top of the "stack"
        view.bringSubviewToFront(webView)
        
        // 4. Pin to all four corners
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // 5. Explicitly enable interaction on the View, the WebView, and the Internal Scroller
        view.isUserInteractionEnabled = true
        webView.isUserInteractionEnabled = true
        webView.scrollView.isUserInteractionEnabled = true
        webView.scrollView.isScrollEnabled = true
        
        // 6. Enable JavaScript (Crucial for dashboard buttons/menus to respond)
        webView.configuration.preferences.javaScriptEnabled = true
        
        // 7. Visual Debug: (Optional) Set a border to see exactly where the touchable area is
        // webView.layer.borderWidth = 2
        // webView.layer.borderColor = UIColor.red.cgColor
    }

    private func loadFinancialDashboard() {
        // 1. Get the base URL (e.g., "http://dbankdemo.com/bank")
        let rawBaseUrl = AppConst.baseurl
        
        // 2. Remove "/bank" if it exists at the end of the string
        // This turns "http://dbankdemo.com/bank" into "http://dbankdemo.com"
        let homeUrl = rawBaseUrl.replacingOccurrences(of: "/bank", with: "")
        
        // 3. Construct the final path (ensure there is a "/" between domain and file)
        let fullUrlString = homeUrl + "/financedashboard.html"
        
        if let url = URL(string: fullUrlString) {
            let request = URLRequest(url: url)
            webView.load(request)
            print("Loading URL: \(fullUrlString)")
        } else {
            print("Invalid URL: \(fullUrlString)")
        }
    }

    @IBAction func Logout(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.layer.borderWidth = 0.5
        self.tabBarController?.tabBar.layer.borderColor = UIColor.lightGray.cgColor
    }
}

// Note: You can now delete the UITableViewDataSource extension
// as the WebView handles its own rendering.
