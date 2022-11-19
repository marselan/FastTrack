//
//  ContentView.swift
//  FastTrack
//
//  Created by Mariano Arselan on 18-11-22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            HStack {
                TextField("Search for a song", text: $searchText)
                    .onSubmit(startSearch)
                Button("Search") {
                    startSearch()
                }
            }
            ScrollView() {
                LazyVGrid(columns: gridItems) {
                    ForEach(tracks) { track in
                        Text(track.trackName)
                            .frame(width: 150, height: 150)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
    
    let gridItems: [GridItem] = [
        GridItem(.adaptive(minimum: 150, maximum: 200)),
    ]
    
    @AppStorage("searchText") var searchText = ""
    @State private var tracks = [Track]()
    
    func performSearch() async throws {
        guard let url = URL(string: "https://itunes.apple.com/search?term=\(searchText)&limit=100&entity=song") else { return }
        let (data, _) = try await URLSession.shared.data(from: url)
        let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
        tracks = searchResult.results
    }
    
    func startSearch() {
        Task {
            try await performSearch()
        }
    }
}

struct Track: Identifiable, Decodable {
    var id: Int { trackId }
    let trackId: Int
    let artistName: String
    let trackName: String
    let previewUrl: URL
    let artworkUrl100: String
    var artworkURL: URL? {
        let replacedString = artworkUrl100.replacingOccurrences(of: "100x100", with: "300x300")
        return URL(string: replacedString)
    }
}

struct SearchResult: Decodable {
    let results: [Track]
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
