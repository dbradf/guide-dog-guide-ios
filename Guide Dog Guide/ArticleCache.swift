//
//  ArticleCache.swift
//  Guide Dog Guide
//
//  Created by David Bradford on 2/1/17.
//  Copyright © 2017 David Bradford. All rights reserved.
//

import Foundation

class ArticleCache {
    let documentsUri = "https://raw.githubusercontent.com/dbradf/guide-dog-guide-data/master/documents.json"
    let documentUri = "https://raw.githubusercontent.com/dbradf/guide-dog-guide-data/master/documents/"
    
    let fm = FileManager.default
    
    let refreshCallback: () -> Void
    
    var topics: [String] = []
    var documents: [String] = []
    var lastUpdate: Date? = nil
    
    var json: Any? = nil

    
    init(_ refreshCallback: @escaping () -> Void) {
        self.refreshCallback = refreshCallback
        retrieveData()
    }
    
    func getTopics() -> [String] {
        return topics
    }
    
    func createMarkdownOptions() -> MarkdownOptions {
        var markdownOptions = MarkdownOptions()
        markdownOptions.autoHyperlink = true
        markdownOptions.autoNewlines = true
        
        return markdownOptions
    }
    
    func retrieveData() {
        let url = URL(string: documentsUri)!
        let session = URLSession.shared
        
        session.dataTask(with: url) {
            (data, response, err) in
            DispatchQueue.main.async {
                self.topics = self.parseJson(data: data!)
                self.refreshCallback()
            }
            }.resume()
    }
    
    func retrieveDocument(file: String, index: Int) {
        let mdOptions = self.createMarkdownOptions()
        var markdownEngine = Markdown(options: mdOptions)
        let url = URL(string: self.documentUri + file)!
        let session = URLSession.shared
        
        session.dataTask(with: url) {
            (data, response, err) in
            DispatchQueue.main.async {
                self.documents[index] = markdownEngine.transform(String(data: data!, encoding: String.Encoding.utf8) as String!)
                
            }
            }.resume()
    }
    
    func parseJson(data: Data) -> [String] {
        print(data.description)
        var names = [String]()
        var index = 0
        json = try? JSONSerialization.jsonObject(with: data, options: [])
        if let documents = (json as AnyObject)["documents"] as? [[String: AnyObject]] {
            for document in documents {
                if let name = document["name"] as? String {
                    names.append(name)
                }
                if let filename = document["location"] as? String {
                    retrieveDocument(file: filename, index: index)
                }
                self.documents.append("Loading...")
                index += 1
            }
        }
        
        return names
    }
    

}
