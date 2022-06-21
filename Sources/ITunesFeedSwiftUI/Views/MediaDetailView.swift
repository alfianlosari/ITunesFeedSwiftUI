//
//  MediaDetailView.swift
//  
//
//  Created by Alfian Losari on 6/18/22.
//

import ITunesFeedGenerator
import SwiftUI

public protocol ITunesMediaDetailItem {
    var url: String { get }
    var name: String { get }
}

extension Book: ITunesMediaDetailItem {}
extension Song: ITunesMediaDetailItem {}
extension Application: ITunesMediaDetailItem {}

public struct MediaDetailView: View {
    
    @State var phase: WebViewLoadPhase = .loading

    let item: ITunesMediaDetailItem
    public init(book: Book) { self.item = book }
    public init(song: Song) { self.item = song }
    public init(app: Application) { self.item = app }
    public init(item: ITunesMediaDetailItem) { self.item = item }
    
    public var body: some View {
        mainView.navigationTitle(item.name)
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    @ViewBuilder
    private var mainView: some View {
        if let url = URL(string: item.url) {
            WebView(url: url, phase: $phase)
                .overlay(overlayView)
        } else {
            Text("URL is not valid \(item.url)")
        }
    }
    
    @ViewBuilder
    private var overlayView: some View {
        switch phase {
        case .success:
            EmptyView()
        case .failure(let error):
            ZStack {
                Rectangle()
                    .foregroundColor(loadingBackgroundColor)
                Text(error.localizedDescription)
            }
            
        case .loading:
            ZStack {
                Rectangle()
                    .foregroundColor(loadingBackgroundColor)
                ProgressView()
            }
        }
    }
    
    private var loadingBackgroundColor: Color {
        #if os(macOS)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color(uiColor: UIColor.systemBackground)
        #endif
    }
}

#if DEBUG
struct MediaDetailView_Previews: PreviewProvider {
    static let song = Song.stub
    static var previews: some View {
        NavigationStack {
            MediaDetailView(song: song)
        }
    }
}
#endif
