//
//  MediaListItemView.swift
//  
//
//  Created by Alfian Losari on 6/18/22.
//

import ITunesFeedGenerator
import SwiftUI

protocol ITunesMediaListItem {
    var artworkUrl100: String { get }
    var name: String { get }
    var artistName: String { get }
    var releaseDate: String { get }
    var url: String { get }
}

extension Book: ITunesMediaListItem {}
extension Song: ITunesMediaListItem {}
extension Application: ITunesMediaListItem {}

extension Song: Identifiable {}
extension Book: Identifiable {}
extension Application: Identifiable {}

public struct MediaListItemView: View {
    
    let item: ITunesMediaListItem
    public init(book: Book) { self.item = book }
    public init(song: Song) { self.item = song }
    public init(app: Application) { self.item = app }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: URL(string: item.artworkUrl100)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .failure(_):
                    Image(systemName: "photo")
                        .foregroundColor(Color.gray.opacity(0.8))
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        
                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxWidth: 100, minHeight: 100)
            .background { Color.gray.opacity(0.3)}
            .cornerRadius(8)
            
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name).font(.callout).foregroundColor(.primary)
                Text(item.artistName).font(.caption).foregroundColor(.primary)
                Text(item.releaseDate).font(.caption2).foregroundColor(.secondary)
                
                if let buttonURL = URL(string: item.url) {
                    Spacer()
                    
                    Button("iTunes") {
                        #if os(iOS)
                        UIApplication.shared.open(buttonURL)
                        #elseif os(macOS)
                        NSWorkspace.shared.open(buttonURL)
                        #endif
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .padding(.top, 8)
                }
            }
            .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 8)
    }
}

#if DEBUG
struct MediaListItemView_Previews: PreviewProvider {
    
    static let book = Book.stub
    static let song = Song.stub
    static let app = Application.stub
    
    static var previews: some View {
        NavigationStack {
            List {
                Section("Books") {
                    NavigationLink(destination: MediaDetailView(book: book)) {
                        MediaListItemView(book: book)
                    }
                }
                
                Section("Songs") {
                    MediaListItemView(song: song)
                }
                
                
                Section("Apps") {
                    MediaListItemView(app: app)
                }
            }
            .navigationTitle("XCA iTunes Feed")
        }
       
    }
}

extension Book {
    
    static var stub: Book {
        let jsonString = """
         {
                "artistName": "Elin Hilderbrand",
                "id": "1604139372",
                "name": "The Hotel Nantucket",
                "releaseDate": "2022-06-14",
                "kind": "books",
                "artistId": "283108017",
                "artistUrl": "https://books.apple.com/us/author/elin-hilderbrand/id283108017",
                "artworkUrl100": "https://is5-ssl.mzstatic.com/image/thumb/Publication122/v4/ca/06/16/ca0616e7-8bd3-05cd-468e-385d1df50e23/9780316259088.jpg/100x155bb.png",
                "url": "https://books.apple.com/us/book/the-hotel-nantucket/id1604139372"
              }
        """.data(using: .utf8)!
        
        let book = try! JSONDecoder().decode(Book.self, from: jsonString)
        return book
        
    }
}


extension Song {
    static var stub: Song {
        let jsonString = """
        {
                "artistName": "Joji",
                "id": "1625328892",
                "name": "Glimpse of Us",
                "releaseDate": "2022-06-10",
                "kind": "songs",
                "artistId": "1258279972",
                "artistUrl": "https://music.apple.com/sg/artist/joji/1258279972",
                "artworkUrl100": "https://is2-ssl.mzstatic.com/image/thumb/Music122/v4/f0/45/85/f0458570-7306-662e-01aa-a6bc3bded675/054391890016.jpg/100x100bb.jpg",
                "genres": [
                  {
                    "genreId": "14",
                    "name": "Pop",
                    "url": "https://itunes.apple.com/sg/genre/id14"
                  },
                  {
                    "genreId": "34",
                    "name": "Music",
                    "url": "https://itunes.apple.com/sg/genre/id34"
                  },
                  {
                    "genreId": "20",
                    "name": "Alternative",
                    "url": "https://itunes.apple.com/sg/genre/id20"
                  }
                ],
                "url": "https://music.apple.com/sg/album/glimpse-of-us/1625328890?i=1625328892"
              }
        """.data(using: .utf8)!
        
        let song = try! JSONDecoder().decode(Song.self, from: jsonString)
        return song
        
    }
}


extension Application {
    static var stub: Application {
        let jsonString = """
        {
                "artistName": "Google LLC",
                "id": "284815942",
                "name": "Google",
                "releaseDate": "2019-02-12",
                "kind": "apps",
                "artworkUrl100": "https://is2-ssl.mzstatic.com/image/thumb/Purple122/v4/51/b1/b2/51b1b2b2-e394-48a9-badc-635077051296/logo_gsa_ios_color-0-1x_U007emarketing-0-0-0-6-0-0-0-85-220-0.png/100x100bb.png",
                "genres": [],
                "url": "https://apps.apple.com/us/app/google/id284815942"
              }
        """.data(using: .utf8)!
        
        let app = try! JSONDecoder().decode(Application.self, from: jsonString)
        return app
    }
}

#endif
