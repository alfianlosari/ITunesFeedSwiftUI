//
//  SafariView.swift
//  
//
//  Created by Alfian Losari on 6/18/22.
//


import SwiftUI
import WebKit

enum WebViewLoadPhase {
    case success
    case failure(Error)
    case loading
}

#if os(iOS)
struct WebView: UIViewRepresentable {
 
    let url: URL
    @Binding var phase: WebViewLoadPhase

 
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard webView.url != url else {
            return
        }
        
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        let request = URLRequest(url: url)
        webView.load(request)
    
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(phase: $phase)
    }
    
}

#elseif os(macOS)
struct WebView: NSViewRepresentable {
 
    let url: URL
    @Binding var phase: WebViewLoadPhase
    
    func makeNSView(context: Context) -> WKWebView {
        WKWebView()
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        guard webView.url != url else {
            return
        }
        
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        let request = URLRequest(url: url)
        webView.load(request)
    }

    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(phase: $phase)
    }
}

#endif

class WebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    
    @Binding var phase: WebViewLoadPhase
    
    init(phase: Binding<WebViewLoadPhase>) {
        self._phase = phase
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.phase = .success
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.phase = .failure(error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.phase = .failure(error)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.phase = .loading
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        let exceptions = SecTrustCopyExceptions(serverTrust)
        SecTrustSetExceptions(serverTrust, exceptions)
        completionHandler(.useCredential, URLCredential(trust: serverTrust));
    }
}

#if DEBUG
struct WebView_Previews : PreviewProvider {
    static var previews: some View {
        WebView(url: URL(string: "https://apple.com")!, phase: .constant(.loading))
    }
}
#endif
