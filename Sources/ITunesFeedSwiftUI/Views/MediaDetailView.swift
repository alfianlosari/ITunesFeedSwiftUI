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
            WebView(url: url)
        } else {
            Text("URL is not valid \(item.url)")
        }
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
