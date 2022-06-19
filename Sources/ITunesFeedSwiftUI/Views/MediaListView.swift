//
//  MediaListView.swift
//  
//
//  Created by Alfian Losari on 6/19/22.
//

import SwiftUI
import ITunesFeedGenerator

public struct MediaListView<T: Codable>: View where T: ITunesMediaListItem, T: Identifiable, T: Hashable {
 
    let title: String
    @StateObject var vm: MediaListObservableObject<T>
    
    public init(title: String, vm: MediaListObservableObject<T>) {
        self.title = title
        self._vm = StateObject(wrappedValue: vm)
    }
    
    public var body: some View {
        List(vm.results ?? []) { item in
            NavigationLink(value: item) {
                MediaListItemView(item: item)
            }
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

struct MediaListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            Group {
                MediaListView(title: "Top 25 songs", vm: SongListObservableObject(region: "us", resultLimit: .limit25))
            }
        }
    }
}
