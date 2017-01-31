//
//  MasterViewController.swift
//  Guide Dog Guide
//
//  Created by David Bradford on 1/14/17.
//  Copyright © 2017 David Bradford. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var documentsUri = "https://raw.githubusercontent.com/dbradf/guide-dog-guide-data/master/documents.json"
    var documentUri = "https://raw.githubusercontent.com/dbradf/guide-dog-guide-data/master/documents/"
    
    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var json: Any? = nil

    var topics = [String]()
    var documents = [String]()

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
                self.tableView.reloadData()
            }
        }.resume()
    }
    
    func retrieveDocument(file: String, index: Int) {
        let mdOptions = self.createMarkdownOptions()
        var markdownEngine = Markdown(options: mdOptions)
        let url = URL(string: documentUri + file)!
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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.retrieveData()
        // Do any additional setup after loading the view, typically from a nib.
//        self.navigationItem.leftBarButtonItem = self.editButtonItem

//        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
//        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = topics[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = documents[indexPath.row]
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = topics[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            objects.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//        }
//    }


}

