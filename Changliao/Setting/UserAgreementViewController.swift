//
//  UserAgreementViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/22/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import WebKit
import Masonry

@objc class UserAgreementViewController: UIViewController,WKNavigationDelegate,WKUIDelegate {
    
    var webView:WKWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        // Do any additional setup after loading the view.
        webView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        webView.scrollView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        view.addSubview(webView)
        webView.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            make?.bottom.equalTo()(self.view.mas_bottom)
        }
        webView.load(URLRequest(url: URL(string: "https://www.2000rmb.com/mobile/")!))
        webView.navigationDelegate = self
        webView.uiDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "用户协议"
    }
    
    // MARK: WebKit
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        //
        decisionHandler(.allow)
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if !(navigationAction.targetFrame?.isMainFrame)! {
            webView.load(navigationAction.request)
        }
        return nil
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
