//
//  ContentView.swift
//  fetch-ios
//
//  Created by Max Maeder on 10/8/24.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    @StateObject private var dataFetcher = DataFetcher()
    
    // Keep track of expanded columns
    @State private var expandedSections: Set<Int> = []
    
    var body: some View {
        NavigationView {
            if dataFetcher.isLoading {
                // If data being fetched, show loader
                ProgressView("Loading...")
                    .navigationTitle("Items")
                    .navigationBarTitleDisplayMode(.large)
            } else {
                // Otherwise, display the list of items
                List {
                    // Group items by list ID
                    ForEach(Array(groupItemsByListId().sorted(by: { $0.key < $1.key })), id: \.key) { listId, items in
                        // Display collapsible section for each list ID
                        Section(header: sectionHeader(for: listId)) {
                            // When expanded, show items under section header
                            if expandedSections.contains(listId) {
                                ForEach(items) { item in
                                    Text(item.name ?? "")
                                }
                            }
                        }
                    }
                }
                // Add page title
                .navigationTitle("Hiring Items")
                .navigationBarTitleDisplayMode(.large)
            }
        }
        // Fetch data when view appears
        .onAppear {
            dataFetcher.fetchData()
        }
    }
    
    // Group loaded data from by listId, returning a dict keyed
    //   by list ID, where the value is an array of items with that ID
    private func groupItemsByListId() -> [Int: [Item]] {
        let groupedDictionary = Dictionary(grouping: dataFetcher.items, by: { $0.listId })
        return groupedDictionary
    }
    
    // Custom section header, toggle list expansion on tap
    private func sectionHeader(for listId: Int) -> some View {
        HStack {
            Text("List ID: \(listId)")
                .font(.headline)
            
            Spacer()
            
            // Expand/collapse icon
            Image(systemName: expandedSections.contains(listId) ? "chevron.down" : "chevron.right")
                .onTapGesture {
                    toggleSection(listId)
                }
        }
    }
    
    // Toggle whether section expanded
    private func toggleSection(_ listId: Int) {
        if expandedSections.contains(listId) {
            expandedSections.remove(listId)
        } else {
            expandedSections.insert(listId)
        }
    }
}



#Preview {
    ContentView()
}
