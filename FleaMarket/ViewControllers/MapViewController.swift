//
//  WriteViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/19.
//

import UIKit
import WebKit

class MapViewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string:"https://map.naver.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}
