//
//  ObservableObject.swift
//  
//
//  Created by Alfian Losari on 6/18/22.
//

import SwiftUI
import ITunesFeedGenerator

public enum FetchPhase<T> {
    case success(T)
    case failure(Error)
    case loading
}

public class MediaListObservableObject<T: Codable>: ObservableObject {
    
    let repository: FeedRepositoryInterface
    let region: String
    let resultLimit: ResultLimit
    
    @Published var phase: FetchPhase<Feed<T>> = .loading
    
    init(region: String = "us",
        resultLimit: ResultLimit = .limit25,
        repository: FeedRepositoryInterface = FeedRepository()) {
            self.region = region
            self.resultLimit = resultLimit
            self.repository = repository
    }
    
    public func fetchMedia() {
        phase = .loading
        Task.detached(priority: .high) { [weak self] in
            guard let self = self else { return }
            do {
                let results = try await self.fetch()
                Task { @MainActor in
                    self.phase = .success(results)
                }
                
            } catch {
                Task { @MainActor in
                    self.phase = .failure(error)
                }
            }
        }
    }
    
    func fetch() async throws -> Feed<T> {
        fatalError("Implement in subclass")
    }
    
}

public final class SongListObservableObject: MediaListObservableObject<Song> {
    
    public override init(region: String = "us",
        resultLimit: ResultLimit = .limit25,
        repository: FeedRepositoryInterface = FeedRepository()) {
            super.init(region: region, resultLimit: resultLimit, repository: repository)
    }
    
    
    override func fetch() async throws -> Feed<Song> {
        try await repository.getMostPlayedSongsFeed(region: region, resultLimit: resultLimit)
    }
    
}

public final class BookListObservableObject: MediaListObservableObject<Book> {
    
    let pricingType: PricingType
    
    public init(region: String = "us",
        resultLimit: ResultLimit = .limit25,
        pricingType: PricingType,
        repository: FeedRepositoryInterface = FeedRepository()) {
            self.pricingType = pricingType
            super.init(region: region, resultLimit: resultLimit, repository: repository)
    }
    
    
    override func fetch() async throws -> Feed<Book> {
        try await repository.getTopBooksFeed(region: region, type: pricingType, resultLimit: resultLimit)
    }
    
}

public final class AppListObservableObject: MediaListObservableObject<Application> {
    
    let pricingType: PricingType
    
    public init(region: String = "us",
        resultLimit: ResultLimit = .limit25,
        pricingType: PricingType,
        repository: FeedRepositoryInterface = FeedRepository()) {
            self.pricingType = pricingType
            super.init(region: region, resultLimit: resultLimit, repository: repository)
    }
    
    
    override func fetch() async throws -> Feed<Application> {
        try await repository.getTopAppsFeed(region: region, type: pricingType, resultLimit: resultLimit)
    }
    
}
