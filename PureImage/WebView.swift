//
//  WebView.swift
//  PureImage
//
//  Created by Miaoqi Wang on 2021/6/24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    
    @Binding var request: URLRequest?
    
    static var pageUrl: URL? = nil
    let webView = InnerWebView()
    
    func makeUIView(context: Context) -> InnerWebView {
        return webView
    }
    
    func updateUIView(_ uiView: InnerWebView, context: Context) {
        if let req = request {
            uiView.load(req)
        }
    }
}

class InnerWebView: WKWebView {
        
    init() {
        let config = WKWebViewConfiguration()
        super.init(frame: .zero, configuration: config)
        self.navigationDelegate = self
        self.uiDelegate = self
        self.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.106 Safari/537.36"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func back() {
        if canGoBack {
            goBack()
        }
    }
}

extension InnerWebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("InnerWebView - didStartProvisionalNavigation")
        WebView.pageUrl = webView.url
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("InnerWebView - didFinish")
        WebView.pageUrl = webView.url
    }
}

extension InnerWebView: WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        self.load(navigationAction.request)
        return nil
    }
}
