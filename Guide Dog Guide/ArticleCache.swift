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
    
    let fileService: FileService
    let fm = FileManager.default
    
    let refreshCallback: () -> Void
    
    var topics: [String] = []
    var documents: [String] = []
    var lastUpdate: Date? = nil
    
    var json: Any? = nil

    
    init(_ refreshCallback: @escaping () -> Void) {
        self.refreshCallback = refreshCallback
        let fileService = FileService()
        self.fileService = fileService
        self.refresh(force: false)
    }
    
    func refresh(force: Bool) {
        if (!self.fileService.doesIndexExist()) {
            self.retrieveData()
        } else {
            if force {
                self.checkForUpdates()
            } else {
                self.readFiles()
                self.refreshCallback()
            }
        }
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
    
    func checkForUpdates() {
        let url = URL(string: documentsUri)!
        let session = URLSession.shared
        
        session.dataTask(with: url) {
            (data, response, err) in
            DispatchQueue.main.async {
                self.updateJson(data: data!)
            }
        }.resume()
    }
    
    func retrieveData() {
        let url = URL(string: documentsUri)!
        let session = URLSession.shared
        
        session.dataTask(with: url) {
            (data, response, err) in
            DispatchQueue.main.async {
                self.fileService.writeIndexFile(contents: String(data: data!, encoding: .utf8)!)
                self.topics = self.parseJson(data: data!, getDocuments: self.retrieveDocument)
                self.refreshCallback()
            }
        }.resume()
    }
    
    func readFiles() {
        let indexContent = self.fileService.readIndexFile()
        self.topics = self.parseJson(data: indexContent.data(using: .utf8)!, getDocuments: self.getDocument)
        self.refreshCallback()
    }
    
    func getDocument(_ filename: String, _ index: Int) -> String {
        if !fileService.doesDocumentExist(filename) {
            return retrieveDocument(filename, index)
        } else {
            return self.fileService.readDocument(filename: filename)
        }
    }
    
    func retrieveDocument(_ file: String, _ index: Int) -> String {
        let mdOptions = self.createMarkdownOptions()
        var markdownEngine = Markdown(options: mdOptions)
        let url = URL(string: self.documentUri + file)!
        let session = URLSession.shared
        
        session.dataTask(with: url) {
            (data, response, err) in
            DispatchQueue.main.async {
                if let contents = data {
                    self.documents[index] = markdownEngine.transform(String(data: contents, encoding: String.Encoding.utf8) as String!)
                    self.fileService.writeDocument(filename: file, contents: self.documents[index])
                }
            }
            }.resume()
        return "Loading..."
    }
    
    func parseJson(data: Data, getDocuments: (String, Int) -> String) -> [String] {
        var names = [String]()
        var index = 0
        json = try? JSONSerialization.jsonObject(with: data, options: [])
        if let documents = (json as AnyObject)["documents"] as? [[String: AnyObject]] {
            for document in documents {
                if let name = document["name"] as? String {
                    names.append(name)
                }
                if let filename = document["location"] as? String {
                    self.documents.append(getDocuments(filename, index))
                }
                index += 1
            }
        }
        
        return names
    }
    
    func updateJson(data: Data) {
        var changes = false
        let newJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any?]
        
        if isJsonDateNewer(json1: newJson!!, json2: json as! [String : Any?], key: "lastUpdated") {
            changes = true
            self.retrieveData()
        }
        
//        if let newDocuments = (newJson as AnyObject)["documents"] as? [[String: AnyObject]] {
//            if let documents = (json as AnyObject)["documents"] as? [[String: AnyObject]] {
//                for newDocument in newDocuments {
//                    if let name = document["name"] as? String {
//                        names.append(name)
//                    }
//                    if let filename = document["location"] as? String {
//                        self.documents.append(getDocuments(filename, index))
//                    }
//                    index += 1
//                }
//            }
//        }
        
        if !changes {
            self.refreshCallback()
        }
    }
    
    func isJsonDateNewer(json1: [String: Any?], json2: [String: Any?], key: String) -> Bool {
        if let value1 = json1[key] as? String {
            if let value2 = json2[key] as? String {
                let date1 = string2date(str: value1)
                let date2 = string2date(str: value2)
                
                return date1 > date2
            }
        }
        
        return false
    }
    
    func string2date(str: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: str)!
    }

}
