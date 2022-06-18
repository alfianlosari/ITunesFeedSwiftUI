//
//  SafariView.swift
//  
//
//  Created by Alfian Losari on 6/18/22.
//


import SwiftUI
import WebKit

#if os(iOS)
struct WebView: UIViewRepresentable {
 
    let url: URL
 
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

#elseif os(macOS)
struct WebView: NSViewRepresentable {
 
    let url: URL
    
    func makeNSView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
#endif

#if DEBUG
struct WebView_Previews : PreviewProvider {
    static var previews: some View {
        WebView(url: URL(string: "https://apple.com")!)
    }
}
#endif
