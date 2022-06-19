//
//  MediaGridView.swift
//  
//
//  Created by Alfian Losari on 6/19/22.
//

import SwiftUI

public struct MediaGridView<T: Codable>: View where T: ITunesMediaListItem, T: Identifiable, T: Hashable {
    
    let title: String
    @StateObject var vm: MediaListObservableObject<T>
    
    public init(title: String, vm: MediaListObservableObject<T>) {
        self.title = title
        self._vm = StateObject(wrappedValue: vm)
    }
    
    private let columns = [GridItem(.adaptive(minimum: 240), alignment: .leading)]
    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 24) {
                ForEach(vm.results ?? []) { item in
                    #if os(macOS)
                    // Currently macOS layout is broken when it is embedded in NavigationLink 
                    MediaListItemView(item: item)
                    #else
                    NavigationLink(value: item) {
                        MediaListItemView(item: item)
                    }
                    #endif
                }
            }
            .padding()
        }
        .navigationTitle(title)
        .overlay(overlayView)
        .task {
            if vm.results == nil {
                vm.fetchMedia()
            }
        }
    }
    
    @ViewBuilder
    private var overlayView: some View {
        switch vm.phase {
        case .success(let feed) where feed.results.isEmpty:
            Text("Feed is empty")
        case .failure(let error):
            Text(error.localizedDescription)
        case .loading:
            ProgressView()
        default: EmptyView()
        }
    }
}

struct MediaGridView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MediaGridView(title: "Top 24 songs", vm: SongListObservableObject(region: "us", resultLimit: .limit25))
        }
    }
}
