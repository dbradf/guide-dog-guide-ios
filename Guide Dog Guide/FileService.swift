//
//  FileService.swift
//  Guide Dog Guide
//
//  Created by David Bradford on 2/11/17.
//  Copyright © 2017 David Bradford. All rights reserved.
//

import Foundation

class FileService {
    let INDEX_FILE = "documents.json"
    let DOCUMENTS_DIR = "documents"
    
    let fm = FileManager.default
    let supportDirectoryUrl: URL?
    
    init() {
        do {
            supportDirectoryUrl = try fm.url(for:.applicationSupportDirectory,
                                     in: .userDomainMask,
                                     appropriateFor: nil,
                                     create: true)
        } catch {
            supportDirectoryUrl = nil
        }
    }
    
    func readIndexFile() -> String {
        let path = getPath(INDEX_FILE)
        return String(data: fm.contents(atPath: path)!, encoding: String.Encoding.utf8)!
    }
    
    func writeIndexFile(contents: String) {
        createIndexFile(contents: contents)
    }
    
    func createIndexFile(contents: String) {
        let path = getPath(INDEX_FILE)
        fm.createFile(atPath: path, contents: contents.data(using: .utf8), attributes: nil)
    }
    
    func doesIndexExist() -> Bool {
        return fileExists(INDEX_FILE)
    }
    
    func readDocument(filename: String) -> String {
        let path = getDocumentPath(filename)
        return String(data: fm.contents(atPath: path)!, encoding: String.Encoding.utf8)!
    }
    
    func writeDocument(filename: String, contents: String) {
        if !doesDocumentsExist() {
            createDocumentsDirectory()
        }
        
        let path = getDocumentPath(filename)
        fm.createFile(atPath: path, contents: contents.data(using: .utf8), attributes: nil)
    }
    
    func createDocumentsDirectory() {
        let path = supportDirectoryUrl?.appendingPathComponent(DOCUMENTS_DIR)
        do {
            try fm.createDirectory(at: path!, withIntermediateDirectories: true, attributes: nil)
        } catch {}
    }
    
    func doesDocumentExist(_ filename: String) -> Bool {
        return fm.fileExists(atPath: getDocumentPath(filename))
    }
    
    func doesDocumentsExist() -> Bool {
        return fileExists(DOCUMENTS_DIR)
    }
    
    func fileExists(_ filename: String) -> Bool {
        return fm.fileExists(atPath: getPath(filename))
    }
    
    func getDocumentPath(_ filename: String) -> String {
        return (supportDirectoryUrl?.appendingPathComponent(DOCUMENTS_DIR).appendingPathComponent(filename).path)!
    }
    
    func getPath(_ filename: String) -> String {
        return (supportDirectoryUrl?.appendingPathComponent(filename).path)!
    }

    
    
}
