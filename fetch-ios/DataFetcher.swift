//
//  DataFetcher.swift
//  fetch-ios
//
//  Created by Max Maeder on 10/8/24.
//

import Foundation

// A hiring 'item'
struct Item: Codable, Identifiable {
    let id: Int
    let listId: Int
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case listId
        case name
    }
}

// The URL to query hiring items
let itemsURL = URL(string: "https://fetch-hiring.s3.amazonaws.com/hiring.json")!

// A class responsible for fetching and managing the list of hiring items
class DataFetcher: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false
    
    func fetchData() {
        isLoading = true
        
        // Fetch data from backend
        let task = URLSession.shared.dataTask(with: itemsURL) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                // Parse JSON response
                let fetchedItems = try JSONDecoder().decode([Item].self, from: data)
                
                DispatchQueue.main.async {
                    self.items = fetchedItems
                        // Filter out items where name is blank/null
                        .filter { $0.name != nil && !$0.name!.isEmpty }
                        // Sort lexicographically by list ID, then name
                        .sorted {
                            if $0.listId == $1.listId {
                                return $0.name! < $1.name!
                            } else {
                                return $0.listId < $1.listId
                            }
                        }
                    self.isLoading = false
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
        
        task.resume()
    }
}
